<script setup>
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { getMedals, redeemMedal } from '@/api/thesis'
import { goLogin } from '@/utils/auth'
import { useUserStore } from '@/stores/modules/user'

const userStore = useUserStore()
const totalMinutes = ref(0)
const defs = ref([])
const mine = ref([])
const loading = ref(false)

function load() {
  loading.value = true
  getMedals()
    .then((res) => {
      const x = res.data
      if (x.code !== 200) return
      totalMinutes.value = x.totalMinutes != null ? Number(x.totalMinutes) : 0
      defs.value = x.definitions || []
      mine.value = x.mine || []
    })
    .finally(() => {
      loading.value = false
    })
}

onShow(() => {
  // 严格检查 token 和用户信息
  if (!userStore.token || !userStore.user || !userStore.user.userId) {
    if (userStore.token) userStore.removeToken()
    return goLogin()
  }
  load()
})

function mineRow(code) {
  return mine.value.find((m) => m.code === code)
}

function redeem(code) {
  redeemMedal(code).then((r) => {
    const b = r.data
    if (b.code === 200) {
      uni.showToast({ title: '已兑换优先预约权', icon: 'success' })
      load()
    } else {
      uni.showToast({ title: b.msg || '兑换失败', icon: 'none' })
    }
  })
}
</script>

<template>
  <view class="page">
    <view class="hero">
      <text class="big">{{ totalMinutes }}</text>
      <text class="sub">累计有效学习时长（分钟）</text>
      <text class="tip">解锁勋章后可兑换优先预约权（管理员需在参数中开启 medal.redeem.bypassBlacklist）。</text>
    </view>

    <view v-if="loading" class="empty">加载中...</view>
    <view v-else class="card">
      <text class="title">勋章说明与进度</text>
      <view v-for="d in defs" :key="d.code" class="row">
        <view class="left">
          <text class="name">{{ d.name }}</text>
          <text class="meta">需 {{ d.needMinutes }} 分钟 · {{ d.perkDesc || '权益见说明' }}</text>
        </view>
        <view class="right">
          <text v-if="mineRow(d.code)" class="ok">已解锁</text>
          <text v-else class="no">未解锁</text>
          <button
            v-if="mineRow(d.code) && mineRow(d.code).redeemed !== '1'"
            class="btn"
            size="mini"
            type="primary"
            @click="redeem(d.code)"
          >
            兑换权益
          </button>
          <text v-if="mineRow(d.code) && mineRow(d.code).redeemed === '1'" class="done">已兑换</text>
        </view>
      </view>
    </view>
  </view>
</template>

<style scoped>
.page {
  min-height: 100vh;
  padding: 20rpx;
  background: #f5f7fa;
}
.hero {
  background: linear-gradient(135deg, #409eff, #36cfc9);
  border-radius: 16rpx;
  padding: 32rpx;
  color: #fff;
  margin-bottom: 16rpx;
}
.big {
  font-size: 56rpx;
  font-weight: 800;
}
.sub {
  display: block;
  font-size: 26rpx;
  margin-top: 8rpx;
  opacity: 0.95;
}
.tip {
  display: block;
  font-size: 22rpx;
  margin-top: 16rpx;
  opacity: 0.9;
  line-height: 1.5;
}
.card {
  background: #fff;
  border-radius: 12rpx;
  padding: 24rpx;
}
.title {
  display: block;
  font-size: 32rpx;
  font-weight: 700;
  margin-bottom: 16rpx;
}
.row {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 16rpx;
  padding: 20rpx 0;
  border-bottom: 1px solid #f0f0f0;
}
.left {
  flex: 1;
}
.name {
  display: block;
  font-size: 28rpx;
  font-weight: 600;
}
.meta {
  display: block;
  font-size: 22rpx;
  color: #666;
  margin-top: 8rpx;
  line-height: 1.4;
}
.right {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 8rpx;
}
.ok {
  color: #67c23a;
  font-size: 24rpx;
}
.no {
  color: #909399;
  font-size: 24rpx;
}
.done {
  color: #e6a23c;
  font-size: 24rpx;
}
.btn {
  margin: 0;
}
.empty {
  text-align: center;
  color: #999;
  padding: 40rpx;
}
</style>
