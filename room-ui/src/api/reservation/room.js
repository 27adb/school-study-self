import request from '@/utils/request'

// 查询自习室列表
export function listRoom(query) {
  return request({
    url: '/reservation/room/list',
    method: 'get',
    params: query
  })
}

// 查询自习室详细
export function getRoom(id) {
  return request({
    url: '/reservation/room/' + id,
    method: 'get'
  })
}

// 新增自习室
export function addRoom(data) {
  return request({
    url: '/reservation/room',
    method: 'post',
    data: data
  })
}

// 修改自习室
export function updateRoom(data) {
  return request({
    url: '/reservation/room',
    method: 'put',
    data: data
  })
}

// 删除自习室
export function delRoom(id) {
  return request({
    url: '/reservation/room/' + id,
    method: 'delete'
  })
}
