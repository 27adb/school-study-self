<script setup>
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { listReminders, readReminder } from '@/api/thesis'
import { goLogin } from '@/utils/auth'
import { useUserStore } from '@/stores/modules/user'

const userStore = useUserStore()
const rows = ref([])
const loading = ref(false)

function load() {
  loading.value = true
  listReminders()
    .then((res) => {
      const b = res.data
      if (b.code !== 200) return
      rows.value = b.data || []
    })
    .finally(() => {
      loading.value = false
    })
}

onShow(() => {
  if (!userStore.token) goLogin()
  else load()
})

function markRead(row) {
  readReminder(row.id).then((r) => {
    if (r.data.code === 200) {
      load()
    }
  })
}
</script>

<template>
  <view class="page">
    <view class="card">
      <text class="title">预约提醒</text>
      <text class="hint">系统在预约开始前会生成提醒（后台定时任务），到馆后请及时签到。</text>
      <view v-if="loading" class="empty">加载中...</view>
      <view v-else-if="!rows.length" class="empty">暂无未读提醒</view>
      <view v-for="r in rows" :key="r.id" class="item" @click="markRead(r)">
        <view class="top">
          <text class="t">{{ r.title }}</text>
          <text class="tag">点按已读</text>
        </view>
        <text class="body">{{ r.body }}</text>
        <text class="time">{{ r.fireTime }}</text>
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
.card {
  background: #fff;
  border-radius: 12rpx;
  padding: 24rpx;
}
.title {
  display: block;
  font-size: 34rpx;
  font-weight: 700;
  margin-bottom: 12rpx;
}
.hint {
  display: block;
  font-size: 24rpx;
  color: #909399;
  margin-bottom: 20rpx;
  line-height: 1.5;
}
.empty {
  text-align: center;
  color: #999;
  padding: 32rpx;
}
.item {
  padding: 20rpx 0;
  border-bottom: 1px solid #f0f0f0;
}
.top {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8rpx;
}
.t {
  font-weight: 600;
  font-size: 28rpx;
}
.tag {
  font-size: 22rpx;
  color: #409eff;
}
.body {
  display: block;
  font-size: 26rpx;
  color: #333;
  line-height: 1.5;
}
.time {
  display: block;
  font-size: 22rpx;
  color: #999;
  margin-top: 8rpx;
}
</style>
