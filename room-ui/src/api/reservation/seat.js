import request from '@/utils/request'

// 查询自习室座位列表
export function listSeat(query) {
  return request({
    url: '/reservation/seat/list',
    method: 'get',
    params: query
  })
}

// 查询自习室座位详细
export function getSeat(id) {
  return request({
    url: '/reservation/seat/' + id,
    method: 'get'
  })
}

// 新增自习室座位
export function addSeat(data) {
  return request({
    url: '/reservation/seat',
    method: 'post',
    data: data
  })
}

// 修改自习室座位
export function updateSeat(data) {
  return request({
    url: '/reservation/seat',
    method: 'put',
    data: data
  })
}

// 删除自习室座位
export function delSeat(id) {
  return request({
    url: '/reservation/seat/' + id,
    method: 'delete'
  })
}
