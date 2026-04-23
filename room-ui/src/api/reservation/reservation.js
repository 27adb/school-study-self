import request from '@/utils/request'

// 查询自习室预约管理列表
export function listReservation(query) {
  return request({
    url: '/reservation/reservation/list',
    method: 'get',
    params: query
  })
}

// 查询自习室预约管理详细
export function getReservation(id) {
  return request({
    url: '/reservation/reservation/' + id,
    method: 'get'
  })
}

// 新增自习室预约管理
export function addReservation(data) {
  return request({
    url: '/reservation/reservation',
    method: 'post',
    data: data
  })
}

// 修改自习室预约管理
export function updateReservation(data) {
  return request({
    url: '/reservation/reservation',
    method: 'put',
    data: data
  })
}

// 删除自习室预约管理
export function delReservation(id) {
  return request({
    url: '/reservation/reservation/' + id,
    method: 'delete'
  })
}

// 管理员审核预约（待审核 → 已通过/已拒绝）
export function auditReservation(data) {
  return request({
    url: '/reservation/reservation/audit',
    method: 'put',
    data
  })
}
