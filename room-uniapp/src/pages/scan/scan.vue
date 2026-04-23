<script setup>
import { studentSignIn, studentSignOut, getReservation } from '@/api/reservation'
import { getSeat } from '@/api/seat'
import { getRoom } from '@/api/room'
import { useUserStore } from '@/stores/modules/user'

const userStore = useUserStore()
const DEFAULT_RADIUS_METER = 120

function parseDate(v) {
  if (!v) return null
  const normalized = String(v).replace('T', ' ').replace(/\.\d+$/, '')
  const d = new Date(normalized)
  return Number.isNaN(d.getTime()) ? null : d
}

function toRad(v) {
  return (Number(v) * Math.PI) / 180
}

function distanceMeter(lat1, lng1, lat2, lng2) {
  const R = 6378137
  const dLat = toRad(lat2 - lat1)
  const dLng = toRad(lng2 - lng1)
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) * Math.sin(dLng / 2)
  return 2 * R * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
}

function bd09ToGcj02(bdLat, bdLng) {
  const xPi = (Math.PI * 3000.0) / 180.0
  const x = Number(bdLng) - 0.0065
  const y = Number(bdLat) - 0.006
  const z = Math.sqrt(x * x + y * y) - 0.00002 * Math.sin(y * xPi)
  const theta = Math.atan2(y, x) - 0.000003 * Math.cos(x * xPi)
  const lng = z * Math.cos(theta)
  const lat = z * Math.sin(theta)
  return { lat, lng }
}

function pickCoord(room) {
  const lat = Number(room.latitude ?? room.lat ?? room.locationLat ?? room.locationLatitude)
  const lng = Number(room.longitude ?? room.lng ?? room.locationLng ?? room.locationLongitude)
  if (!Number.isFinite(lat) || !Number.isFinite(lng)) return null
  return { lat, lng }
}

function pickRadius(room) {
  const v = Number(room.signRadius ?? room.signRadiusMeter ?? room.radiusMeter)
  return Number.isFinite(v) && v > 0 ? v : DEFAULT_RADIUS_METER
}

function getCurrentLocation() {
  return new Promise((resolve, reject) => {
    uni.authorize({
      scope: 'scope.userLocation',
      success() {
        uni.getLocation({
          type: 'gcj02',
          isHighAccuracy: true,
          success: resolve,
          fail: (err) => {
            const msg = String(err?.errMsg || '')
            if (msg.includes('auth deny') || msg.includes('authorize')) {
              reject(new Error('定位权限被拒绝，请在微信小程序设置中开启位置权限后重试'))
              return
            }
            if (msg.includes('require permission desc')) {
              reject(new Error('小程序未声明定位权限描述，请重新编译并上传最新代码'))
              return
            }
            reject(err)
          },
        })
      },
      fail: (err) => {
        const msg = String(err?.errMsg || '')
        if (msg.includes('require permission desc')) {
          reject(new Error('小程序未声明定位权限描述，请重新编译并上传最新代码'))
          return
        }
        reject(new Error('定位权限未授权，请在设置中开启后重试'))
      },
    })
  })
}

function showActionError(title, payload, fallback) {
  const body = payload?.data?.data ? payload.data.data : payload?.data || payload
  const msg =
    body?.msg ||
    body?.message ||
    body?.error ||
    body?.errMsg ||
    payload?.errMsg ||
    payload?.message ||
    (typeof payload === 'string' ? payload : '') ||
    ''
  const code = body?.code ?? payload?.code
  const raw = (() => {
    try {
      return JSON.stringify(body)
    } catch (_e) {
      return ''
    }
  })()
  const finalMsg = msg || (raw ? `原始返回：${raw.slice(0, 180)}` : fallback || '操作失败')
  const content = code != null ? `错误码：${code}\n${finalMsg}` : finalMsg
  uni.showModal({
    title,
    content: String(content),
    showCancel: false,
    confirmText: '知道了',
  })
}

function askOpenLocationSetting(msg) {
  return new Promise((resolve, reject) => {
    uni.showModal({
      title: '需要定位权限',
      content: msg || '签到/签退需要定位权限，请在设置中开启后重试',
      confirmText: '去设置',
      cancelText: '取消',
      success: (res) => {
        if (!res.confirm) {
          reject(new Error('未开启定位权限，已取消操作'))
          return
        }
        uni.openSetting({
          success: (settingRes) => {
            const ok = !!settingRes?.authSetting?.['scope.userLocation']
            if (ok) resolve(true)
            else reject(new Error('定位权限未开启，请开启后重试'))
          },
          fail: () => reject(new Error('无法打开设置页，请手动开启定位权限')),
        })
      },
      fail: () => reject(new Error('未开启定位权限，已取消操作')),
    })
  })
}

