import { useUserStore } from '@/stores/modules/user'
import { goLogin, isAuthExpiredResponse } from '@/utils/auth'

export function normalizeAuthToken(token) {
  const raw = String(token || '').trim()
  if (!raw) return ''
  if (/^Bearer\s+/i.test(raw)) return raw
  return `Bearer ${raw}`
}

function resolveBaseURL() {
  const platform = import.meta.env.UNI_PLATFORM
  let fromPlatformEnv = ''
  if (platform === 'mp-weixin') {
    fromPlatformEnv = import.meta.env.VITE_APP_API_BASE_MP_WEIXIN || ''
  } else if (platform && platform.indexOf('mp-') === 0) {
    fromPlatformEnv = import.meta.env.VITE_APP_API_BASE_MP || ''
  } else {
    fromPlatformEnv = import.meta.env.VITE_APP_API_BASE || ''
  }
  if (!fromPlatformEnv) {
    fromPlatformEnv = import.meta.env.VITE_APP_API_BASE || ''
  }
  if (fromPlatformEnv) return fromPlatformEnv
  // 真机调试时使用电脑 IP，H5 开发时使用代理
  return platform === 'h5' ? '/api' : 'http://192.168.143.160:8080'
}

export const baseURL = resolveBaseURL()
let lastNetToastAt = 0
const NET_TOAST_GAP_MS = 2500
let lastAuthToastAt = 0
const AUTH_TOAST_GAP_MS = 3000

function showNetToast(title) {
  const now = Date.now()
  if (now - lastNetToastAt < NET_TOAST_GAP_MS) return
  lastNetToastAt = now
  uni.showToast({ title, icon: 'none' })
}

function showAuthToast() {
  const now = Date.now()
  if (now - lastAuthToastAt < AUTH_TOAST_GAP_MS) return
  lastAuthToastAt = now
  uni.showToast({ title: '登录已失效，请重新登录', icon: 'none' })
}

function shouldHandleAuthExpired(options) {
  const rawUrl = String(options?.url || '')
  const noTokenRequest =
    options?.headers?.isToken === false || options?.header?.isToken === false
  if (noTokenRequest) return false
  // 登录/注册等匿名接口不触发过期跳转
  if (rawUrl === '/login' || rawUrl === '/register') return false
  const pages = getCurrentPages()
  const current = pages && pages.length ? pages[pages.length - 1] : null
  if (current && current.route === 'pages/login/login') return false
  return true
}

function buildQuery(params) {
  if (!params || typeof params !== 'object') return ''
  const parts = []
  for (const key of Object.keys(params)) {
    const v = params[key]
    if (v === undefined || v === null || v === '') continue
    parts.push(`${encodeURIComponent(key)}=${encodeURIComponent(String(v))}`)
  }
  return parts.length ? `?${parts.join('&')}` : ''
}

function request(options) {
  const userStore = useUserStore()
  const header = {
    ...(options.header || {}),
  }
  if (options.headers) {
    Object.assign(header, options.headers)
  }
  if (header.isToken === false) {
    delete header.Authorization
  } else if (userStore.token) {
    header.Authorization = normalizeAuthToken(userStore.token)
  }
  delete header.isToken
  delete header.repeatSubmit

  const method = (options.method || 'GET').toUpperCase()
  let path = options.url
  if (!path.startsWith('http')) {
    path = `${String(baseURL).replace(/\/$/, '')}/${String(path).replace(/^\//, '')}`
  }
  if (method === 'GET' && options.params) {
    path += buildQuery(options.params)
  }

  return new Promise((resolve, reject) => {
    uni.request({
      url: path,
      method,
      data: method === 'GET' ? undefined : options.data,
      header,
      timeout: options.timeout ?? 10000,
      success(res) {
        if (isAuthExpiredResponse(res) && shouldHandleAuthExpired(options)) {
          showAuthToast()
          goLogin()
        }
        if (res.statusCode === 500) {
          showNetToast('无法连接到服务器！')
        }
        resolve({
          data: res.data,
          status: res.statusCode,
          statusCode: res.statusCode,
        })
      },
      fail(err) {
        const msg = String(err?.errMsg || '')
        if (msg.includes('timeout')) {
          showNetToast('请求超时，请检查服务地址与网络')
        } else {
          showNetToast('网络异常')
        }
        reject(err)
      },
    })
  })
}

export default request
