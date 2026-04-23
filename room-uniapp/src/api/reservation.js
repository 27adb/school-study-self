import request from '@/utils/request'

export function listReservation(query) {
  return request({
    url: '/reservation/reservation/list',
    method: 'get',
    params: query,
  })
}

export function getReservation(id) {
  return request({
    url: `/reservation/reservation/${id}`,
    method: 'get',
  })
}

/** 学生预约（走论文扩展校验：黑名单/课表冲突/座位与时长） */
export function addReservation(data) {
  return request({
    url: '/student/thesis/reservation',
    method: 'post',
    data,
  })
}

export function updateReservation(data) {
  return request({
    url: '/reservation/reservation',
    method: 'put',
    data,
  })
}

export function delReservation(id) {
  return request({
    url: `/reservation/reservation/${id}`,
    method: 'delete',
  })
}

/** 学生端签到（服务端写入签到时间） */
export function studentSignIn(id) {
  return request({
    url: '/student/reservation/signIn',
    method: 'post',
    data: { id },
  })
}

/** 学生端签退 */
export function studentSignOut(id) {
  return request({
    url: '/student/reservation/signOut',
    method: 'post',
    data: { id },
  })
}
