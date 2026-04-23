<script setup>
import { ref } from 'vue'
import { register } from '@/api/login'
import { sendCampusCode, registerByCampusSms } from '@/api/campus'

const form = ref({ username: '', password: '', nickName: '', phonenumber: '' })
const smsForm = ref({ campusAccount: '', smsCode: '', password: '', nickName: '' })
const smsHint = ref('')
const loading = ref(false)
const tab = ref('pwd')

function submitRegister() {
  if (!form.value.username || !form.value.password) {
    uni.showToast({ title: '账号和密码必填', icon: 'none' })
    return
  }
  loading.value = true
  register(form.value)
    .then((res) => {
      if (res.data.code === 200) {
        uni.showToast({ title: '注册成功，请登录', icon: 'success' })
        setTimeout(() => uni.navigateBack(), 600)
      } else {
        uni.showToast({ title: res.data.msg || '注册失败', icon: 'none' })
      }
    })
    .finally(() => {
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

function submitSmsRegister() {
  if (!smsForm.value.campusAccount || !smsForm.value.smsCode || !smsForm.value.password) {
    uni.showToast({ title: '学号、验证码与密码必填', icon: 'none' })
    return
  }
  loading.value = true
  registerByCampusSms({
    campusAccount: smsForm.value.campusAccount,
    smsCode: smsForm.value.smsCode,
    password: smsForm.value.password,
    nickName: smsForm.value.nickName || smsForm.value.campusAccount,
  })
    .then((res) => {
      if (res.data.code === 200) {
        uni.showToast({ title: '注册成功，请使用学号+密码或验证码登录', icon: 'success' })
        setTimeout(() => uni.navigateBack(), 700)
      } else {
        uni.showToast({ title: res.data.msg || '注册失败', icon: 'none' })
      }
    })
    .finally(() => {
      loading.value = false
    })
}
</script>

<template>
  <view class="page">
    <view class="tabs">
      <text :class="['t', tab === 'pwd' ? 'on' : '']" @click="tab = 'pwd'">账号密码注册</text>
      <text :class="['t', tab === 'sms' ? 'on' : '']" @click="tab = 'sms'">学号+短信注册</text>
    </view>

    <view v-if="tab === 'pwd'" class="card">
      <text class="title">学生注册</text>
      <input v-model="form.username" class="input" placeholder="学号/账号" />
      <input v-model="form.nickName" class="input" placeholder="昵称" />
      <input v-model="form.phonenumber" class="input" placeholder="手机号" />
      <input v-model="form.password" class="input" password placeholder="密码" />
      <button class="btn" type="primary" :loading="loading" @click="submitRegister">注册</button>
    </view>

    <view v-else class="card">
      <text class="title">校园短信验证注册</text>
      <text class="hint">需管理员开启「系统注册」；注册后可用密码或验证码登录（JWT）。</text>
      <input v-model="smsForm.campusAccount" class="input" placeholder="学号（将作为登录名）" />
      <view class="sms-row">
        <input v-model="smsForm.smsCode" class="input sms-input" type="number" placeholder="短信码" />
        <button class="sms-btn" size="mini" type="default" @click="sendSms">获取验证码</button>
      </view>
      <text v-if="smsHint" class="tip">{{ smsHint }}</text>
      <input v-model="smsForm.password" class="input" password placeholder="登录密码（5～20 位）" />
      <input v-model="smsForm.nickName" class="input" placeholder="昵称（可选）" />
      <button class="btn" type="primary" :loading="loading" @click="submitSmsRegister">完成注册</button>
    </view>
  </view>
</template>

<style lang="scss" scoped>
.page {
  min-height: 100vh;
  padding: 24rpx;
  background: #f5f7fa;
}
.tabs {
  display: flex;
  margin-bottom: 16rpx;
  background: #fff;
  border-radius: 12rpx;
  overflow: hidden;
}
.tabs .t {
  flex: 1;
  text-align: center;
  padding: 24rpx;
  font-size: 28rpx;
  color: #666;
}
.tabs .on {
  color: #409eff;
  font-weight: 600;
  background: #ecf5ff;
}
.card {
  background: #fff;
  border-radius: 16rpx;
  padding: 24rpx;
}
.title {
  display: block;
  text-align: center;
  font-size: 34rpx;
  font-weight: 600;
  margin-bottom: 24rpx;
}
.hint {
  display: block;
  font-size: 24rpx;
  color: #909399;
  margin-bottom: 16rpx;
  line-height: 1.5;
}
.input {
  height: 80rpx;
  padding: 0 20rpx;
  margin-bottom: 16rpx;
  background: #f7f7f7;
  border-radius: 10rpx;
}
.sms-row {
  display: flex;
  align-items: center;
  gap: 12rpx;
  margin-bottom: 12rpx;
}
.sms-input {
  flex: 1;
  margin-bottom: 0;
}
.sms-btn {
  flex-shrink: 0;
  border-radius: 44rpx;
  font-size: 24rpx;
}
.tip {
  font-size: 22rpx;
  color: #e6a23c;
  margin-bottom: 12rpx;
}
.btn {
  margin-top: 8rpx;
}
</style>
