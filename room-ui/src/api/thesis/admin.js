import request from '@/utils/request'

export function listViolation(query) {
  return request({ url: '/thesis/admin/violation/list', method: 'get', params: query })
}
export function addViolation(data) {
  return request({ url: '/thesis/admin/violation', method: 'post', data })
}
export function delViolation(id) {
  return request({ url: '/thesis/admin/violation/' + id, method: 'delete' })
}
export function listBlacklist(query) {
  return request({ url: '/thesis/admin/blacklist/list', method: 'get', params: query })
}
export function addBlacklist(data) {
  return request({ url: '/thesis/admin/blacklist', method: 'post', data })
}
export function updateBlacklist(data) {
  return request({ url: '/thesis/admin/blacklist', method: 'put', data })
}
export function releaseBlacklistByUser(data) {
  return request({ url: '/thesis/admin/blacklist/releaseByUser', method: 'put', data })
}
export function listRepair(query) {
  return request({ url: '/thesis/admin/repair/list', method: 'get', params: query })
}
export function addRepair(data) {
  return request({ url: '/thesis/admin/repair', method: 'post', data })
}
export function updateRepair(data) {
  return request({ url: '/thesis/admin/repair', method: 'put', data })
}
export function delRepair(id) {
  return request({ url: '/thesis/admin/repair/' + id, method: 'delete' })
}
export function listCleaning(query) {
  return request({ url: '/thesis/admin/cleaning/list', method: 'get', params: query })
}
export function generateCleaning() {
  return request({ url: '/thesis/admin/cleaning/generate', method: 'post' })
}
export function updateCleaning(data) {
  return request({ url: '/thesis/admin/cleaning', method: 'put', data })
}
export function dashboardSummary() {
  return request({ url: '/thesis/admin/dashboard/summary', method: 'get' })
}
export function suggestList() {
  return request({ url: '/thesis/admin/suggest', method: 'get' })
}

/** 业务审计（room_business_audit） */
export function listBizAudit(query) {
  return request({ url: '/thesis/admin/audit/business', method: 'get', params: query })
}

export function listFeedback(query) {
  return request({ url: '/thesis/admin/feedback/list', method: 'get', params: query })
}

export function updateFeedbackStatus(id, data) {
  return request({ url: '/reservation/assistant/feedback/' + id + '/status', method: 'put', data })
}

export function listMedalDef() {
  return request({ url: '/thesis/admin/medal/list', method: 'get' })
}
export function addMedalDef(data) {
  return request({ url: '/thesis/admin/medal', method: 'post', data })
}
export function updateMedalDef(data) {
  return request({ url: '/thesis/admin/medal', method: 'put', data })
}
export function removeMedalDef(code) {
  return request({ url: '/thesis/admin/medal/' + code, method: 'delete' })
}

/** 全局看板 Excel（二进制） */
export function exportDashboardExcel() {
  return request({ url: '/thesis/admin/dashboard/exportExcel', method: 'post', responseType: 'blob' })
}
