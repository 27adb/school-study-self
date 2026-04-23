<script setup>
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { listMyCourses, addMyCourse, delMyCourse } from '@/api/thesis'
import { goLogin } from '@/utils/auth'
import { useUserStore } from '@/stores/modules/user'

const userStore = useUserStore()
const rows = ref([])
const weekLabels = ['周一', '周二', '周三', '周四', '周五', '周六', '周日']
const form = ref({ weekDay: 1, courseName: '', startTime: '08:00', endTime: '10:00' })

function load() {
  listMyCourses().then((res) => {
    const b = res.data
    if (b.code !== 200) return
    rows.value = b.data || []
  })
}

onShow(() => {
  if (!userStore.token) goLogin()
  else load()
})

function onWeekChange(e) {
  form.value.weekDay = Number(e.detail.value) + 1
}

function submitAdd() {
  if (!form.value.courseName.trim()) return uni.showToast({ title: '请填写课程名', icon: 'none' })
  const st = form.value.startTime.length === 5 ? `${form.value.startTime}:00` : form.value.startTime
  const et = form.value.endTime.length === 5 ? `${form.value.endTime}:00` : form.value.endTime
  addMyCourse({
    weekDay: form.value.weekDay,
    courseName: form.value.courseName.trim(),
    startTime: st,
    endTime: et,
  }).then((r) => {
    const b = r.data
    if (b.code === 200) {
      uni.showToast({ title: '已保存', icon: 'success' })
      form.value.courseName = ''
      load()
    } else {
      uni.showToast({ title: b.msg || '失败', icon: 'none' })
    }
  })
}

function remove(id) {
  uni.showModal({
    title: '确认删除？',
    success: (m) => {
      if (!m.confirm) return
      delMyCourse(id).then((r) => {
        if (r.data.code === 200) {
          uni.showToast({ title: '已删除', icon: 'none' })
          load()
        }
      })
    },
  })
}
</script>

<template>
  <view class="page">
    <view class="card">
      <text class="title">我的课表</text>
      <text class="hint">预约时将自动校验与课程时间是否冲突（同一天、时段重叠即拦截）。</text>
      <picker mode="selector" :range="weekLabels" :value="form.weekDay - 1" @change="onWeekChange">
        <view class="row">星期：{{ weekLabels[form.weekDay - 1] }}</view>
      </picker>
      <input v-model="form.courseName" class="input" placeholder="课程名称" />
      <view class="time-row">
        <text>起</text>
        <input v-model="form.startTime" class="input sm" placeholder="08:00" />
        <text>止</text>
        <input v-model="form.endTime" class="input sm" placeholder="10:00" />
      </view>
      <button type="primary" @click="submitAdd">添加课程</button>
    </view>

    <view class="card">
      <text class="sub">已维护课程</text>
      <view v-if="!rows.length" class="empty">暂无记录</view>
      <view v-for="c in rows" :key="c.id" class="item">
        <view class="top">
          <text class="name">{{ c.courseName }}</text>
          <text class="del" @click="remove(c.id)">删除</text>
        </view>
        <text class="meta">{{ weekLabels[(c.weekDay || 1) - 1] }} {{ c.startTime }} ~ {{ c.endTime }}</text>
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
  margin-bottom: 16rpx;
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
  margin-bottom: 16rpx;
  line-height: 1.5;
}
.row {
  padding: 20rpx;
  background: #f7f7f7;
  border-radius: 10rpx;
  margin-bottom: 12rpx;
}
.input {
  height: 76rpx;
  padding: 0 20rpx;
  margin-bottom: 12rpx;
  background: #f7f7f7;
  border-radius: 10rpx;
}
.time-row {
  display: flex;
  align-items: center;
  gap: 12rpx;
  margin-bottom: 16rpx;
  font-size: 26rpx;
}
.input.sm {
  flex: 1;
  margin-bottom: 0;
}
.sub {
  display: block;
  font-size: 30rpx;
  font-weight: 600;
  margin-bottom: 12rpx;
}
.empty {
  text-align: center;
  color: #999;
  padding: 20rpx;
}
.item {
  padding: 16rpx 0;
  border-bottom: 1px solid #f0f0f0;
}
.top {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.name {
  font-weight: 600;
  font-size: 28rpx;
}
.del {
  font-size: 24rpx;
  color: #f56c6c;
}
.meta {
  font-size: 24rpx;
  color: #666;
  margin-top: 8rpx;
}
</style>
