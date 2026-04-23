<script setup>
import { ref } from 'vue'
import { listNotice, getNotice } from '@/api/notice'

const noticeList = ref([])
const noticeTotal = ref(0)
const noticeNum = ref(1)
const noticeSize = ref(10)
const noticeLoading = ref(false)

function getNoticeList() {
  noticeLoading.value = true
  listNotice({
    pageNum: noticeNum.value,
    pageSize: noticeSize.value,
  }).then((res) => {
    noticeList.value = res.data.rows
    noticeTotal.value = res.data.total
    noticeLoading.value = false
  })
}

getNoticeList()

const noticeDrawer = ref(false)
const noticeDetail = ref({})

function getNoticeDetail(row) {
  getNotice(row.noticeId).then((res) => {
    noticeDetail.value = res.data.data
    noticeDrawer.value = true
  })
}

function prevPage() {
  if (noticeNum.value <= 1) return
  noticeNum.value -= 1
  getNoticeList()
}

function nextPage() {
  const maxPage = Math.ceil(noticeTotal.value / noticeSize.value) || 1
  if (noticeNum.value >= maxPage) return
  noticeNum.value += 1
  getNoticeList()
}
</script>

<template>
  <view class="notice">
    <text class="title">通知公告</text>
    <view v-if="noticeLoading" class="loading">加载中...</view>
    <view
      v-for="row in noticeList"
      :key="row.noticeId"
      class="row"
      @click="getNoticeDetail(row)"
    >
      <view class="type">
        <text v-if="row.noticeType == 1" class="pill warn">通知</text>
        <text v-if="row.noticeType == 2" class="pill ok">公告</text>
      </view>
      <text class="cell title-cell">{{ row.noticeTitle }}</text>
      <text class="cell date">{{ row.createTime.split(' ')[0] }}</text>
    </view>
    <view v-if="noticeTotal" class="pager">
      <button size="mini" :disabled="noticeNum <= 1" @click="prevPage">上一页</button>
      <text class="pager-info">{{ noticeNum }} / {{ Math.ceil(noticeTotal / noticeSize) || 1 }}</text>
      <button
        size="mini"
        :disabled="noticeNum >= Math.ceil(noticeTotal / noticeSize)"
        @click="nextPage"
      >
        下一页
      </button>
    </view>

    <view v-if="noticeDrawer" class="drawer-mask" @click="noticeDrawer = false">
      <view class="drawer" @click.stop>
        <view class="drawer-head">
          <text class="drawer-title">
            {{ (noticeDetail.noticeType == 1 ? '通知' : '公告') + '详情' }}
          </text>
          <text class="close" @click="noticeDrawer = false">关闭</text>
        </view>
        <scroll-view scroll-y class="drawer-body">
          <view class="info">
            <text class="line">标题：<text class="bold">{{ noticeDetail.noticeTitle }}</text></text>
            <text class="line">发布者：{{ noticeDetail.createBy }}</text>
            <text class="line">发布时间：{{ noticeDetail.createTime }}</text>
            <text class="line">修改时间：{{ noticeDetail.updateTime }}</text>
          </view>
          <rich-text class="content" :nodes="noticeDetail.noticeContent" />
        </scroll-view>
      </view>
    </view>
  </view>
</template>

<style lang="scss" scoped>
.notice {
  margin-top: 24rpx;

  > .title {
    display: block;
    margin: 20rpx 0;
    color: #555;
    font-size: 40rpx;
    font-weight: 600;
    text-align: center;
  }

  .loading {
    text-align: center;
    color: #999;
    padding: 24rpx;
  }

  .row {
    display: flex;
    align-items: center;
    gap: 16rpx;
    padding: 20rpx 16rpx;
    background: #fff;
    border-bottom: 1px solid #f0f0f0;
  }

  .type {
    width: 120rpx;
    flex-shrink: 0;
  }

  .pill {
    padding: 4rpx 12rpx;
    border-radius: 8rpx;
    font-size: 22rpx;
    color: #fff;
  }

  .pill.warn {
    background: #e6a23c;
  }

  .pill.ok {
    background: #67c23a;
  }

  .cell {
    font-size: 26rpx;
    color: #333;
  }

  .title-cell {
    flex: 1;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .date {
    width: 180rpx;
    flex-shrink: 0;
    text-align: right;
    color: #999;
    font-size: 24rpx;
  }

  .pager {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 24rpx;
    padding: 24rpx 0;
    background: #fff;
  }

  .pager-info {
    font-size: 26rpx;
    color: #666;
  }

  .drawer-mask {
    position: fixed;
    left: 0;
    right: 0;
    top: 0;
    bottom: 0;
    background: rgba(0, 0, 0, 0.45);
    z-index: 999;
  }

  .drawer {
    position: absolute;
    left: 0;
    top: 0;
    bottom: 0;
    width: 100%;
    max-width: 100%;
    background: #fff;
    display: flex;
    flex-direction: column;
  }

  .drawer-head {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 24rpx;
    border-bottom: 1px solid #eee;
  }

  .drawer-title {
    font-size: 32rpx;
    font-weight: 600;
    color: #333;
  }

  .close {
    color: #409eff;
    font-size: 28rpx;
  }

  .drawer-body {
    flex: 1;
    height: 0;
    padding: 24rpx;
  }

  .info {
    margin-bottom: 24rpx;
    padding: 20rpx;
    background: #f5f5f5;
    border-radius: 10rpx;
    display: flex;
    flex-direction: column;
    gap: 12rpx;
  }

  .line {
    font-size: 28rpx;
    color: #555;
  }

  .bold {
    font-weight: 600;
  }

  .content {
    font-size: 28rpx;
    color: #333;
    line-height: 1.6;
  }
}
</style>
