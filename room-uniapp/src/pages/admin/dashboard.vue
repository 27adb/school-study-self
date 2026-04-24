<script setup>
import { computed, nextTick, onMounted, ref } from 'vue'
import { listRoom, listSeat, updateSeat, getOverview, listFeedback, updateFeedbackStatus } from '@/api/assistant'
import { listReservation, updateReservation, auditReservation } from '@/api/reservation'
import { releaseBlacklistByUser } from '@/api/thesis'
import request from '@/utils/request'
import { useUserStore } from '@/stores/modules/user'

const rooms = ref([])
const roomId = ref(null)
const seats = ref([])
const loading = ref(false)
const suggestList = ref([])
let chart = null
const overview = ref({ totalSeats: 0, freeSeats: 0, usingSeats: 0, reservedSeats: 0, faultSeats: 0 })

const userStore = useUserStore()

const tab = ref('core') // core | reservations | system

const reservationStatusOptions = ['已预约', '使用中', '违约中', '取消预约']
const reservationStatus = ref(reservationStatusOptions[0])
const reservationLoading = ref(false)
const reservations = ref([]) // enriched: { ...row, seat }
const violationLoading = ref(false)
const violationReservations = ref([])
const auditLoading = ref(false)
const pendingAudits = ref([])

const roomAdminModules = [
  '座位管理',
  '预约管理',
  '违规处理',
  '数据统计',
  '排班管理（待接入）',
  '故障派单',
  '订单审核',
]
const systemAdminModules = [
  '权限管理',
  '自习室配置',
  '数据管理',
  '日志记录',
  '建议优化',
  '公告管理',
]

const roomNameById = computed(() => {
  const map = {}
  ;(rooms.value || []).forEach((r) => { map[r.id] = r.name })
  return map
})

const systemLoading = ref(false)
const configs = ref([])
const roles = ref([])
const users = ref([])
const notices = ref([])
const dictTypes = ref([])
const operlogs = ref([])
const roomConfigs = ref([])

const faultTickets = computed(() => (suggestList.value || []).filter((f) => f.feedbackType === '故障反馈'))
const improveSuggestions = computed(() => (suggestList.value || []).filter((f) => f.feedbackType !== '故障反馈'))

function loadRooms() {
  listRoom({ pageNum: 1, pageSize: 1000 }).then((res) => {
    rooms.value = res.data.rows || []
    if (!roomId.value && rooms.value.length) roomId.value = rooms.value[0].id
    loadSeatData()
  })
}

function changeRoom(e) {
  roomId.value = rooms.value[e.detail.value].id
  loadSeatData()
}

function loadSeatData() {
  if (!roomId.value) return
  loading.value = true
  Promise.all([listSeat({ roomId: roomId.value, pageNum: 1, pageSize: 2000 }), getOverview(roomId.value)])
    .then(([seatRes, overviewRes]) => {
      seats.value = seatRes.data.rows || []
      if (overviewRes?.data?.code === 200) {
        overview.value = overviewRes.data.data || overview.value
      }
      renderChart()
      if (tab.value === 'reservations') {
        loadReservations()
        loadViolationReservations()
      }
    })
    .finally(() => (loading.value = false))
}

function nowPlus8() {
  const d = new Date()
  d.setHours(d.getHours() + 8)
  return d.toISOString().replace('T', ' ').split('.')[0]
}

function seatMap() {
  const map = new Map()
  ;(seats.value || []).forEach((s) => map.set(s.id, s))
  return map
}

function parseDate(v) {
  if (!v) return null
  const d = new Date(String(v).replace(/-/g, '/'))
  return Number.isNaN(d.getTime()) ? null : d
}

function isViolationLike(row) {
  if (!row) return false
  if (row.status === '违约' || row.reservationStatus === '违约中') return true
  const now = Date.now()
  const inAt = parseDate(row.reservationInTime)
  const outAt = parseDate(row.reservationOutTime)
  const noShow = row.reservationStatus === '已预约' && inAt && now > inAt.getTime() + 15 * 60 * 1000
  const overtime = row.reservationStatus === '使用中' && outAt && now > outAt.getTime()
  return !!(noShow || overtime)
}

