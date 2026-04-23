<script setup>
import { ref, watch, onMounted, onUnmounted } from 'vue'
import { listReservation, updateReservation } from '@/api/reservation'
import { listSeat } from '@/api/seat'
import { listRoom } from '@/api/room'
import { useUserStore } from '@/stores/modules/user'

const userStore = useUserStore()
const reservationData = ref({})

function parseDate(v) {
  if (!v) return null
  const d = new Date(String(v).replace(/-/g, '/'))
  return Number.isNaN(d.getTime()) ? null : d
}

function isNoShowViolation(row) {
  if (!row || row.reservationStatus !== '已预约') return false
  const inAt = parseDate(row.reservationInTime)
  if (!inAt) return false
  return Date.now() > inAt.getTime() + 15 * 60 * 1000
}

function isOvertimeSignOutViolation(row) {
  if (!row || row.reservationStatus !== '使用中') return false
  const outAt = parseDate(row.reservationOutTime)
  if (!outAt) return false
  return Date.now() > outAt.getTime()
}

function toLocalViolationRow(row) {
  return {
    ...row,
    status: '违约',
    reservationStatus: '违约中',
    remark: row.remark || (isOvertimeSignOutViolation(row) ? '超时未签退（待管理员处理）' : '超时未签到（待管理员处理）'),
  }
}

function getReservation() {
  listReservation({ userId: userStore.user.userId }).then((res) => {
    const total = Number(res?.data?.total || 0)
    const rows = res?.data?.rows || []
    if (!total || !rows.length) {
      reservationData.value = {}
      return
    }
    reservationData.value = {}

    const first = rows[0]
    const firstStatus = first?.reservationStatus
    if (firstStatus == '已预约' || firstStatus == '使用中' || firstStatus == '违约中') {
      reservationData.value =
        isNoShowViolation(first) || isOvertimeSignOutViolation(first) ? toLocalViolationRow(first) : first
      listSeat().then((seatListRes) => {
        listSeat({ pageSize: seatListRes.data.total }).then((seatsRes) => {
          const seatInfo = seatsRes.data.rows.find(
            (item) => item.id == reservationData.value.seatId
          )
          if (!seatInfo) return
          reservationData.value = {
            ...reservationData.value,
            roomId: seatInfo.roomId,
            seatNum: seatInfo.seatNum,
          }
          listRoom().then((roomListRes) => {
            listRoom({ pageSize: roomListRes.data.total }).then((roomsRes) => {
              const roomInfo = roomsRes.data.rows.find(
                (item) => item.id == reservationData.value.roomId
              )
              if (!roomInfo) return
              reservationData.value = {
                ...reservationData.value,
                name: roomInfo.name,
                location: roomInfo.location,
                rowsCount: roomInfo.rowsCount,
                colsCount: roomInfo.colsCount,
                openTime: roomInfo.openTime,
                closeTime: roomInfo.closeTime,
              }
            })
          })
        })
      })
    }
  })
}

watch(
  () => userStore.user?.userId,
  (userId) => {
    if (userId) getReservation()
  },
  { immediate: true }
)

// 监听预约刷新事件
onMounted(() => {
  uni.$on('refreshReservation', () => {
    console.log('MyReservation 收到刷新事件')
    getReservation()
  })
})

// 组件卸载时移除监听
onUnmounted(() => {
  uni.$off('refreshReservation')
})

function gotoScan() {
  uni.navigateTo({ url: '/pages/scan/scan' })
}

function qrSignInUrl() {
  if (!reservationData.value.id) return ''
  const text = signInCode()
  return `https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${encodeURIComponent(text)}`
}

function qrSignOutUrl() {
  if (!reservationData.value.id) return ''
  const text = signOutCode()
  return `https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${encodeURIComponent(text)}`
}

function signInCode() {
  if (!reservationData.value.id) return ''
  return `STUDY_ROOM:signIn:${reservationData.value.id}`
}

function signOutCode() {
  if (!reservationData.value.id) return ''
  return `STUDY_ROOM:signOut:${reservationData.value.id}`
}

function copyCode(text) {
  if (!text) {
    uni.showToast({ title: '业务码为空', icon: 'none' })
    return
  }
  uni.setClipboardData({
    data: text,
    success: () => uni.showToast({ title: '业务码已复制', icon: 'success' }),
    fail: () => uni.showToast({ title: '复制失败', icon: 'none' }),
  })
}

function applyUnlock() {
  // 将“申请解锁/解除禁约”的诉求转成一条反馈申诉（由管理员处理）
  uni.navigateTo({
    url:
      '/pages/feedback/index?prefillType=' +
      encodeURIComponent('申诉') +
      '&prefillContent=' +
      encodeURIComponent(
        `我申请解除禁约/解锁订单（订单ID：${reservationData.value.id}，当前预约状态：${reservationData.value.reservationStatus}）。`
      ),
  })
}

