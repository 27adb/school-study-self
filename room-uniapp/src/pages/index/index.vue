<script setup>
import { ref, watch, onMounted, onUnmounted } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { listReservation } from '@/api/reservation'
import { baseURL } from '@/utils/request'
import { getInfo } from '@/api/login'
import { goLogin, isAuthExpiredResponse } from '@/utils/auth'
import { useUserStore } from '@/stores/modules/user'
import MyReservation from '@/components/MyReservation.vue'
import Notice from '@/components/Notice.vue'

const userStore = useUserStore()
const defaultStatus = ref('normal')
const defaultNumber = ref(0)
const startTime = ref('')
const endTime = ref('')
const remainingTime = ref('')
const banDays = ref(7)
const remark = ref('')
const canUnban = ref(false)
const violationWarnShown = ref(false)

// 轮播图配置 - 使用渐变色背景代替图片
const carouselSlides = [
  { background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)', title: '欢迎来到自习室', subtitle: '安静学习 高效成长' },
  { background: 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)', title: '预约便捷', subtitle: '随时随地 想约就约' },
  { background: 'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)', title: '环境优美', subtitle: '舒适环境 助力学习' }
]
const currentSlide = ref(0)
let autoplayTimer = null

// 自动播放
function startAutoplay() {
  if (autoplayTimer) clearInterval(autoplayTimer)
  autoplayTimer = setInterval(() => {
    currentSlide.value = (currentSlide.value + 1) % carouselSlides.length
  }, 4000)
}

function stopAutoplay() {
  if (autoplayTimer) {
    clearInterval(autoplayTimer)
    autoplayTimer = null
  }
}

function getReservation() {
  listReservation({ userId: userStore.user.userId, pageNum: 1, pageSize: 200 }).then((res) => {
    const rows = res?.data?.rows || []
    const violationRows = rows.filter((item) => {
      const isMarked = item.status === '违约' || item.reservationStatus === '违约中'
      const inAt = item.reservationInTime ? new Date(String(item.reservationInTime).replace(/-/g, '/')).getTime() : NaN
      const outAt = item.reservationOutTime ? new Date(String(item.reservationOutTime).replace(/-/g, '/')).getTime() : NaN
      const noShow = item.reservationStatus === '已预约' && Number.isFinite(inAt) && Date.now() > inAt + 15 * 60 * 1000
      const overtime = item.reservationStatus === '使用中' && Number.isFinite(outAt) && Date.now() > outAt
      return isMarked || noShow || overtime
    })
    const total = violationRows.length
    defaultNumber.value = total
    if (total >= 3 && violationRows.length) {
      defaultStatus.value = 'banned'
      const latest = [...violationRows].sort((a, b) => new Date(b.reservationOutTime || 0) - new Date(a.reservationOutTime || 0))[0]
      const startDate = new Date(latest.reservationOutTime)
      const endDate = new Date(startDate)
      endDate.setDate(startDate.getDate() + banDays.value)
      startTime.value = formatDate(startDate)
      endTime.value = formatDate(endDate)
      updateRemainingTime()
      remark.value = latest.remark || ''
      if (!violationWarnShown.value) {
        violationWarnShown.value = true
        uni.showModal({
          title: '违约提醒',
          content: `你当前累计违约 ${total} 次，已进入禁约状态，请联系管理员处理。\n原因：${remark.value || '未按时签到/签退'}`,
          showCancel: false,
          confirmText: '我知道了',
        })
      }
    } else {
      defaultStatus.value = 'normal'
      startTime.value = ''
      endTime.value = ''
      remainingTime.value = ''
      remark.value = ''
      canUnban.value = false
      violationWarnShown.value = false
    }
  })
}

function formatDate(date) {
  const y = date.getFullYear()
  const m = String(date.getMonth() + 1).padStart(2, '0')
  const d = String(date.getDate()).padStart(2, '0')
  const h = String(date.getHours()).padStart(2, '0')
  const mm = String(date.getMinutes()).padStart(2, '0')
  const s = String(date.getSeconds()).padStart(2, '0')
  return `${y}-${m}-${d} ${h}:${mm}:${s}`
}

