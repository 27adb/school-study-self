<script setup>
import { ref, computed } from 'vue'
import { onShow, onShareAppMessage } from '@dcloudio/uni-app'
import { listReservation } from '@/api/reservation'
import { getShareText, getCarpoolInfo } from '@/api/thesis'
import { goLogin } from '@/utils/auth'
import { useUserStore } from '@/stores/modules/user'

const userStore = useUserStore()
const reservations = ref([])
const selectedId = ref(null)
const shareLine = ref('')
const carpoolCode = ref('')
const carpoolHint = ref('')

const resLabels = computed(() =>
  reservations.value.map((r) => `预约 #${r.id}（${r.reservationStatus || '-'}）`),
)

const shareTitle = computed(() => (shareLine.value ? shareLine.value.slice(0, 32) : '自习室预约分享'))

function loadList() {
  listReservation({ userId: userStore.user.userId, pageNum: 1, pageSize: 50 }).then((res) => {
    reservations.value = res.data.rows || []
    if (reservations.value.length && !selectedId.value) selectedId.value = reservations.value[0].id
    refreshShare()
  })
}

function refreshShare() {
  if (!selectedId.value) {
    shareLine.value = '暂无预约，完成预约后可生成分享文案与预约码。'
    return
  }
  getShareText(selectedId.value).then((res) => {
    const b = res.data
    if (b.code === 200 && b.data != null) shareLine.value = b.data
    else shareLine.value = b.msg || '获取失败'
  })
}

function onPickReservation(e) {
  const i = Number(e.detail.value)
  const row = reservations.value[i]
  if (row) {
    selectedId.value = row.id
    refreshShare()
  }
}

function resIndex() {
  const i = reservations.value.findIndex((r) => r.id === selectedId.value)
  return i >= 0 ? i : 0
}

function loadCarpool() {
  const code = (carpoolCode.value || '').trim().toUpperCase()
  if (!code) return uni.showToast({ title: '请输入拼座码', icon: 'none' })
  getCarpoolInfo(code).then((res) => {
    const b = res.data
    if (b.code !== 200) {
      carpoolHint.value = ''
      return uni.showToast({ title: b.msg || '查询失败', icon: 'none' })
    }
    const g = b.data
    if (!g) {
      carpoolHint.value = ''
      return
    }
    carpoolHint.value = `拼座码 ${code}：自习室 #${g.roomId}，招募中，过期 ${g.expireTime || '-'}`
  })
}

function copyText() {
  if (!shareLine.value) return
  uni.setClipboardData({ data: shareLine.value, success: () => uni.showToast({ title: '已复制', icon: 'none' }) })
}

onShow(() => {
  if (!userStore.token) goLogin()
  else loadList()
})

onShareAppMessage(() => ({
  title: shareTitle.value,
  path: '/pages/share/index',
}))
</script>

<template>
  <view class="page">
    <view class="card">
      <text class="title">分享预约 / 拼座</text>
      <text class="hint">将官方生成的文案发给同学，便于核对预约码或加入拼座。</text>
      <picker v-if="reservations.length" mode="selector" :range="resLabels" :value="resIndex()" @change="onPickReservation">
        <view class="picker">选择要分享的预约</view>
      </picker>
      <textarea v-model="shareLine" class="ta" />
      <button type="primary" @click="copyText">复制分享文案</button>
<!--      <button class="btn2" open-type="share">转发给好友（需小程序端支持）</button>-->
    </view>

    <view class="card">
      <text class="sub">拼座码查询</text>
      <view class="row">
        <input v-model="carpoolCode" class="input" placeholder="输入 8 位拼座码" />
        <button size="mini" type="primary" @click="loadCarpool">查询</button>
      </view>
      <text v-if="carpoolHint" class="hint2">{{ carpoolHint }}</text>
    </view>
  </view>
</template>

<style scoped>
.page {
  min-height: 100vh;
  padding: 20rpx;
  background: #f5f7fa;
}
.card {
  background: #fff;
  border-radius: 12rpx;
  padding: 24rpx;
  margin-bottom: 16rpx;
}
.title {
  display: block;
  font-size: 34rpx;
  font-weight: 700;
  margin-bottom: 12rpx;
}
.sub {
  display: block;
  font-size: 30rpx;
  font-weight: 600;
  margin-bottom: 12rpx;
}
.hint {
  display: block;
  font-size: 24rpx;
  color: #909399;
  margin-bottom: 16rpx;
  line-height: 1.5;
}
.hint2 {
  display: block;
  font-size: 24rpx;
  color: #606266;
  margin-top: 12rpx;
  line-height: 1.5;
}
.picker {
  padding: 20rpx;
  background: #f7f7f7;
  border-radius: 10rpx;
  margin-bottom: 12rpx;
  font-size: 26rpx;
}
.ta {
  width: 100%;
  min-height: 220rpx;
  background: #f7f7f7;
  border-radius: 10rpx;
  padding: 16rpx;
  margin-bottom: 16rpx;
  font-size: 26rpx;
}
.btn2 {
  margin-top: 16rpx;
  background: #fff;
  color: #409eff;
  border: 1px solid #409eff;
}
.row {
  display: flex;
  align-items: center;
  gap: 12rpx;
}
.input {
  flex: 1;
  height: 72rpx;
  padding: 0 20rpx;
  background: #f7f7f7;
  border-radius: 10rpx;
}
</style>
