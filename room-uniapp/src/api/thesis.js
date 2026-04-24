import request from '@/utils/request'

/** 我的课程表（冲突校验用） */
export function listMyCourses() {
  return request({ url: '/student/thesis/courses', method: 'get' })
}
export function addMyCourse(data) {
  return request({ url: '/student/thesis/courses', method: 'post', data })
}
export function delMyCourse(id) {
  return request({ url: '/student/thesis/courses/' + id, method: 'delete' })
}

export function listReminders() {
  return request({ url: '/student/thesis/reminders', method: 'get' })
}
export function readReminder(id) {
  return request({ url: '/student/thesis/reminders/read/' + id, method: 'post' })
}

export function getBanStatus() {
  return request({ url: '/student/thesis/banStatus', method: 'get' })
}

export function getMedals() {
  return request({ url: '/student/thesis/medals', method: 'get' })
}
export function redeemMedal(code) {
  return request({ url: '/student/thesis/medals/redeem/' + code, method: 'post' })
}

export function createCarpool(data) {
  return request({ url: '/student/thesis/carpool/create', method: 'post', data })
}
export function getCarpoolInfo(shareCode) {
  return request({ url: '/student/thesis/carpool/joinInfo/' + shareCode, method: 'get' })
}

export function joinCarpool(data) {
  return request({ url: '/student/thesis/carpool/join', method: 'post', data })
}

export function submitRepair(data) {
  return request({ url: '/student/thesis/repair', method: 'post', data })
}

export function getShareText(id) {
  return request({ url: '/student/thesis/reservation/share/' + id, method: 'get' })
}

export function releaseBlacklistByUser(data) {
  return request({ url: '/thesis/admin/blacklist/releaseByUser', method: 'put', data })
}
