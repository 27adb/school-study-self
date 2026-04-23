import request from '@/utils/request'

export function listSeat(query) {
  return request({
    url: '/reservation/seat/list',
    method: 'get',
    params: query,
  })
}

export function getSeat(id) {
  return request({
    url: `/reservation/seat/${id}`,
    method: 'get',
  })
}

export function updateSeat(data) {
  return request({
    url: '/reservation/seat',
    method: 'put',
    data,
  })
}
