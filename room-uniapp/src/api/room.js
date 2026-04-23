import request from '@/utils/request'

export function listRoom(query) {
  return request({
    url: '/reservation/room/list',
    method: 'get',
    params: query,
  })
}

export function getRoom(id) {
  return request({
    url: `/reservation/room/${id}`,
    method: 'get',
  })
}
