<script setup>
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { login, getInfo } from '@/api/login'
import { sendCampusCode, loginByCampusSms } from '@/api/campus'
import { useUserStore } from '@/stores/modules/user'

const userStore = useUserStore()
const loading = ref(false)
const loginForm = ref({ username: '', password: '' })
const smsForm = ref({ campusAccount: '', smsCode: '' })
const smsHint = ref('')

function resolveToken(body) {
  if (!body) return ''
  return body.token || body.access_token || body.accessToken || body?.data?.token || ''
}

onShow(() => {
  // 登录页不再自动跳首页，避免因陈旧 token 产生循环跳转
})

function handleLogin() {
  if (!loginForm.value.username) {
    uni.showToast({ title: '请输入您的账号', icon: 'none' })
    return
  }
  if (!loginForm.value.password) {
    uni.showToast({ title: '请输入您的密码', icon: 'none' })
    return
  }
  loading.value = true
  login(loginForm.value.username, loginForm.value.password)
    .then((res) => {
      if (res.data.code === 200) {
        const token = resolveToken(res.data)
        if (!token) {
          uni.showToast({ title: '登录成功但未获取到令牌', icon: 'none' })
          return
        }
        userStore.setToken(token)
        getInfo()
          .then((infoRes) => {
            if (infoRes.data.code === 200) {
              userStore.setUser(infoRes.data.user || {})
              userStore.setRoles(infoRes.data.roles || [])
              uni.showToast({ title: '登录成功', icon: 'success' })
              uni.switchTab({ url: '/pages/index/index' })
            } else {
              uni.showToast({ title: infoRes.data.msg || '获取用户信息失败，请重试', icon: 'none' })
            }
          })
          .catch(() => {
            uni.showToast({ title: '网络异常，暂无法获取用户信息', icon: 'none' })
          })
          .finally(() => {
            loading.value = false
        })
      } else {
        uni.showToast({ title: res.data.msg || '登录失败', icon: 'none' })
        loading.value = false
      }
    })
    .catch(() => {
      uni.showToast({ title: '网络异常，请稍后重试', icon: 'none' })
      loading.value = false
    })
}

function sendSms() {
  if (!smsForm.value.campusAccount) {
    uni.showToast({ title: '请填写学号', icon: 'none' })
    return
  }
  sendCampusCode(smsForm.value.campusAccount).then((res) => {
    if (res.data && res.data.code === 200) {
      smsHint.value = res.data.demoCode ? `演示验证码：${res.data.demoCode}` : '验证码已下发'
      uni.showToast({ title: '已发送', icon: 'none' })
    } else {
      uni.showToast({ title: (res.data && res.data.msg) || '发送失败', icon: 'none' })
    }
  })
}

function handleSmsLogin() {
  if (!smsForm.value.campusAccount || !smsForm.value.smsCode) {
    uni.showToast({ title: '学号与验证码必填', icon: 'none' })
    return
  }
  loading.value = true
  loginByCampusSms(smsForm.value.campusAccount, smsForm.value.smsCode)
    .then((res) => {
      if (res.data.code === 200) {
        const token = resolveToken(res.data)
        if (!token) {
          uni.showToast({ title: '登录成功但未获取到令牌', icon: 'none' })
          loading.value = false
          return
        }
        userStore.setToken(token)
        getInfo()
          .then((infoRes) => {
            if (infoRes.data.code === 200) {
              userStore.setUser(infoRes.data.user || {})
              userStore.setRoles(infoRes.data.roles || [])
              uni.showToast({ title: '登录成功', icon: 'success' })
              uni.switchTab({ url: '/pages/index/index' })
            } else {
              uni.showToast({ title: infoRes.data.msg || '获取用户信息失败，请重试', icon: 'none' })
            }
          })
          .catch(() => {
            uni.showToast({ title: '网络异常，暂无法获取用户信息', icon: 'none' })
          })
          .finally(() => {
            loading.value = false
          })
      } else {
        uni.showToast({ title: res.data.msg || '登录失败', icon: 'none' })
        loading.value = false
      }
    })
    .catch(() => {
      uni.showToast({ title: '网络异常，请稍后重试', icon: 'none' })
      loading.value = false
    })
}
</script>

<template>
  <view class="login">
    <view class="login-form">
      <view class="title">
        <image class="logo" src="/static/logo/logo.png" mode="aspectFit" />
        <text>自习室预约平台</text>
      </view>
      <input v-model="loginForm.username" class="input" type="text" placeholder="学号" />
      <input
        v-model="loginForm.password"
        class="input"
        type="password"
        password
        placeholder="密码"
        confirm-type="done"
        @confirm="handleLogin"
      />
      <button class="btn" type="primary" :loading="loading" :disabled="loading" @click="handleLogin">
        {{ loading ? '登录中...' : '登录' }}
      </button>
      <view class="extra">
        <text class="link" @click="uni.navigateTo({ url: '/pages/register/register' })">没有账号？去注册</text>
      </view>
      <view class="divider"><text>校园验证码登录（JWT）</text></view>
      <input v-model="smsForm.campusAccount" class="input" type="text" placeholder="学号（须已注册）" />
      <view class="sms-row">
        <input v-model="smsForm.smsCode" class="input sms-input" type="number" placeholder="短信码" />
        <button class="sms-btn" size="mini" type="default" @click="sendSms">获取验证码</button>
      </view>
      <text v-if="smsHint" class="hint">{{ smsHint }}</text>
      <button class="btn secondary" type="default" :loading="loading" @click="handleSmsLogin">验证码登录</button>
    </view>
  </view>
</template>

<style lang="scss" scoped>
.login { display:flex;align-items:center;justify-content:center;min-height:100vh;padding:40rpx;background:linear-gradient(160deg,#409eff 0%,#36cfc9 100%); }
.login-form { width:100%;max-width:680rpx;padding:48rpx 40rpx 32rpx;background:rgba(255,255,255,.92);border-radius:16rpx; }
.title { display:flex;align-items:center;justify-content:center;gap:16rpx;margin-bottom:40rpx;color:#707070;font-size:40rpx;font-weight:600; }
.logo { width:48rpx;height:48rpx; }
.input { height:88rpx;margin-bottom:24rpx;padding:0 28rpx;font-size:28rpx;background:#fff;border:1px solid #e5e5e5;border-radius:44rpx; }
.btn { margin-top:16rpx;height:88rpx;line-height:88rpx;border-radius:44rpx;font-size:30rpx; }
.extra { margin-top:20rpx;text-align:center; }
.link { font-size:26rpx;color:#409eff; }
.divider { margin:28rpx 0 20rpx;text-align:center;font-size:24rpx;color:#999; }
.sms-row { display:flex;align-items:center;gap:12rpx;margin-bottom:12rpx; }
.sms-input { flex:1;margin-bottom:0; }
.sms-btn { flex-shrink:0;border-radius:44rpx;font-size:24rpx; }
.hint { display:block;font-size:22rpx;color:#e6a23c;margin-bottom:12rpx; }
.btn.secondary { background:#fff;color:#409eff;border:1px solid #409eff; }
</style>