function loadReservations() {
  if (!roomId.value || !userStore.isRoomAdmin()) return
  reservationLoading.value = true
  listReservation({ pageNum: 1, pageSize: 2000, reservationStatus: reservationStatus.value })
    .then((res) => {
      const rows = res.data.rows || []
      const sMap = seatMap()
      reservations.value = rows
        .filter((r) => sMap.has(r.seatId))
        .map((r) => ({ ...r, seat: sMap.get(r.seatId) }))
    })
    .finally(() => {
      reservationLoading.value = false
    })
}

function loadViolationReservations() {
  if (!roomId.value || !userStore.isRoomAdmin()) return
  violationLoading.value = true
  listReservation({ pageNum: 1, pageSize: 2000 })
    .then((res) => {
      const rows = res.data.rows || []
      const sMap = seatMap()
      violationReservations.value = rows
        .filter((r) => sMap.has(r.seatId))
        .filter((r) => isViolationLike(r))
        .map((r) => ({ ...r, seat: sMap.get(r.seatId) }))
    })
    .finally(() => {
      violationLoading.value = false
    })
}

function loadPendingAudits() {
  if (!roomId.value || !userStore.isRoomAdmin()) return
  auditLoading.value = true
  listReservation({ pageNum: 1, pageSize: 2000 })
    .then((res) => {
      const rows = res.data.rows || []
      const sMap = seatMap()
      pendingAudits.value = rows
        .filter((r) => sMap.has(r.seatId))
        .filter((r) => ['待审核', '待确认'].includes(r.auditStatus))
        .map((r) => ({ ...r, seat: sMap.get(r.seatId) }))
    })
    .finally(() => {
      auditLoading.value = false
    })
}

function updateReservationStatus(item, payload) {
  if (!item?.id) return
  return updateReservation({ id: item.id, ...payload })
}

function signIn(item) {
  uni.showModal({
    title: '提示',
    content: '确认签到？',
    success(res) {
      if (!res.confirm) return
      updateReservationStatus(item, {
        reservationStatus: '使用中',
        signInTime: nowPlus8(),
      }).then((r) => {
        if (r.data.code === 200) {
          uni.showToast({ title: '签到成功', icon: 'success' })
          loadReservations()
          loadViolationReservations()
        }
      })
    },
  })
}

function signOut(item) {
  uni.showModal({
    title: '提示',
    content: '确认签退？',
    success(res) {
      if (!res.confirm) return
      updateReservationStatus(item, {
        reservationStatus: '完成预约',
        signOutTime: nowPlus8(),
      }).then((r) => {
        if (r.data.code === 200) {
          uni.showToast({ title: '签退成功', icon: 'success' })
          loadReservations()
          loadViolationReservations()
        }
      })
    },
  })
}

function cancelReservation(item) {
  uni.showModal({
    title: '提示',
    content: '确认取消预约？',
    success(res) {
      if (!res.confirm) return
      updateReservationStatus(item, { reservationStatus: '取消预约' }).then((r) => {
        if (r.data.code === 200) {
          uni.showToast({ title: '取消成功', icon: 'success' })
          loadReservations()
          loadViolationReservations()
        }
      })
    },
  })
}

function releaseBan(item) {
  uni.showModal({
    title: '提示',
    content: '确认解除禁约？',
    success(res) {
      if (!res.confirm) return
      Promise.all([
        updateReservationStatus(item, {
          status: '正常',
          reservationStatus: '取消预约',
        }),
        item?.userId
          ? releaseBlacklistByUser({ userId: item.userId, remark: '管理员在移动管理端解除禁约' })
          : Promise.resolve({ data: { code: 200 } }),
      ]).then(([r]) => {
        if (r?.data?.code === 200) {
          uni.showToast({ title: '解除禁约成功', icon: 'success' })
          loadReservations()
          loadViolationReservations()
        }
      })
    },
  })
}

