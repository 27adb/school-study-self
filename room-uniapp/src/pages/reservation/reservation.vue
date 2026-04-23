<script setup>
import { ref, computed } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { listRoom, getRoom } from '@/api/room'
import { listSeat } from '@/api/seat'
import { listReservation, addReservation } from '@/api/reservation'
import { getRecommend, getGroupRecommend } from '@/api/assistant'
import { createCarpool, joinCarpool } from '@/api/thesis'
import { listNotice } from '@/api/notice'
import { baseURL } from '@/utils/request'
import { goLogin } from '@/utils/auth'
import { runStudentViolationCheck } from '@/utils/violation'
import { useUserStore } from '@/stores/modules/user'

const userStore = useUserStore()
const loading = ref(false)
const roomList = ref([])
const searchKeyword = ref('')
const resetBtnShow = ref(false)

function getList() {
  loading.value = true
  listRoom({ name: searchKeyword.value })
    .then((res) => {
      const body = res.data
      if (body && body.code !== undefined && body.code !== 200) {
        uni.showToast({ title: body.msg || '加载自习室失败', icon: 'none' })
        roomList.value = []
        return
      }
      roomList.value = (body && body.rows) || []
    })
    .catch(() => {
      roomList.value = []
    })
    .finally(() => {
      loading.value = false
    })
}
getList()

function searchBtn() {
  if (!searchKeyword.value) return uni.showToast({ title: '请输入自习室名称', icon: 'none' })
  resetBtnShow.value = true
  getList()
}
function resetBtn() {
  searchKeyword.value = ''
  resetBtnShow.value = false
  getList()
}

function handleImageError(e, item) {
  // 图片加载失败时，清除 item.image，让占位符显示
  console.log('封面图加载失败:', item?.name, e.detail?.errMsg)
  if (item) {
    item._imageFailed = true // 标记该图片加载失败
  }
}

const roomShow = ref(false)
const roomData = ref({})
const seatList = ref([])
const seatOccupancy = ref({})
const selectedSeat = ref(null)
const loading2 = ref(false)
const groupSize = ref(2)
const groupSuggestion = ref([])
const shareCodeJoin = ref('')
const carpoolGroupId = ref(null)
const reservationRuleText = ref('请在预约开始后尽快签到，未按规则签到将计入违约。')

/** 预约时长（小时），论文要求 1～4 小时 */
const durationHours = ref(2)
const durationOptions = [1, 2, 3, 4]

const reservationData = ref({ userId: null, seatId: null, status: null, reservationStatus: null, reservationInTime: null, reservationOutTime: null })

