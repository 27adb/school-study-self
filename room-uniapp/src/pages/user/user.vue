<script setup>
import { computed, ref, watch } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { getInfo, logout } from '@/api/login'
import { updateUserProfile, updateUserPwd, uploadAvatar } from '@/api/user'
import { listReservation } from '@/api/reservation'
import { getRoom } from '@/api/room'
import { getSeat } from '@/api/seat'
import { baseURL } from '@/utils/request'
import { goLogin, isAuthExpiredResponse } from '@/utils/auth'
import { runStudentViolationCheck } from '@/utils/violation'
import { useUserStore } from '@/stores/modules/user'

const userStore = useUserStore()
const roleText = computed(() => {
  if (userStore.isSystemAdmin() && userStore.isRoomAdmin()) return '系统超级管理员'
  if (userStore.isSystemAdmin()) return '系统管理员'
  if (userStore.isRoomAdmin()) return '自习室管理员'
  return '普通学生'
})
// 使用 base64 编码的默认头像（灰色人像图标）
const defaultAvatar = 'data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxMDAiIGhlaWdodD0iMTAwIiB2aWV3Qm94PSIwIDAgMTAwIDEwMCI+PGNpcmNsZSBjeD0iNTAiIGN5PSI1MCIgcj0iNTAiIGZpbGw9IiNkOWQ5ZDkiLz48Y2lyY2xlIGN4PSI1MCIgY3k9IjM1IiByPSIyMCIgZmlsbD0iI2ZmZiIvPjxwYXRoIGQ9Ik01MCA1NSBjLTE1IDAtMzUgOC0zNSAyMHYxNWg3MHYtMTVjMC0xMi0yMC0yMC0zNS0yMHoiIGZpbGw9IiNmZmYiLz48L3N2Zz4='
const avatarUrl = ref(defaultAvatar)
watch(() => userStore.user, (u) => { 
  const avatarPath = u?.avatar
  if (avatarPath) {
    // 拼接完整路径，并添加错误处理
    const fullUrl = baseURL + avatarPath
    // 检查图片是否存在，不存在则使用默认头像
    uni.getImageInfo({
      src: fullUrl,
      success: () => {
        avatarUrl.value = fullUrl
      },
      fail: () => {
        console.warn('头像加载失败，使用默认头像:', fullUrl)
        avatarUrl.value = defaultAvatar
      }
    })
  } else {
    avatarUrl.value = defaultAvatar
  }
}, { deep: true, immediate: true })

function getUserInfo() {
  getInfo().then((res) => {
    if (res.data.code === 200) {
      userStore.setUser(res.data.user)
      userStore.setRoles(res.data.roles || [])
    } else if (isAuthExpiredResponse(res)) {
      // 认证失败时清除 token,防止循环
      userStore.removeToken()
      goLogin()
    } else {
      uni.showToast({ title: res?.data?.msg || '网络异常，请稍后重试', icon: 'none' })
    }
  }).catch(() => {
    uni.showToast({ title: '网络异常，请稍后重试', icon: 'none' })
  })
}
onShow(() => { 
  // 先检查 token,没有则跳转登录
  if (!userStore.token) return goLogin()
  // 有 token 但用户信息不完整,也跳转登录
  if (!userStore.user || !userStore.user.userId) {
    userStore.removeToken()
    return goLogin()
  }
  getUserInfo() 
})

const avatar = ref(''); const avatarFilePath = ref(''); const avatarShow = ref(false)
function updateAvatar() { avatar.value = avatarUrl.value; avatarFilePath.value = ''; avatarShow.value = true }
function chooseAvatar() { uni.chooseImage({ count:1, sizeType:['compressed'], success: (res) => { avatar.value = res.tempFilePaths[0]; avatarFilePath.value = res.tempFilePaths[0] } }) }
function updateAvatarBtn() { if (!avatarFilePath.value) return uni.showToast({ title: '请选择图片文件', icon: 'none' }); uploadAvatar(avatarFilePath.value).then(() => { uni.showToast({ title: '修改成功', icon: 'success' }); avatarShow.value = false; getUserInfo() }) }

const editProfileShow = ref(false)
const profileForm = ref({ nickName:'', phonenumber:'', email:'', sex:'0' })
function editProfile() { editProfileShow.value = true; const u = userStore.user || {}; profileForm.value = { ...u, sex: String(u.sex ?? '0') } }
function saveProfile() { updateUserProfile(profileForm.value).then((res) => { if (res.data.code === 200) { uni.showToast({ title: '保存成功', icon: 'success' }); editProfileShow.value = false; getUserInfo() } }) }

