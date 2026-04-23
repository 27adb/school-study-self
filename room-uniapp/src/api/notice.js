import request from '@/utils/request'

export function listNotice(query) {
  return request({
    url: '/system/notice/list',
    method: 'get',
    params: query,
  })
}

export function getNotice(noticeId) {
  return request({
    url: `/system/notice/${noticeId}`,
    method: 'get',
  })
}
