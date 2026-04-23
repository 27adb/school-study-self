<script setup>
import { ref } from 'vue'
import { onLoad, onShow } from '@dcloudio/uni-app'
import { getInfo } from '@/api/login'
import { addFeedback, listFeedback } from '@/api/assistant'
import { submitRepair } from '@/api/thesis'
import { goLogin, isAuthExpiredResponse } from '@/utils/auth'
import { useUserStore } from '@/stores/modules/user'

const userStore = useUserStore()
const loading = ref(false)
const feedbackList = ref([])

const form = ref({ type: '建议', content: '', quietScore: 4, lightingScore: 4, appealEvidence: '' })
const types = ['建议', '申诉', '故障反馈']
const scoreRange = [1, 2, 3, 4, 5]
const submitting = ref(false)

function onTypeChange(e) {
  const i = Number(e.detail?.value)
  form.value.type = types[i] || '建议'
}

function onQuietScoreChange(e) {
  const i = Number(e.detail?.value)
  form.value.quietScore = scoreRange[i] || 4
}

function onLightingScoreChange(e) {
  const i = Number(e.detail?.value)
  form.value.lightingScore = scoreRange[i] || 4
}

function loadMyFeedback() {
  const userId = userStore.user?.userId
  if (!userId) return
  loading.value = true
  listFeedback({ userId, pageNum: 1, pageSize: 50 })
    .then((res) => {
      feedbackList.value = res?.data?.rows || []
    })
    .finally(() => {
      loading.value = false
    })
}

onLoad((options) => {
  // 允许从“申请解锁/反馈申诉”入口带参，自动预填
  const prefillType = options?.prefillType
  const prefillContent = options?.prefillContent
  if (prefillType && types.includes(prefillType)) form.value.type = prefillType
  if (prefillContent) form.value.content = decodeURIComponent(prefillContent)
})

onShow(() => {
  if (!userStore.token) {
    goLogin()
    return
  }

  const hasUserId = !!userStore.user?.userId
  if (hasUserId) {
    loadMyFeedback()
    return
  }

  // 兼容“从非我的页面直达”的情况
  getInfo().then((res) => {
    if (res.data.code !== 200) {
      if (isAuthExpiredResponse(res)) {
        uni.showToast({ title: '登录状态已过期', icon: 'none' })
        goLogin()
      } else {
        uni.showToast({ title: res?.data?.msg || '网络异常，请稍后重试', icon: 'none' })
      }
      return
    }
    userStore.setUser(res.data.user)
    userStore.setRoles(res.data.roles || [])
    loadMyFeedback()
  }).catch(() => {
    uni.showToast({ title: '网络异常，请稍后重试', icon: 'none' })
  })
})

function submit() {
  if (submitting.value) return
  if (!form.value.content) {
    uni.showToast({ title: '请填写内容', icon: 'none' })
    return
  }
  submitting.value = true
  const payload = {
    feedbackType: form.value.type,
    content: form.value.content,
    status: '待处理',
    quietScore: form.value.quietScore,
    lightingScore: form.value.lightingScore,
  }
  if (form.value.type === '申诉' && form.value.appealEvidence.trim()) {
    payload.appealEvidence = form.value.appealEvidence.trim()
  }
  const submitTask =
    form.value.type === '故障反馈'
      ? submitRepair({
          content: form.value.content,
          remark: form.value.appealEvidence.trim() || '',
          quietScore: form.value.quietScore,
          lightingScore: form.value.lightingScore,
        })
      : addFeedback(payload)

  submitTask
    .then((res) => {
      if (res.data.code !== 200) {
        uni.showToast({ title: res.data.msg || '提交失败', icon: 'none' })
        return
      }
      uni.showToast({ title: form.value.type === '故障反馈' ? '工单已提交' : '提交成功', icon: 'success' })
      form.value.content = ''
      form.value.appealEvidence = ''
      if (form.value.type !== '故障反馈') {
        loadMyFeedback()
      }
    })
    .catch(() => {
      uni.showToast({ title: '提交失败，请检查网络或联系管理员', icon: 'none' })
    })
    .finally(() => {
      submitting.value = false
    })
}
</script>