watch(() => userStore.user?.userId, (id) => { if (id) getReservation() }, { immediate: true })

// 监听预约刷新事件
onMounted(() => {
  uni.$on('refreshReservation', () => {
    console.log('收到预约刷新事件')
    getReservation()
  })
})

// 页面卸载时移除监听
onUnmounted(() => {
  uni.$off('refreshReservation')
})

let timer = null
function updateRemainingTime() {
  if (!endTime.value) return
  const diff = new Date(endTime.value).getTime() - Date.now()
  if (diff > 0) {
    const days = Math.floor(diff / (1000 * 60 * 60 * 24))
    const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60))
    const mins = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60))
    const secs = Math.floor((diff % (1000 * 60)) / 1000)
    remainingTime.value = `${days}天${hours}小时${mins}分${secs}秒`
  } else {
    remainingTime.value = '0天0小时0分0秒'
  }
  canUnban.value = false
}

onMounted(() => { 
  timer = setInterval(updateRemainingTime, 1000)
  startAutoplay()
})
onUnmounted(() => { 
  if (timer) clearInterval(timer)
  stopAutoplay()
})

function cancelBan() {
  uni.showModal({
    title: '禁约处理',
    content: '当前为累计违约禁约状态，请联系管理员处理。',
    showCancel: false,
  })
}

function avatarSrc() {
  const a = userStore.user?.avatar
  // 使用 base64 编码的默认头像（灰色人像图标）
  const defaultAvatar = 'data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxMDAiIGhlaWdodD0iMTAwIiB2aWV3Qm94PSIwIDAgMTAwIDEwMCI+PGNpcmNsZSBjeD0iNTAiIGN5PSI1MCIgcj0iNTAiIGZpbGw9IiNkOWQ5ZDkiLz48Y2lyY2xlIGN4PSI1MCIgY3k9IjM1IiByPSIyMCIgZmlsbD0iI2ZmZiIvPjxwYXRoIGQ9Ik01MCA1NSBjLTE1IDAtMzUgOC0zNSAyMHYxNWg3MHYtMTVjMC0xMi0yMC0yMC0zNS0yMHoiIGZpbGw9IiNmZmYiLz48L3N2Zz4='
  return a ? baseURL + a : defaultAvatar
}

function goPage(url) {
  uni.navigateTo({ url })
}

onShow(() => {
  if (!userStore.token) {
    goLogin()
    return
  }
  getInfo().then((res) => {
    if (res.data.code === 200) {
      userStore.setUser(res.data.user)
      userStore.setRoles(res.data.roles || [])
      getReservation()
    } else if (isAuthExpiredResponse(res)) {
      uni.showToast({ title: '登录状态已过期', icon: 'none' })
      goLogin()
    }
  }).catch(() => {
    uni.showToast({ title: '网络异常，请稍后重试', icon: 'none' })
  })
})
</script>