function doAudit(item, auditStatus, successText) {
  if (!item?.id) return
  auditReservation({ id: item.id, auditStatus }).then((r) => {
    if (r?.data?.code === 200) {
      uni.showToast({ title: successText, icon: 'success' })
      loadPendingAudits()
      loadReservations()
      loadViolationReservations()
    } else {
      uni.showToast({ title: r?.data?.msg || '操作失败', icon: 'none' })
    }
  })
}

function toggleFault(seat) {
  const to = seat.status === 1 ? 0 : 1
  updateSeat({ id: seat.id, status: to }).then((res) => {
    if (res.data.code === 200) {
      seat.status = to
      uni.showToast({ title: '已更新座位状态', icon: 'success' })
      loadSeatData()
    }
  })
}

async function renderChart() {
  // #ifdef H5
  await nextTick()
  const dom = document.getElementById('seatChart')
  if (!dom) return
  if (!chart) {
    const echarts = await import('echarts')
    chart = echarts.init(dom)
  }
  chart.setOption({
    title: { text: '座位状态统计', left: 'center' },
    tooltip: { trigger: 'item' },
    legend: { bottom: 0 },
    series: [{ type: 'pie', radius: ['35%', '62%'], data: [
      { name: '空闲', value: overview.value.freeSeats || 0 },
      { name: '使用中', value: overview.value.usingSeats || 0 },
      { name: '已预约', value: overview.value.reservedSeats || 0 },
      { name: '故障', value: overview.value.faultSeats || 0 },
    ] }],
  })
  // #endif
}

function markFeedbackDone(item) {
  updateFeedbackStatus(item.id, { status: '已处理' }).then((res) => {
    if (res.data.code === 200) {
      uni.showToast({ title: '已标记处理', icon: 'success' })
      loadFeedback()
    } else {
      uni.showToast({ title: res.data.msg || '操作失败', icon: 'none' })
    }
  })
}

function loadFeedback() {
  listFeedback({ pageNum: 1, pageSize: 20 }).then((res) => {
    suggestList.value = res.data.rows || []
  })
}

function loadSystemData() {
  if (!userStore.isSystemAdmin() || systemLoading.value) return
  systemLoading.value = true
  Promise.all([
    request({ url: '/system/config/list', method: 'get', params: { pageNum: 1, pageSize: 50 } }),
    request({ url: '/system/role/list', method: 'get', params: { pageNum: 1, pageSize: 50 } }),
    request({ url: '/system/user/list', method: 'get', params: { pageNum: 1, pageSize: 20 } }),
    request({ url: '/system/notice/list', method: 'get', params: { pageNum: 1, pageSize: 20 } }),
    request({ url: '/reservation/room/list', method: 'get', params: { pageNum: 1, pageSize: 50 } }),
    request({ url: '/reservation/assistant/feedback/list', method: 'get', params: { pageNum: 1, pageSize: 30 } }),
    request({ url: '/system/dict/type/list', method: 'get', params: { pageNum: 1, pageSize: 50 } }),
    request({ url: '/monitor/operlog/list', method: 'get', params: { pageNum: 1, pageSize: 20 } }),
  ])
    .then(([configRes, roleRes, userRes, noticeRes, roomRes, feedbackRes, dictTypeRes, operlogRes]) => {
      configs.value = configRes.data.rows || []
      roles.value = roleRes.data.rows || []
      users.value = userRes.data.rows || []
      notices.value = noticeRes.data.rows || []
      roomConfigs.value = roomRes.data.rows || []
      suggestList.value = feedbackRes.data.rows || []
      dictTypes.value = dictTypeRes.data.rows || []
      operlogs.value = operlogRes.data.rows || []
    })
    .finally(() => { systemLoading.value = false })
}