async function verifyScanPermission(reservationId, action) {
  const detailRes = await getReservation(reservationId)
  const row = detailRes?.data?.data
  if (!row || !row.id) throw new Error('未找到预约记录')
  if (Number(row.userId) !== Number(userStore.user?.userId)) {
    throw new Error('仅可操作本人预约记录')
  }
  if (row.auditStatus === '待审核') {
    throw new Error('订单待管理员审核通过后才能签到')
  }
  if (row.auditStatus === '已拒绝') {
    throw new Error('订单已拒绝，无法签到')
  }
  if (action === 'signIn' && row.reservationStatus !== '已预约') {
    throw new Error('当前预约状态不可签到')
  }
  if (action === 'signOut' && row.reservationStatus !== '使用中') {
    throw new Error('当前预约状态不可签退')
  }
  const now = new Date()
  const inTime = parseDate(row.reservationInTime)
  const outTime = parseDate(row.reservationOutTime)
  if (action === 'signIn' && inTime && now < inTime) {
    throw new Error(`未到签到时间，预约开始于 ${row.reservationInTime}`)
  }
  if (action === 'signOut' && outTime && now < outTime) {
    throw new Error(`未到签退时间，预约结束于 ${row.reservationOutTime}`)
  }

  const seatRes = await getSeat(row.seatId)
  const seat = seatRes?.data?.data
  if (!seat?.roomId) throw new Error('未找到座位所属自习室')
  const roomRes = await getRoom(seat.roomId)
  const room = roomRes?.data?.data || {}
  const coord = pickCoord(room)
  if (!coord) throw new Error('该自习室未配置签到范围，请联系管理员配置经纬度')

  let current = null
  try {
    current = await getCurrentLocation()
  } catch (e) {
    const msg = String(e?.message || e?.errMsg || '')
    if (msg.includes('require permission desc')) {
      throw new Error('小程序未声明定位权限描述，请重新编译并上传最新代码')
    }
    if (msg.includes('auth deny') || msg.includes('authorize') || msg.includes('定位权限')) {
      await askOpenLocationSetting('签到/签退需要定位权限，请开启后重试')
      current = await getCurrentLocation()
    } else {
      throw e
    }
  }
  const radius = pickRadius(room)
  const dGcj = distanceMeter(current.latitude, current.longitude, coord.lat, coord.lng)

  // 兼容管理员使用百度选点（BD-09）配置的历史数据，避免坐标系不一致导致误判
  const coordFromBd = bd09ToGcj02(coord.lat, coord.lng)
  const dBdConverted = distanceMeter(
    current.latitude,
    current.longitude,
    coordFromBd.lat,
    coordFromBd.lng
  )

  const minDistance = Math.min(dGcj, dBdConverted)
  if (minDistance > radius) {
    throw new Error(
      `未在签到范围内（当前距离约 ${Math.round(minDistance)} 米，允许 ${Math.round(radius)} 米）`
    )
  }
}

function scan() {
  uni.scanCode({
    onlyFromCamera: true,
    success(res) {
      parseAndGo(res.result)
    },
    fail(err) {
      const msg = (err && (err.errMsg || err.errno)) ? String(err.errMsg || err.errno) : ''
      if (msg.includes('cancel') || msg.includes('取消')) {
        return
      }
      uni.showModal({
        title: '无法调起扫码',
        content:
          '真机请允许相机权限；开发者工具/H5 常不支持扫码。本系统仅支持到馆扫码签到/签退。',
        showCancel: true,
        confirmText: '知道了',
      })
    },
  })
}

async function parseAndGo(raw) {
  const p = (raw || '').trim()
  if (!p) {
    uni.showToast({ title: '无效二维码', icon: 'none' })
    return
  }
  const parts = p.split(':')
  if (parts[0] !== 'STUDY_ROOM' || parts.length < 3) {
    uni.showToast({ title: '非本系统自习室签到码', icon: 'none' })
    return
  }
  const action = parts[1]
  const id = Number(parts[2])
  if (!id) {
    uni.showToast({ title: '无效预约编号', icon: 'none' })
    return
  }
  if (action === 'signIn') {
    verifyScanPermission(id, action)
      .then(() => studentSignIn(id))
      .then((r) => {
        const biz = r?.data || {}
        if (biz.code === 200) {
          uni.showToast({ title: '签到成功', icon: 'success' })
          return
        }
        showActionError('签到失败', biz, '签到失败')
      })
      .catch((e) => {
        showActionError('签到失败', e, '签到失败')
      })
    return
  }
  if (action === 'signOut') {
    verifyScanPermission(id, action)
      .then(() => studentSignOut(id))
      .then((r) => {
        const biz = r?.data || {}
        if (biz.code === 200) {
          uni.showToast({ title: '签退成功', icon: 'success' })
          return
        }
        showActionError('签退失败', biz, '签退失败')
      })
      .catch((e) => {
        showActionError('签退失败', e, '签退失败')
      })
    return
  }
  uni.showToast({ title: '未知操作类型', icon: 'none' })
}
</script>

<template>
  <view class="page">
    <view class="card">
      <text class="h1">扫码签到 / 签退</text>
      <text class="tip">仅支持本人预约扫码操作，且必须在自习室配置的签到范围内。</text>
      <button class="btn" type="primary" @click="scan">打开相机扫码</button>
    </view>
  </view>
</template>

<style lang="scss" scoped>
.page {
  min-height: 100vh;
  padding: 40rpx;
  background: #f5f7fa;
}
.card {
  padding: 48rpx 36rpx;
  background: #fff;
  border-radius: 16rpx;
}
.h1 {
  display: block;
  font-size: 36rpx;
  font-weight: 600;
  margin-bottom: 24rpx;
  color: #303133;
}
.tip {
  display: block;
  font-size: 26rpx;
  color: #606266;
  line-height: 1.5;
  margin-bottom: 40rpx;
}
.btn {
  border-radius: 44rpx;
  height: 88rpx;
  line-height: 88rpx;
  font-size: 30rpx;
}
</style>