function cancelReservation() {
  uni.showModal({
    title: '提示',
    content: '确定取消预约吗？',
    success(res) {
      if (!res.confirm) return
      updateReservation({
        id: reservationData.value.id,
        reservationStatus: '取消预约',
      }).then((r) => {
        if (r.data.code === 200) {
          getReservation()
          uni.showToast({ title: '取消预约成功', icon: 'success' })
        }
      })
    },
  })
}
</script>

<template>
  <view v-if="reservationData.id" class="my-reservation">
    <view class="title">
      <text class="h2">我的预约</text>
      <text class="tag">{{ reservationData.reservationStatus }}</text>
    </view>
    <view class="reservation">
      <view class="info">
        <text class="h4">{{ reservationData.name }}</text>
        <text class="p"><text class="b">布局：</text>{{ reservationData.rowsCount }}行 ~ {{ reservationData.colsCount }}列</text>
        <text class="p"><text class="b">位置：</text>{{ reservationData.location }}</text>
        <text class="p"><text class="b">座位号：</text>{{ reservationData.seatNum }}</text>
        <text class="p"><text class="b">开放时间：</text>{{ reservationData.openTime }} ~ {{ reservationData.closeTime }}</text>
        <text class="p"><text class="b">预约时间：</text>{{ reservationData.reservationInTime }}</text>
        <text class="p"><text class="b">超时时间：</text>{{ reservationData.reservationOutTime }}</text>
        <text class="p warn"><text class="b">注意：</text>预约开始 15 分钟内未签到系统将自动释放座位；超时未签到违约累计规则见首页说明</text>
        <text v-if="reservationData.auditStatus" class="p"><text class="b">订单审核：</text>{{ reservationData.auditStatus }}</text>
      </view>
      <view class="btn">
        <view v-if="reservationData.reservationStatus == '使用中'">
          <text class="tag ok">已签到</text>
          <image v-if="qrSignOutUrl()" class="qr" :src="qrSignOutUrl()" mode="aspectFit" />
          <text class="code">业务码：{{ signOutCode() }}</text>
          <button size="mini" @click="copyCode(signOutCode())">复制签退业务码</button>
          <text class="qr-tip">请前往「扫码签到 / 签退」页面扫码签退</text>
          <button size="mini" type="primary" @click="gotoScan">去扫码签退</button>
        </view>
        <view v-else-if="reservationData.reservationStatus == '违约中'">
          <text class="tag" style="color:#f56c6c;background:#fef0f0;">当前为违约禁约中</text>
          <button size="mini" type="primary" @click="applyUnlock">申请解锁</button>
        </view>
        <view v-else>
          <image v-if="reservationData.reservationStatus == '已预约' && qrSignInUrl()" class="qr" :src="qrSignInUrl()" mode="aspectFit" />
          <text v-if="reservationData.reservationStatus == '已预约'" class="code">业务码：{{ signInCode() }}</text>
          <button v-if="reservationData.reservationStatus == '已预约'" size="mini" @click="copyCode(signInCode())">复制签到业务码</button>
          <text v-if="reservationData.reservationStatus == '已预约'" class="qr-tip">到馆扫描以上签到码或「我的-扫码签到」</text>
          <button size="mini" type="primary" @click="gotoScan">去扫码签到</button>
          <button size="mini" type="warn" @click="cancelReservation">取消预约</button>
        </view>
      </view>
    </view>
  </view>
</template>

<style lang="scss" scoped>
.my-reservation {
  .title {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin: 40rpx 0 20rpx;
  }

  .h2 {
    color: #555;
    font-size: 32rpx;
    font-weight: 600;
  }

  .tag {
    padding: 4rpx 16rpx;
    font-size: 22rpx;
    color: #409eff;
    background: #ecf5ff;
    border-radius: 8rpx;
  }

  .tag.ok {
    color: #67c23a;
    background: #f0f9eb;
    display: block;
    margin-bottom: 16rpx;
    text-align: center;
  }

  .reservation {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 32rpx;
    background: #fff;
    border-radius: 20rpx;
    box-shadow: 0 8rpx 10rpx rgba(0, 0, 0, 0.08);
  }

  .info {
    flex: 1;
    color: #555;
    display: flex;
    flex-direction: column;
    gap: 8rpx;
  }

  .h4 {
    font-size: 34rpx;
    font-weight: 600;
    margin-bottom: 8rpx;
  }

  .p {
    font-size: 24rpx;
    line-height: 1.5;
  }

  .b {
    font-weight: 600;
  }

  .warn {
    color: #f56c6c;
  }

  .btn {
    width: 220rpx;
    display: flex;
    flex-direction: column;
    align-items: flex-end;
    gap: 16rpx;
  }

  .qr {
    width: 200rpx;
    height: 200rpx;
    background: #fff;
    border-radius: 12rpx;
  }

  .qr-tip {
    font-size: 20rpx;
    color: #909399;
    text-align: right;
    line-height: 1.3;
  }

  .code {
    font-size: 20rpx;
    color: #606266;
    text-align: right;
    word-break: break-all;
    max-width: 420rpx;
  }
}
</style>