function switchTab(next) {
  if (next === 'core' && !userStore.isRoomAdmin()) return
  if (next === 'reservations' && !userStore.isRoomAdmin()) return
  if (next === 'system' && !userStore.isSystemAdmin()) return
  tab.value = next
  if (next === 'reservations') {
    loadReservations()
    loadViolationReservations()
    loadPendingAudits()
  } else if (next === 'system') {
    loadSystemData()
  }
}

function onReservationStatusChange(e) {
  const idx = Number(e.detail?.value)
  reservationStatus.value = reservationStatusOptions[idx] || reservationStatusOptions[0]
  loadReservations()
}

onMounted(() => {
  if (!userStore.isAdmin()) {
    uni.showToast({ title: '无管理端访问权限', icon: 'none' })
    uni.navigateBack()
    return
  }
  if (userStore.isRoomAdmin()) {
    tab.value = 'core'
    loadFeedback()
    loadRooms()
    return
  }
  if (userStore.isSystemAdmin()) {
    tab.value = 'system'
    loadSystemData()
  }
})
</script>

<template>
  <view class="page">
    <view class="tab-bar">
      <button v-if="userStore.isRoomAdmin()" size="mini" :type="tab === 'core' ? 'primary' : 'default'" @click="switchTab('core')">座位/反馈</button>
      <button v-if="userStore.isRoomAdmin()" size="mini" :type="tab === 'reservations' ? 'primary' : 'default'" @click="switchTab('reservations')">预约管理</button>
      <button
        v-if="userStore.isSystemAdmin()"
        size="mini"
        :type="tab === 'system' ? 'primary' : 'default'"
        @click="switchTab('system')"
      >
        系统管理
      </button>
    </view>

    <view v-if="userStore.isRoomAdmin() && tab !== 'system'" class="card">
      <text class="subtitle">自习室管理员职责模块</text>
      <view class="module-list">
        <text v-for="m in roomAdminModules" :key="m" class="module-tag">{{ m }}</text>
      </view>
    </view>
    <view v-if="userStore.isSystemAdmin() && tab === 'system'" class="card">
      <text class="subtitle">系统管理员职责模块</text>
      <view class="module-list">
        <text v-for="m in systemAdminModules" :key="m" class="module-tag">{{ m }}</text>
      </view>
    </view>

    <view v-if="userStore.isRoomAdmin()" class="card">
      <text class="title">管理端：统计与运维</text>
      <picker :range="rooms" range-key="name" @change="changeRoom">
        <view class="picker">当前自习室：{{ rooms.find(r=>r.id===roomId)?.name || '请选择' }}</view>
      </picker>
      <view class="quick-stats">
        <text>总座位：{{ overview.totalSeats || 0 }}</text>
        <text>空闲：{{ overview.freeSeats || 0 }}</text>
        <text>占用：{{ (overview.usingSeats || 0) + (overview.reservedSeats || 0) }}</text>
        <text>故障：{{ overview.faultSeats || 0 }}</text>
      </view>
      <view v-if="tab === 'core'">
        <!-- #ifdef H5 --><view id="seatChart" class="chart"></view><!-- #endif -->
        <!-- #ifndef H5 --><view class="tip">当前端暂不支持 ECharts，请在 H5 端查看图表。</view><!-- #endif -->
      </view>
    </view>

    <view v-if="tab === 'core'">
      <view class="card">
        <text class="subtitle">座位调整（故障/恢复）</text>
        <view v-if="loading" class="loading">加载中...</view>
        <view class="seat-list">
          <view v-for="s in seats" :key="s.id" class="seat-item">
            <text>#{{ s.seatNum }}（{{ s.rowNum }}行{{ s.colNum }}列）</text>
            <button size="mini" :type="s.status===1?'warn':'primary'" @click="toggleFault(s)">
              {{ s.status===1?'恢复正常':'标记故障' }}
            </button>
          </view>
        </view>
      </view>
      <view class="card">
        <text class="subtitle">故障派单（来自故障反馈）</text>
        <view v-for="f in faultTickets.slice(0,20)" :key="f.id" class="fb-item">
          <text class="fb-top">[{{ f.feedbackType }}] {{ f.createBy }} · {{ f.createTime }}</text>
          <text class="fb-content">{{ f.content }}</text>
          <view class="fb-actions">
            <text class="fb-status">状态：{{ f.status }}</text>
            <button v-if="f.status !== '已处理'" size="mini" @click="markFeedbackDone(f)">标记已处理</button>
          </view>
        </view>
        <view v-if="!faultTickets.length" class="tip">暂无故障工单</view>
      </view>
    </view>

    <!-- 预约管理 -->
    <view v-if="tab === 'reservations'" class="card">
      <text class="subtitle">订单/预约管理（{{ roomNameById[roomId] || '' }}）</text>
      <picker :range="reservationStatusOptions" @change="onReservationStatusChange">
        <view class="picker">状态筛选：{{ reservationStatus }}</view>
      </picker>
      <view v-if="reservationLoading" class="loading">加载中...</view>
      <scroll-view v-else scroll-y class="reserve-scroll">
        <view v-for="r in reservations" :key="r.id" class="reserve-item">
          <view class="reserve-top">
            <text class="reserve-seat">座位：{{ (r.seat && r.seat.seatNum) || '-' }}</text>
            <text class="reserve-status">状态：{{ r.reservationStatus }}</text>
          </view>
          <text class="reserve-meta">预约时间：{{ r.reservationInTime }} ~ {{ r.reservationOutTime }}</text>
          <text v-if="r.signInTime" class="reserve-meta">签到：{{ r.signInTime }}</text>
          <text v-if="r.signOutTime" class="reserve-meta">签退：{{ r.signOutTime }}</text>
          <text v-if="r.remark" class="reserve-meta">备注：{{ r.remark }}</text>
          <view class="reserve-actions">
            <button
              v-if="r.reservationStatus === '已预约'"
              size="mini"
              type="primary"
              @click="signIn(r)"
            >
              签到
            </button>
            <button
              v-if="r.reservationStatus === '已预约'"
              size="mini"
              type="warn"
              @click="cancelReservation(r)"
            >
              取消
            </button>
            <button
              v-if="r.reservationStatus === '使用中'"
              size="mini"
              type="primary"
              @click="signOut(r)"
            >
              签退
            </button>
            <button
              v-if="r.reservationStatus === '违约中'"
              size="mini"
              type="primary"
              @click="releaseBan(r)"
            >
              解除禁约
            </button>
          </view>
        </view>
        <view v-if="!reservations.length" class="tip">暂无订单</view>
      </scroll-view>
      <view class="divider"></view>
      <text class="subtitle">违约名单（重点关注）</text>
      <view v-if="violationLoading" class="loading">加载中...</view>
      <view v-else>
        <view v-for="r in violationReservations" :key="`vio-${r.id}`" class="reserve-item">
          <view class="reserve-top">
            <text class="reserve-seat">座位：{{ (r.seat && r.seat.seatNum) || '-' }}</text>
            <text class="reserve-status bad">状态：{{ r.reservationStatus === '违约中' || r.status === '违约' ? '违约中' : `疑似违约(${r.reservationStatus})` }}</text>
          </view>
          <text class="reserve-meta">用户ID：{{ r.userId }}</text>
          <text class="reserve-meta">预约时间：{{ r.reservationInTime }} ~ {{ r.reservationOutTime }}</text>
          <text v-if="r.remark" class="reserve-meta">违约原因：{{ r.remark }}</text>
          <view class="reserve-actions">
            <button size="mini" type="primary" @click="releaseBan(r)">解除禁约</button>
          </view>
        </view>
        <view v-if="!violationReservations.length" class="tip">当前无违约记录</view>
      </view>
      <view class="divider"></view>
      <text class="subtitle">订单审核</text>
      <view v-if="auditLoading" class="loading">加载中...</view>
      <view v-else>
        <view v-for="r in pendingAudits" :key="`audit-${r.id}`" class="reserve-item">
          <view class="reserve-top">
            <text class="reserve-seat">座位：{{ (r.seat && r.seat.seatNum) || '-' }}</text>
            <text class="reserve-status">{{ r.auditStatus || '待审核' }}</text>
          </view>
          <text class="reserve-meta">用户ID：{{ r.userId }}</text>
          <text class="reserve-meta">预约时间：{{ r.reservationInTime }} ~ {{ r.reservationOutTime }}</text>
          <view class="reserve-actions">
            <button size="mini" type="primary" @click="doAudit(r, '已通过', '审核已通过')">通过</button>
            <button size="mini" type="warn" @click="doAudit(r, '已拒绝', '已驳回')">驳回</button>
          </view>
        </view>
        <view v-if="!pendingAudits.length" class="tip">暂无待审核订单</view>
      </view>
    </view>

    <!-- 系统管理：仅超级管理员 -->
    <view v-if="tab === 'system' && userStore.isSystemAdmin()" class="system-wrap">
      <view class="card">
        <text class="subtitle">权限管理（角色/用户）</text>
        <scroll-view scroll-y class="sys-scroll">
          <view v-for="role in roles" :key="role.roleId" class="sys-row">
            <text class="sys-key">{{ role.roleName }}</text>
            <text class="sys-muted">({{ role.roleKey }})</text>
          </view>
          <view v-if="!roles.length" class="tip">暂无角色</view>
        </scroll-view>
        <scroll-view scroll-y class="sys-scroll">
          <view v-for="u in users" :key="u.userId" class="sys-row">
            <text class="sys-key">{{ u.nickName || u.userName }}</text>
            <text class="sys-muted">({{ u.userName }})</text>
          </view>
          <view v-if="!users.length" class="tip">暂无用户</view>
        </scroll-view>
      </view>

      <view class="card">
        <text class="subtitle">数据配置</text>
        <view v-if="systemLoading" class="loading">加载中...</view>
        <scroll-view v-else scroll-y class="sys-scroll">
          <view v-for="c in configs" :key="c.configId" class="sys-row">
            <text class="sys-key">{{ c.configKey }}</text>
            <text class="sys-muted">{{ c.configValue }}</text>
          </view>
          <view v-if="!configs.length" class="tip">暂无配置</view>
        </scroll-view>
      </view>

      <view class="card">
        <text class="subtitle">自习室配置</text>
        <view v-if="systemLoading" class="loading">加载中...</view>
        <scroll-view v-else scroll-y class="sys-scroll">
          <view v-for="r in roomConfigs" :key="r.id" class="sys-row">
            <text class="sys-key">{{ r.name }}</text>
            <text class="sys-muted">{{ r.location }} · {{ r.openTime }}-{{ r.closeTime }}</text>
          </view>
          <view v-if="!roomConfigs.length" class="tip">暂无自习室配置数据</view>
        </scroll-view>
      </view>

      <view class="card">
        <text class="subtitle">字典数据类型</text>
        <view v-if="systemLoading" class="loading">加载中...</view>
        <scroll-view v-else scroll-y class="sys-scroll">
          <view v-for="d in dictTypes" :key="d.dictId" class="sys-row">
            <text class="sys-key">{{ d.dictName }}</text>
            <text class="sys-muted">({{ d.dictType }})</text>
          </view>
          <view v-if="!dictTypes.length" class="tip">暂无字典类型</view>
        </scroll-view>
      </view>

      <view class="card">
        <text class="subtitle">公告管理</text>
        <view v-if="systemLoading" class="loading">加载中...</view>
        <scroll-view v-else scroll-y class="sys-scroll">
          <view v-for="n in notices" :key="n.noticeId" class="sys-row">
            <text class="sys-key">
              {{ n.noticeType == 1 ? '通知' : '公告' }}：{{ n.noticeTitle }}
            </text>
            <text class="sys-muted">{{ (n.createTime || '').split(' ')[0] }}</text>
          </view>
          <view v-if="!notices.length" class="tip">暂无通知</view>
        </scroll-view>
      </view>

      <view class="card">
        <text class="subtitle">建议优化（学生反馈）</text>
        <scroll-view scroll-y class="sys-scroll">
          <view v-for="f in improveSuggestions.slice(0, 20)" :key="`s-${f.id}`" class="sys-row">
            <text class="sys-key">[{{ f.feedbackType }}] {{ f.createBy || '-' }}</text>
            <text class="sys-muted">{{ f.status }}</text>
          </view>
          <view v-if="!improveSuggestions.length" class="tip">暂无建议优化反馈</view>
        </scroll-view>
      </view>

      <view class="card">
        <text class="subtitle">日志记录</text>
        <scroll-view scroll-y class="sys-scroll">
          <view v-for="l in operlogs" :key="l.operId" class="sys-row">
            <text class="sys-key">{{ l.title }}</text>
            <text class="sys-muted">{{ l.operName }}</text>
          </view>
          <view v-if="!operlogs.length" class="tip">暂无操作日志</view>
        </scroll-view>
      </view>
    </view>
  </view>