const pwdShow = ref(false)
const pwdForm = ref({ oldPassword:'', newPassword:'', confirmPassword:'' })
function updatePwd(){ pwdForm.value={ oldPassword:'', newPassword:'', confirmPassword:'' }; pwdShow.value = true }
function savePwd(){ if(pwdForm.value.newPassword!==pwdForm.value.confirmPassword) return uni.showToast({ title:'两次密码不一致', icon:'none' }); updateUserPwd(pwdForm.value.oldPassword,pwdForm.value.newPassword).then((res)=>{ if(res.data.code===200){ uni.showToast({ title:'修改成功', icon:'success' }); pwdShow.value=false; logout().then(()=>{ userStore.removeToken(); userStore.removeUser(); userStore.removeRoles(); goLogin() }) } }) }

const recordShow = ref(false)
const recordTitle = ref('预约记录')
const recordList = ref([])
function parseDate(v) {
  if (!v) return null
  const d = new Date(String(v).replace(/-/g, '/'))
  return Number.isNaN(d.getTime()) ? null : d
}

function isViolationRow(item) {
  const status = String(item?.status || '')
  const reservationStatus = String(item?.reservationStatus || '')
  const remark = String(item?.remark || '')
  const now = Date.now()
  const inAt = parseDate(item?.reservationInTime)
  const outAt = parseDate(item?.reservationOutTime)
  const noShow = reservationStatus === '已预约' && inAt && now > inAt.getTime() + 15 * 60 * 1000
  const overtime = reservationStatus === '使用中' && outAt && now > outAt.getTime()
  return (
    status === '违约' ||
    reservationStatus === '违约中' ||
    remark.includes('违约') ||
    remark.includes('未签到') ||
    remark.includes('未签退') ||
    !!noShow ||
    !!overtime
  )
}

async function enrichRecord(item) {
  try {
    if (!item?.seatId) {
      return { ...item, seatNum: '-', name: '未知自习室', location: '-' }
    }
    const seatRes = await getSeat(item.seatId)
    const seat = seatRes?.data?.data
    if (!seat?.roomId) {
      return { ...item, seatNum: seat?.seatNum || '-', name: '未知自习室', location: '-' }
    }
    const roomRes = await getRoom(seat.roomId)
    const room = roomRes?.data?.data || {}
    return {
      ...item,
      seatNum: seat.seatNum || '-',
      name: room.name || '未知自习室',
      location: room.location || '-',
    }
  } catch (e) {
    return { ...item, seatNum: '-', name: '未知自习室', location: '-' }
  }
}

function openRecords(status = '') {
  recordTitle.value = status ? '违约记录' : '预约记录'
  recordShow.value = true
  const run = () =>
    listReservation({ userId: userStore.user.userId, pageNum: 1, pageSize: 500 }).then(async (res) => {
      let rows = res?.data?.rows || []
      if (status) {
        rows = rows.filter(isViolationRow)
      }
      recordList.value = await Promise.all(rows.map((item) => enrichRecord(item)))
    })

  if (status) {
    runStudentViolationCheck(userStore.user.userId).finally(run)
  } else {
    run()
  }
}

function exit(){ uni.showModal({ title:'提示', content:'是否确定退出登录？', success:(r)=>{ if(!r.confirm) return; logout().then(()=>{ userStore.removeToken(); userStore.removeUser(); userStore.removeRoles(); goLogin() }) } }) }
</script>