<template>
  <view class="page">
    <view class="card">
      <text class="title">接收反馈</text>
      <view v-if="loading" class="loading">加载中...</view>
      <view v-else>
        <view v-if="feedbackList.length">
          <view v-for="f in feedbackList" :key="f.id" class="fb-item">
            <view class="fb-top">
              <text class="type">[{{ f.feedbackType }}]</text>
              <text class="status">状态：{{ f.status }}</text>
            </view>
            <text class="meta">{{ f.createTime }}</text>
            <text v-if="f.quietScore || f.lightingScore" class="scores"
              >安静 {{ f.quietScore || '-' }} · 照明 {{ f.lightingScore || '-' }}</text
            >
            <text class="content">{{ f.content }}</text>
            <text v-if="f.appealEvidence" class="evidence">凭证：{{ f.appealEvidence }}</text>
            <view v-if="f.handleRemark" class="handle">
              <text class="handle-label">处理备注：</text>{{ f.handleRemark }}
            </view>
          </view>
        </view>
        <view v-else class="empty">暂无反馈记录</view>
      </view>
    </view>

    <view class="card submit-card">
      <text class="subtitle">提交新的反馈</text>
      <picker :range="types" @change="onTypeChange">
        <view class="picker">类型：{{ form.type }}</view>
      </picker>
      <view class="score-row">
        <text>安静度</text>
        <picker mode="selector" :range="scoreRange" :value="form.quietScore - 1" @change="onQuietScoreChange">
          <view class="mini">{{ form.quietScore }} 分</view>
        </picker>
        <text>照明</text>
        <picker mode="selector" :range="scoreRange" :value="form.lightingScore - 1" @change="onLightingScoreChange">
          <view class="mini">{{ form.lightingScore }} 分</view>
        </picker>
      </view>
      <textarea v-model="form.content" class="ta" placeholder="请输入建议、申诉内容或故障信息" />
      <input
        v-if="form.type === '申诉'"
        v-model="form.appealEvidence"
        class="input"
        placeholder="申诉凭证：图片链接或说明（可先上传图床后粘贴 URL）"
      />
      <button type="primary" :loading="submitting" :disabled="submitting" @click="submit">
        {{ submitting ? '提交中...' : (form.type === '故障反馈' ? '提交工单' : '提交') }}
      </button>
    </view>
  </view>
</template>

<style scoped>
.page{min-height:100vh;padding:20rpx;background:#f5f7fa}
.card{background:#fff;border-radius:12rpx;padding:24rpx;margin-bottom:16rpx}
.title{display:block;font-size:34rpx;font-weight:700;margin-bottom:16rpx}
.subtitle{display:block;font-size:32rpx;font-weight:600;margin-bottom:16rpx;color:#333}
.loading{text-align:center;color:#999;padding:16rpx 0}
.empty{text-align:center;color:#999;padding:20rpx 0}
.picker{height:72rpx;line-height:72rpx;padding:0 20rpx;background:#f7f7f7;border-radius:10rpx;margin-bottom:12rpx}
.ta{width:100%;height:260rpx;background:#f7f7f7;border-radius:10rpx;padding:16rpx;margin-bottom:16rpx}
.fb-item{padding:14rpx 0;border-bottom:1px solid #f1f1f1}
.fb-item:last-child{border-bottom:none}
.fb-top{display:flex;justify-content:space-between;align-items:center;gap:12rpx;margin-bottom:8rpx}
.type{font-size:26rpx;color:#409eff}
.status{font-size:24rpx;color:#666;white-space:nowrap}
.meta{display:block;font-size:22rpx;color:#999;margin-bottom:8rpx}
.scores{display:block;font-size:24rpx;color:#67c23a;margin-bottom:6rpx}
.content{display:block;font-size:26rpx;color:#333;line-height:1.6;word-break:break-word}
.evidence{display:block;font-size:24rpx;color:#666;margin-top:8rpx;word-break:break-all}
.score-row{display:flex;align-items:center;gap:12rpx;margin-bottom:12rpx;font-size:24rpx;flex-wrap:wrap}
.mini{padding:8rpx 16rpx;background:#f0f9eb;border-radius:8rpx;color:#67c23a}
.input{height:72rpx;padding:0 16rpx;margin-bottom:12rpx;background:#f7f7f7;border-radius:10rpx;font-size:26rpx}
.handle{margin-top:10rpx;font-size:24rpx;color:#444}
.handle-label{font-weight:600}
.submit-card{margin-top:0}
</style>
