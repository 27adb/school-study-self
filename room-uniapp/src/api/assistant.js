import request from '@/utils/request'

export function listRoom(query) {
  return request({
    url: '/reservation/room/list',
    method: 'get',
    params: query,
  })
}

export function listSeat(query) {
  return request({
    url: '/reservation/seat/list',
    method: 'get',
    params: query,
  })
}

export function updateSeat(data) {
  return request({
    url: '/reservation/seat',
    method: 'put',
    data,
  })
}

export function getOverview(roomId) {
  return request({
    url: '/reservation/assistant/overview',
    method: 'get',
    params: { roomId },
  })
}

export function getRecommend(params) {
  return request({
    url: '/reservation/assistant/recommend',
    method: 'get',
    params,
  })
}

export function getGroupRecommend(params) {
  return request({
    url: '/reservation/assistant/groupRecommend',
    method: 'get',
    params,
  })
}

export function addFeedback(data) {
  return request({
    url: '/reservation/assistant/feedback',
    method: 'post',
    data,
  })
}

export function listFeedback(query) {
  return request({
    url: '/reservation/assistant/feedback/list',
    method: 'get',
    params: query,
  })
}

export function updateFeedbackStatus(id, data) {
  return request({
    url: `/reservation/assistant/feedback/${id}/status`,
    method: 'put',
    data,
  })
}

