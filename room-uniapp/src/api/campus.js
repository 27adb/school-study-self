import request from '@/utils/request'

export function sendCampusCode(campusAccount) {
  return request({ url: '/campus/sendCode', method: 'post', data: { campusAccount }, headers: { isToken: false } })
}

export function loginByCampusSms(campusAccount, smsCode) {
  return request({
    url: '/campus/loginBySms',
    method: 'post',
    data: { campusAccount, smsCode },
    headers: { isToken: false },
  })
}

/** 学号 + 短信注册（需开启系统注册开关） */
export function registerByCampusSms(data) {
  return request({
    url: '/campus/registerBySms',
    method: 'post',
    data,
    headers: { isToken: false },
  })
}