function formatLocalDateTime(d) {
  const pad = (n) => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`
}

function onDurationChange(e) {
  const i = Number(e.detail.value)
  durationHours.value = durationOptions[i] || 2
  if (selectedSeat.value) applyReservationWindow()
  loadSeatOccupancy()
}

function onGroupSizeChange(e) {
  const options = [2, 3, 4, 5]
  const i = Number(e.detail?.value)
  groupSize.value = options[i] || 2
}

function stripHtml(content) {
  return String(content || '').replace(/<[^>]+>/g, '').replace(/\s+/g, ' ').trim()
}

function loadRuleNotice() {
  return listNotice({ pageNum: 1, pageSize: 20, noticeType: 2 })
    .then((res) => {
      const rows = res?.data?.rows || []
      const hit = rows.find((n) => /规则|签到|预约|违约/.test(`${n.noticeTitle || ''}${n.noticeContent || ''}`)) || rows[0]
      if (!hit) return
      const brief = stripHtml(hit.noticeContent || hit.noticeTitle || '')
      if (brief) {
        reservationRuleText.value = brief.slice(0, 90)
      }
    })
    .catch(() => {})
}

function applyReservationWindow() {
  const hours = Math.min(4, Math.max(1, Number(durationHours.value) || 2))
  const nowIn = new Date()
  const nowOut = new Date(nowIn.getTime() + hours * 3600000)
  reservationData.value.reservationInTime = formatLocalDateTime(nowIn)
  reservationData.value.reservationOutTime = formatLocalDateTime(nowOut)
}

function loadSeatOccupancy() {
  return listReservation().then((res) => {
    const map = {}
    const winInStr = reservationData.value.reservationInTime
    const winOutStr = reservationData.value.reservationOutTime
    const winIn = winInStr ? new Date(String(winInStr).replace(/-/g, '/')) : null
    const winOut = winOutStr ? new Date(String(winOutStr).replace(/-/g, '/')) : null
    ;(res.data.rows || []).forEach((r) => {
      if (r.userId === userStore.user.userId) return
      if (!(r.reservationStatus === '已预约' || r.reservationStatus === '使用中')) return
      if (winIn && winOut && r.reservationInTime && r.reservationOutTime) {
        const ri = new Date(String(r.reservationInTime).replace(/-/g, '/'))
        const ro = new Date(String(r.reservationOutTime).replace(/-/g, '/'))
        if (!(ri < winOut && ro > winIn)) return
      }
      map[r.seatId] = r.reservationStatus
    })
    seatOccupancy.value = map
  })
}

function selectSeat(room) {
  if (room.status == '关闭') return uni.showToast({ title: '自习室已关闭', icon: 'none' })
  loading2.value = true
  roomShow.value = true
  selectedSeat.value = null
  groupSuggestion.value = []
  shareCodeJoin.value = ''
  carpoolGroupId.value = null
  reservationData.value = { userId: null, seatId: null, status: null, reservationStatus: null, reservationInTime: null, reservationOutTime: null, carpoolGroupId: null }
  getRoom(room.id).then((res) => (roomData.value = res.data.data))
  listSeat({ pageNum: 1, pageSize: 1000, roomId: room.id }).then((res) => {
    seatList.value = res.data.rows || []
    loading2.value = false
  })
  loadSeatOccupancy()
}

const seatGrid = computed(() => {
  const rows = roomData.value.rowsCount
  const cols = roomData.value.colsCount
  if (!rows || !cols) return []
  const grid = []
  for (let r = 1; r <= rows; r++) {
    for (let c = 1; c <= cols; c++) grid.push({ rowNum: r, colNum: c, status: null, id: null, seatNum: null })
  }
  seatList.value.forEach((seat) => {
    const merged = { ...seat, status: seatOccupancy.value[seat.id] ?? seat.status }
    const idx = (seat.rowNum - 1) * cols + seat.colNum - 1
    if (idx >= 0 && idx < grid.length) grid[idx] = merged
  })
  return grid
})

function getSeatClass(seat) {
  let cls = ''
  if (seat.status === 0) cls = 'seat-normal'
  if (seat.status === 1) cls = 'seat-fault'
  if (seat.status === null) cls = 'seat-empty'
  if (seat.status == '已预约') cls = 'seat-reserved'
  if (seat.status == '使用中') cls = 'seat-using'
  if (selectedSeat.value === seat.id) cls += ' seat-selected'
  return cls
}

const gridStyle = computed(() => ({ gridTemplateColumns: `repeat(${roomData.value.colsCount || 1}, 1fr)` }))

function canBook(seat) {
  return seat && seat.id && seat.status === 0
}

function pickSeat(seat) {
  if (!canBook(seat)) return
  selectedSeat.value = seat.id
  reservationData.value = {
    userId: userStore.user.userId,
    seatId: seat.id,
    status: '正常',
    reservationStatus: '已预约',
    reservationInTime: null,
    reservationOutTime: null,
    carpoolGroupId: carpoolGroupId.value || null,
  }
  applyReservationWindow()
  loadSeatOccupancy()
}

function reservation(seat) {
  if (!seat.id) return
  if (seat.status === '使用中') return uni.showToast({ title: '该座位使用中', icon: 'none' })
  if (seat.status === '已预约') return uni.showToast({ title: '该座位已预约', icon: 'none' })
  if (seat.status === 1) return uni.showToast({ title: '该座位故障', icon: 'none' })
  listReservation({ userId: userStore.user.userId }).then((res) => {
    const latest = (res.data.rows || [])[0]
    if (latest && (latest.reservationStatus == '已预约' || latest.reservationStatus == '使用中')) {
      return uni.showToast({ title: '你已预约，不可重复预约', icon: 'none' })
    }
    pickSeat(seat)
  })
}

function smartRecommend() {
  applyReservationWindow()
  const params = {
    roomId: roomData.value.id,
    reservationInTime: reservationData.value.reservationInTime,
    reservationOutTime: reservationData.value.reservationOutTime,
  }
  getRecommend(params).then((res) => {
    if (res.data.code !== 200) {
      uni.showToast({ title: res.data.msg || '暂无可推荐座位', icon: 'none' })
      return
    }
    const target = seatGrid.value.find((s) => s.id === res.data.data.seatId)
    if (!target) {
      uni.showToast({ title: '暂无可推荐座位', icon: 'none' })
      return
    }
    pickSeat(target)
    uni.showToast({ title: `已推荐座位 ${target.seatNum}`, icon: 'none' })
  })
}

function groupRecommend() {
  const n = Number(groupSize.value || 2)
  if (n < 2) {
    uni.showToast({ title: '拼座人数至少2人', icon: 'none' })
    return
  }
  applyReservationWindow()
  getGroupRecommend({
    roomId: roomData.value.id,
    size: n,
    reservationInTime: reservationData.value.reservationInTime,
    reservationOutTime: reservationData.value.reservationOutTime,
  }).then((res) => {
    if (res.data.code !== 200) {
      uni.showToast({ title: res.data.msg || '未找到连续拼座', icon: 'none' })
      return
    }
    const ids = (res.data.data || []).map((item) => item.seatId)
    const group = seatGrid.value.filter((s) => ids.includes(s.id))
    if (!group.length) {
      uni.showToast({ title: '未找到连续拼座', icon: 'none' })
      return
    }
    groupSuggestion.value = group
    pickSeat(group[0])
    uni.showToast({ title: `已推荐拼座 ${group.map((x) => x.seatNum).join('、')}`, icon: 'none' })
  })
}

function startCarpool() {
  if (!roomData.value.id) return
  createCarpool({ roomId: roomData.value.id, seatCount: groupSize.value }).then((res) => {
    const body = res.data
    if (!body || body.code !== 200) {
      uni.showToast({ title: (body && body.msg) || '创建失败', icon: 'none' })
      return
    }
    const gid = body.data && body.data.id
    if (!gid) {
      uni.showToast({ title: '未返回拼座组', icon: 'none' })
      return
    }
    carpoolGroupId.value = gid
    reservationData.value.carpoolGroupId = gid
    uni.showToast({ title: '拼座已创建，请选座并预约（组长占座）', icon: 'none' })
  })
}

function joinCarpoolBtn() {
  if (!selectedSeat.value) return uni.showToast({ title: '请先点击座位', icon: 'none' })
  if (!shareCodeJoin.value.trim()) return uni.showToast({ title: '请输入拼座码', icon: 'none' })
  applyReservationWindow()
  joinCarpool({
    shareCode: shareCodeJoin.value.trim().toUpperCase(),
    seatId: selectedSeat.value,
    reservationInTime: reservationData.value.reservationInTime,
    reservationOutTime: reservationData.value.reservationOutTime,
  }).then((r) => {
    const body = r.data
    if (body && body.code === 200) {
      roomShow.value = false
      uni.showToast({ title: '加入拼座成功', icon: 'success' })
    } else {
      uni.showToast({ title: (body && body.msg) || '加入失败', icon: 'none' })
    }
  })
}

function reservationBtn() {
  if (!reservationData.value.userId) return
  runStudentViolationCheck(userStore.user.userId).then((check) => {
    if (check.noShowMarked > 0) {
      uni.showToast({ title: `检测到 ${check.noShowMarked} 条违约，已更新状态`, icon: 'none' })
    }
    listReservation({ userId: userStore.user.userId, pageNum: 1, pageSize: 200 }).then((res) => {
      const rows = res.data.rows || []
      const violationCount = rows.filter((item) => item.status === '违约' || item.reservationStatus === '违约中').length
      if (violationCount >= 3) {
        return uni.showModal({
          title: '禁约提示',
          content: `你当前累计违约 ${violationCount} 次，已被禁约，请联系管理员处理。`,
          showCancel: false,
        })
      }
      const payload = { ...reservationData.value }
      if (carpoolGroupId.value) payload.carpoolGroupId = carpoolGroupId.value
      addReservation(payload).then((r) => {
        const body = r.data
        if (body && body.code === 200) {
          roomShow.value = false
          const msg = [
            `预约时间：${reservationData.value.reservationInTime} ~ ${reservationData.value.reservationOutTime}`,
            '请在规则要求时间内完成签到，逾期将计入违约。',
            `公告规则：${reservationRuleText.value}`,
          ].join('\n')
          uni.showModal({
            title: '预约成功提醒',
            content: msg,
            showCancel: false,
            confirmText: '我知道了',
            success: () => {
              uni.$emit('refreshReservation')
              uni.switchTab({ url: '/pages/index/index' })
            },
          })
        } else {
          uni.showToast({ title: (body && body.msg) || '预约失败', icon: 'none' })
        }
      })
    })
  })
}

onShow(() => {
  if (!userStore.token) goLogin()
  loadRuleNotice()
})
</script>

<template>
  <view class="page">
    <scroll-view scroll-y class="scroll">
      <view class="search-row">
        <input v-model="searchKeyword" class="search-input" placeholder="搜索自习室" />
        <button size="mini" type="primary" @click="searchBtn">搜索</button>
      </view>
      <button v-if="resetBtnShow" class="reset" @click="resetBtn">重置</button>
      <view v-if="loading" class="loading">加载中...</view>
      <view v-for="item in roomList" :key="item.id" class="room-card" @click="selectSeat(item)">
        <!-- 封面图：检查图片是否能正常加载 -->
        <image 
          v-if="item.image && item.image.trim() && !item._imageFailed" 
          class="cover" 
          :src="baseURL + item.image" 
          mode="aspectFill" 
          @error="handleImageError($event, item)" 
        />
        <view v-else class="cover-placeholder">
          <text>📚 {{ item.name }}</text>
        </view>
        <view class="row"><view class="left"><text class="h4">{{ item.name }}</text><text class="p">📍 {{ item.location }}</text><text class="p">🕐 {{ item.openTime }} ~ {{ item.closeTime }}</text><text class="p">⭐ 舒适度 {{ item.comfortScore != null ? item.comfortScore : '-' }} · 在馆约 {{ item.usingCount != null ? item.usingCount : 0 }} 人</text></view><view class="right"><text v-if="item.status == '开放'" class="tag ok">正常运营</text><text v-else class="tag bad">暂未开放</text><text class="tag muted">布局 {{ item.rowsCount }}×{{ item.colsCount }}</text></view></view>
      </view>
    </scroll-view>

    <view v-if="roomShow" class="modal-mask" @click="roomShow=false">
      <view class="modal" @click.stop>
        <view class="modal-title">选择座位（支持智能推荐/拼座推荐）</view>
        <view class="modal-sub" v-if="roomData.name"
          >{{ roomData.name }} · 舒适度 {{ roomData.comfortScore != null ? roomData.comfortScore : '-' }} · 在馆约
          {{ roomData.usingCount != null ? roomData.usingCount : '-' }} 人</view
        >
        <view class="tool-row">
          <picker mode="selector" :range="durationOptions" :value="durationOptions.indexOf(durationHours)" @change="onDurationChange">
            <view class="picker">预约时长：{{ durationHours }} 小时（1〜4）</view>
          </picker>
        </view>
        <view class="tool-row">
          <button size="mini" type="primary" @click="smartRecommend">智能推荐</button>
          <picker :range="[2,3,4,5]" @change="onGroupSizeChange">
            <view class="picker">拼座人数：{{ groupSize }}</view>
          </picker>
          <button size="mini" @click="groupRecommend">拼座推荐</button>
          <button size="mini" type="warn" @click="startCarpool">发起拼座</button>
        </view>
        <view v-if="carpoolGroupId" class="group-tip">已创建拼座组 #{{ carpoolGroupId }}，请选座后点「预约」</view>
        <view class="tool-row" style="flex-wrap:wrap">
          <input v-model="shareCodeJoin" class="search-input" style="flex:1;min-width:200rpx" placeholder="拼座码加入" />
          <button size="mini" type="primary" @click="joinCarpoolBtn">加入拼座</button>
        </view>
        <view v-if="groupSuggestion.length" class="group-tip">推荐拼座：{{ groupSuggestion.map(s=>s.seatNum).join('、') }}</view>
        <view v-if="loading2" class="loading">加载座位...</view>
        <scroll-view v-else scroll-x scroll-y class="seat-scroll"><view class="seat-map" :style="gridStyle"><view v-for="(seat, idx) in seatGrid" :key="seat.id ? seat.id : `e-${idx}`" class="seat" :class="getSeatClass(seat)" @click="reservation(seat)"><text class="seat-main">{{ seat.seatNum }}</text><text v-if="seat.id === selectedSeat" class="seat-sub">已选择</text><text v-else-if="seat.status === 0" class="seat-sub">空闲</text><text v-if="seat.status === 1" class="seat-sub">故障</text><text v-if="seat.status == '已预约'" class="seat-sub">已约</text><text v-if="seat.status == '使用中'" class="seat-sub">使用中</text></view></view></scroll-view>
        <view class="modal-actions"><button size="mini" @click="roomShow=false">取消</button><button size="mini" type="primary" :disabled="!reservationData.userId" @click="reservationBtn">预约</button></view>
      </view>
    </view>
  </view>
</template>

<style lang="scss" scoped>
.page{height:100vh}.scroll{height:100%;padding:10rpx}.search-row{display:flex;gap:16rpx;align-items:center}.search-input{flex:1;height:72rpx;padding:0 20rpx;background:#fff;border-radius:12rpx}.room-card{margin:16rpx 0;padding:20rpx;background:#fff;border-radius:16rpx}.cover{width:100%;height:260rpx;border-radius:12rpx}.cover-placeholder{width:100%;height:260rpx;border-radius:12rpx;background:linear-gradient(135deg,#667eea 0%,#764ba2 100%);display:flex;align-items:center;justify-content:center;color:#fff;font-size:32rpx;font-weight:600}.row{display:flex;justify-content:space-between}.h4{font-size:32rpx;font-weight:600}.p{display:block;font-size:24rpx;margin-top:6rpx}.tag{font-size:22rpx;padding:4rpx 12rpx;border-radius:8rpx;color:#fff;display:block;margin-top:8rpx}.ok{background:#67c23a}.bad{background:#f56c6c}.muted{background:#909399}.modal-mask{position:fixed;inset:0;background:rgba(0,0,0,.5);display:flex;align-items:center;justify-content:center;z-index:1000}.modal{width:96%;max-height:90vh;background:#fff;border-radius:16rpx;padding:20rpx}.modal-title{text-align:center;font-size:30rpx;font-weight:600;margin-bottom:12rpx}.modal-sub{text-align:center;font-size:24rpx;color:#606266;margin-bottom:12rpx;line-height:1.4}.tool-row{display:flex;align-items:center;gap:10rpx;margin-bottom:10rpx}.picker{font-size:24rpx;padding:8rpx 12rpx;background:#f5f7fa;border-radius:8rpx}.group-tip{font-size:24rpx;color:#409eff;margin-bottom:10rpx}.seat-scroll{max-height:55vh}.seat-map{display:grid;gap:8px;padding:10px;background:#f7fafc;border-radius:8px;min-width:min-content}.seat{display:flex;flex-direction:column;align-items:center;justify-content:center;width:40px;height:40px;font-size:20rpx;font-weight:700;border-radius:6px;box-shadow:0 2px 5px rgba(0,0,0,.15)}.seat-sub{font-size:16rpx}.seat-normal{background:rgba(64,158,255,.6);color:#fff;border:2px solid #409eff}.seat-reserved{background:rgba(230,162,60,.6);color:#fff;border:2px solid #e6a23c}.seat-using{background:rgba(144,147,153,.6);color:#fff;border:2px solid #909399}.seat-fault{background:rgba(245,108,108,.6);color:#fff;border:2px solid #f56c6c}.seat-empty{border:1px dashed #e9e9eb;color:#ccc;box-shadow:none}.seat-selected{background:rgba(103,194,58,.6)!important;border:2px solid #67c23a}.modal-actions{display:flex;justify-content:flex-end;gap:20rpx;margin-top:12rpx}
</style>
