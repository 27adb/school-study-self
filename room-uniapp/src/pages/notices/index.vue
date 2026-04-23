<script setup>
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { listNotice, getNotice } from '@/api/notice'
import { useUserStore } from '@/stores/modules/user'
import { goLogin } from '@/utils/auth'

const userStore = useUserStore()
const rows = ref([])
const loading = ref(false)
const detailShow = ref(false)
const detail = ref({})

function load() {
  loading.value = true
  listNotice({ pageNum: 1, pageSize: 30 })
    .then((res) => {
      rows.value = res?.data?.rows || []
    })
    .catch(() => {
      rows.value = []
      uni.showToast({ title: '公告加载失败，请检查网络', icon: 'none' })
    })
    .finally(() => {
      loading.value = false
    })
}

function openDetail(row) {
  getNotice(row.noticeId).then((res) => {
    detail.value = res?.data?.data || {}
    detailShow.value = true
  })
}

onShow(() => {
  if (!userStore.token) {
    goLogin()
    return
  }
  load()
})
</script>

<template>
  <view class="page">
    <view class="card">
      <text class="title">公告查看</text>
      <view v-if="loading" class="empty">加载中...</view>
      <view v-else-if="!rows.length" class="empty">暂无公告</view>
      <view v-for="n in rows" :key="n.noticeId" class="row" @click="openDetail(n)">
        <text class="pill">{{ n.noticeType == 1 ? '通知' : '公告' }}</text>
        <text class="name">{{ n.noticeTitle }}</text>
        <text class="time">{{ (n.createTime || '').split(' ')[0] }}</text>
      </view>
    </view>

    <view v-if="detailShow" class="mask" @click="detailShow = false">
      <view class="dialog" @click.stop>
        <text class="dlg-title">{{ detail.noticeTitle || '公告详情' }}</text>
        <text class="dlg-time">{{ detail.createTime || '' }}</text>
        <scroll-view scroll-y class="dlg-body">
          <rich-text :nodes="detail.noticeContent || ''" />
        </scroll-view>
        <view class="dlg-actions">
          <button size="mini" type="primary" @click="detailShow = false">关闭</button>
        </view>
      </view>
    </view>
  </view>
</template>

<style scoped>
.page{min-height:100vh;padding:20rpx;background:#f5f7fa}
.card{background:#fff;border-radius:12rpx;padding:20rpx}
.title{display:block;font-size:34rpx;font-weight:700;margin-bottom:12rpx}
.empty{text-align:center;color:#999;padding:24rpx}
.row{display:flex;align-items:center;gap:12rpx;padding:18rpx 0;border-bottom:1px solid #f2f2f2}
.pill{font-size:22rpx;color:#fff;background:#409eff;padding:4rpx 10rpx;border-radius:8rpx}
.name{flex:1;font-size:26rpx;color:#333;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.time{font-size:22rpx;color:#999}
.mask{position:fixed;inset:0;background:rgba(0,0,0,.45);display:flex;align-items:center;justify-content:center;z-index:1000}
.dialog{width:92%;max-height:85vh;background:#fff;border-radius:16rpx;padding:20rpx;display:flex;flex-direction:column}
.dlg-title{display:block;font-size:30rpx;font-weight:600;margin-bottom:8rpx}
.dlg-time{display:block;font-size:22rpx;color:#999;margin-bottom:10rpx}
.dlg-body{max-height:60vh}
.dlg-actions{display:flex;justify-content:flex-end;margin-top:12rpx}
</style>