<template>
  <view class="user"><scroll-view scroll-y class="scroll">
    <view class="my-info"><view class="info"><image class="avatar" :src="avatarUrl" mode="aspectFill" @click="updateAvatar" /><view><text class="nick">{{ userStore.user.nickName }}</text><text class="sub">学号：{{ userStore.user.userName }}</text><text class="sub">角色：{{ roleText }}</text></view></view></view>

    <view class="card">
      <view class="option" @click="editProfile"><text>编辑资料</text><text>›</text></view>
      <view class="option" @click="updatePwd"><text>修改密码</text><text>›</text></view>
      <view class="option" @click="openRecords('')"><text>预约记录</text><text>›</text></view>
      <view class="option" @click="openRecords('违约')"><text>违约记录</text><text>›</text></view>
      <view class="option" @click="uni.navigateTo({ url: '/pages/courses/index' })"><text>我的课表</text><text>›</text></view>
      <view class="option" @click="uni.navigateTo({ url: '/pages/reminders/index' })"><text>预约提醒</text><text>›</text></view>
      <view class="option" @click="uni.navigateTo({ url: '/pages/medals/index' })"><text>学习勋章</text><text>›</text></view>
      <view class="option" @click="uni.navigateTo({ url: '/pages/share/index' })"><text>分享预约</text><text>›</text></view>
      <view class="option" @click="uni.navigateTo({ url: '/pages/notices/index' })"><text>公告查看</text><text>›</text></view>
      <view class="option" @click="uni.navigateTo({ url: '/pages/scan/scan' })"><text>扫码签到 / 签退</text><text>›</text></view>
      <view class="option" @click="uni.navigateTo({ url: '/pages/feedback/index' })"><text>反馈申诉</text><text>›</text></view>
      <view v-if="userStore.isAdmin()" class="option" @click="uni.navigateTo({ url: '/pages/admin/dashboard' })">
        <text>{{ userStore.isSystemAdmin() && !userStore.isRoomAdmin() ? '系统管理端' : '管理端数据看板' }}</text>
        <text>›</text>
      </view>
    </view>

    <button class="logout" type="warn" plain @click="exit">退出登录</button>
  </scroll-view>

  <view v-if="avatarShow" class="mask" @click="avatarShow=false"><view class="dialog" @click.stop><text class="dlg-title">修改头像</text><view class="avatar-picker" @click="chooseAvatar"><image v-if="avatar" class="preview" :src="avatar" mode="aspectFill" /><text v-else>点击选择图片</text></view><view class="dlg-actions"><button size="mini" @click="avatarShow=false">取消</button><button size="mini" type="primary" @click="updateAvatarBtn">保存</button></view></view></view>

  <view v-if="editProfileShow" class="mask" @click="editProfileShow=false"><view class="dialog" @click.stop><text class="dlg-title">编辑资料</text><input v-model="profileForm.nickName" class="input" placeholder="昵称" /><input v-model="profileForm.phonenumber" class="input" placeholder="手机号" /><input v-model="profileForm.email" class="input" placeholder="邮箱" /><view class="dlg-actions"><button size="mini" @click="editProfileShow=false">取消</button><button size="mini" type="primary" @click="saveProfile">保存</button></view></view></view>

  <view v-if="pwdShow" class="mask" @click="pwdShow=false"><view class="dialog" @click.stop><text class="dlg-title">修改密码</text><input v-model="pwdForm.oldPassword" class="input" password placeholder="旧密码" /><input v-model="pwdForm.newPassword" class="input" password placeholder="新密码" /><input v-model="pwdForm.confirmPassword" class="input" password placeholder="确认密码" /><view class="dlg-actions"><button size="mini" @click="pwdShow=false">取消</button><button size="mini" type="primary" @click="savePwd">修改</button></view></view></view>

  <view v-if="recordShow" class="mask" @click="recordShow=false"><view class="dialog" @click.stop><text class="dlg-title">{{ recordTitle }}</text><scroll-view scroll-y class="record-scroll"><view v-for="item in recordList" :key="item.id" class="record-item"><text class="title">{{ item.name }} - {{ item.seatNum }}号</text><text>位置：{{ item.location }}</text><text>状态：{{ item.reservationStatus }}</text><text>时间：{{ item.reservationInTime }}</text><text v-if="item.remark">备注：{{ item.remark }}</text></view><view v-if="!recordList.length" class="empty">暂无记录</view></scroll-view></view></view>
  </view>
</template>

<style lang="scss" scoped>
.user{height:100vh}.scroll{height:100%;padding:10rpx}.my-info{padding:32rpx;color:#fff;background:linear-gradient(135deg,#409eff,#36cfc9);border-radius:16rpx;margin-bottom:20rpx}.info{display:flex;align-items:center;gap:20rpx}.avatar{width:96rpx;height:96rpx;border-radius:50%}.nick{display:block;font-size:34rpx;font-weight:700}.sub{display:block;font-size:24rpx;margin-top:4rpx}.card{background:#fff;border-radius:12rpx;overflow:hidden;margin-bottom:16rpx}.option{display:flex;justify-content:space-between;padding:28rpx 24rpx;border-bottom:1px solid #f2f2f2}.logout{margin-top:20rpx}.mask{position:fixed;inset:0;background:rgba(0,0,0,.45);display:flex;align-items:center;justify-content:center;z-index:1000}.dialog{width:92%;max-height:80vh;background:#fff;border-radius:16rpx;padding:20rpx}.dlg-title{display:block;text-align:center;font-size:32rpx;font-weight:600;margin-bottom:14rpx}.avatar-picker{height:300rpx;border:2px dashed #ddd;border-radius:12rpx;display:flex;align-items:center;justify-content:center}.preview{width:100%;height:100%}.input{height:76rpx;padding:0 20rpx;margin-top:12rpx;background:#f7f7f7;border-radius:10rpx}.dlg-actions{display:flex;justify-content:flex-end;gap:16rpx;margin-top:16rpx}.record-scroll{max-height:60vh}.record-item{padding:12rpx 0;border-bottom:1px solid #f1f1f1}.title{display:block;font-weight:600}.empty{text-align:center;color:#999;padding:20rpx}
</style>
