import request from '@/utils/request'

export function login(username, password, code, uuid) {
  const data = { username, password, code, uuid }
  return request({
    url: '/login',
    headers: {
      isToken: false,
      repeatSubmit: false,
    },
    method: 'post',
    data,
  })
}

export function register(data) {
  return request({
    url: '/register',
    headers: {
      isToken: false,
      repeatSubmit: false,
    },
    method: 'post',
    data,
  })
}

export function getInfo() {
  return request({
    url: '/getInfo',
    method: 'get',
  })
}

export function logout() {
  return request({
    url: '/logout',
    method: 'post',
  })
}