<template>
  <view class="index">
    <scroll-view scroll-y class="scroll">
      <view class="my-info">
        <view class="info">
          <image class="avatar" :src="avatarSrc()" mode="aspectFill" />
          <view class="name">
            <text class="nick">你好，{{ userStore.user.nickName }}</text>
            <text class="sub">学号：{{ userStore.user.userName }}</text>
          </view>
        </view>
        <view class="status">
          <view class="box">
            <text :class="['num', defaultNumber >= 3 ? 'bad' : '']">{{ defaultNumber }}</text>
            <text class="label">违约次数</text>
          </view>
          <view class="box">
            <text :class="['num', defaultStatus !== 'normal' ? 'bad' : '']">{{ defaultStatus === 'normal' ? '正常' : '禁约' }}</text>
            <text class="label">预约状态</text>
          </view>
        </view>
        <view v-if="defaultStatus === 'banned'" class="alert">
          <text class="alert-line"><text class="b">开始：</text>{{ startTime }}</text>
          <text class="alert-line"><text class="b">结束：</text>{{ endTime }}</text>
          <text class="alert-line"><text class="b">剩余：</text>{{ remainingTime }}</text>
          <text class="alert-line"><text class="b">原因：</text>{{ remark }}</text>
        </view>
        <button v-if="defaultStatus === 'banned'" class="warn-btn" type="warn" @click="cancelBan">联系管理员处理</button>
      </view>

      <!-- 渐变背景轮播 -->
      <view class="carousel" @touchstart="stopAutoplay" @touchend="startAutoplay">
        <view 
          v-for="(slide, i) in carouselSlides" 
          :key="i" 
          class="carousel-slide"
          :class="{ active: i === currentSlide }"
          :style="{ background: slide.background }"
        >
          <view class="slide-content">
            <text class="slide-title">{{ slide.title }}</text>
            <text class="slide-subtitle">{{ slide.subtitle }}</text>
          </view>
        </view>
        <!-- 指示器 -->
        <view class="carousel-indicators">
          <view 
            v-for="(slide, i) in carouselSlides" 
            :key="i" 
            class="indicator"
            :class="{ active: i === currentSlide }"
            @click="currentSlide = i"
          />
        </view>
      </view>

      <view class="quick">
        <view class="q" @click="goPage('/pages/courses/index')">课表</view>
        <view class="q" @click="goPage('/pages/reminders/index')">提醒</view>
        <view class="q" @click="goPage('/pages/medals/index')">勋章</view>
        <view class="q" @click="goPage('/pages/share/index')">分享</view>
      </view>

      <MyReservation />
      <Notice />
      <view class="bottom-space" />
    </scroll-view>
  </view>
</template>

<style lang="scss" scoped>
.index{height:100vh;display:flex;flex-direction:column}.scroll{flex:1;height:0;padding:10rpx}.quick{display:flex;justify-content:space-between;gap:12rpx;margin-bottom:16rpx}.quick .q{flex:1;text-align:center;padding:22rpx 0;background:#fff;border-radius:12rpx;font-size:26rpx;color:#409eff;box-shadow:0 4rpx 10rpx rgba(0,0,0,.06)}.my-info{padding:32rpx;color:#fff;background:linear-gradient(135deg,#409eff,#36cfc9);border-radius:20rpx;box-shadow:0 8rpx 10rpx rgba(0,0,0,.12);margin-bottom:20rpx}.info{display:flex;align-items:center;gap:20rpx}.avatar{width:100rpx;height:100rpx;border-radius:50%;background:#fff}.name{display:flex;flex-direction:column;gap:8rpx}.nick{font-size:36rpx;font-weight:700}.sub{font-size:28rpx}.status{display:flex;justify-content:space-around;margin-top:20rpx;padding:0 20rpx}.box{display:flex;flex-direction:column;align-items:center;font-size:24rpx}.num{font-size:40rpx;font-weight:700}.num.bad{color:#f56c6c}.alert{margin-top:20rpx;padding:16rpx;background:rgba(255,255,255,.2);border-radius:12rpx;display:flex;flex-direction:column;gap:8rpx}.alert-line{font-size:24rpx}.b{font-weight:700}.warn-btn{margin-top:20rpx;width:100%;border-radius:44rpx}.carousel{height:320rpx;border-radius:20rpx;overflow:hidden;margin-bottom:20rpx;box-shadow:0 8rpx 10rpx rgba(0,0,0,.08);position:relative}.carousel-slide{position:absolute;inset:0;opacity:0;transition:opacity 0.5s ease-in-out;display:flex;align-items:center;justify-content:center;padding:40rpx}.carousel-slide.active{opacity:1;z-index:1}.slide-content{text-align:center;color:#fff}.slide-title{display:block;font-size:48rpx;font-weight:700;margin-bottom:16rpx;text-shadow:0 2rpx 10rpx rgba(0,0,0,.2)}.slide-subtitle{display:block;font-size:28rpx;text-shadow:0 2rpx 10rpx rgba(0,0,0,.2)}.carousel-indicators{position:absolute;bottom:20rpx;left:0;right:0;display:flex;justify-content:center;gap:12rpx;z-index:2}.indicator{width:16rpx;height:16rpx;border-radius:50%;background:rgba(255,255,255,.4);cursor:pointer;transition:all 0.3s}.indicator.active{background:#fff;transform:scale(1.2)}.bottom-space{height:40rpx}
</style>
