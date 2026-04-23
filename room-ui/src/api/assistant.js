import request from '@/utils/request'

export function listRoomAssistant(query) {
  return request({
    url: '/reservation/room/list',
    method: 'get',
    params: query,
  })
}

export function listSeatAssistant(query) {
  return request({
    url: '/reservation/seat/list',
    method: 'get',
    params: query,
  })
}

export function updateSeatAssistant(data) {
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

export function listFeedbackAssistant(query) {
  return request({
    url: '/reservation/assistant/feedback/list',
    method: 'get',
    params: query,
  })
}

export function updateFeedbackStatus(id, data) {
  return request({
    url: '/reservation/assistant/feedback/' + id + '/status',
    method: 'put',
    data,
  })
}