</template>

<style scoped>
.page{min-height:100vh;background:#f5f7fa;padding:20rpx}.card{background:#fff;border-radius:12rpx;padding:20rpx;margin-bottom:16rpx}.title{display:block;font-size:34rpx;font-weight:700;margin-bottom:12rpx}.subtitle{display:block;font-size:30rpx;font-weight:600;margin-bottom:12rpx}.picker{height:72rpx;line-height:72rpx;padding:0 16rpx;background:#f7f7f7;border-radius:8rpx}.quick-stats{display:grid;grid-template-columns:1fr 1fr;gap:8rpx;margin-top:10rpx;color:#555;font-size:24rpx}.chart{width:100%;height:420rpx;margin-top:12rpx}.tip{color:#999;font-size:24rpx;padding:10rpx 0}.seat-list{max-height:480rpx;overflow:auto}.seat-item{display:flex;justify-content:space-between;align-items:center;padding:10rpx 0;border-bottom:1px solid #f0f0f0}.fb-item{padding:10rpx 0;border-bottom:1px solid #f2f2f2}.fb-top{display:block;color:#666;font-size:24rpx;margin-bottom:4rpx}.fb-content{display:block;color:#333;font-size:26rpx}.fb-actions{display:flex;justify-content:space-between;align-items:center;margin-top:8rpx}.fb-status{font-size:22rpx;color:#888}.loading{color:#999;text-align:center;padding:16rpx}
.tab-bar{display:flex;gap:12rpx;justify-content:flex-start;margin-bottom:12rpx;flex-wrap:wrap}
.reserve-scroll{max-height:560rpx}
.reserve-item{padding:14rpx 0;border-bottom:1px solid #f2f2f2}
.reserve-top{display:flex;justify-content:space-between;align-items:center;margin-bottom:6rpx}
.reserve-seat{font-weight:700;color:#333;font-size:26rpx}
.reserve-status{font-size:24rpx;color:#409eff}
.reserve-status.bad{color:#f56c6c}
.reserve-meta{display:block;color:#666;font-size:24rpx;margin-top:4rpx;word-break:break-all}
.reserve-actions{display:flex;justify-content:flex-end;gap:12rpx;margin-top:10rpx;flex-wrap:wrap}
.divider{height:1px;background:#eee;margin:16rpx 0}
.module-list{display:flex;flex-wrap:wrap;gap:12rpx}
.module-tag{font-size:22rpx;color:#409eff;background:#ecf5ff;padding:6rpx 12rpx;border-radius:18rpx}

.system-wrap{margin-top:8rpx}
.sys-scroll{max-height:280rpx}
.sys-row{display:flex;justify-content:space-between;gap:12rpx;padding:10rpx 0;border-bottom:1px solid #f3f3f3}
.sys-key{color:#333;font-weight:600}
.sys-muted{color:#888;font-size:22rpx;max-width:60%}
</style>
