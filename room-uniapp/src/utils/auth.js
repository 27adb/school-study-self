let lastLoginRedirectAt = 0
const REDIRECT_GAP_MS = 3000
let redirecting = false
let unlockTimer = null

export function isAuthExpiredResponse(res) {
  const statusCode = Number(res?.statusCode || res?.status || 0)
  const bizCode = Number(res?.data?.code)
  if (statusCode === 401 || statusCode === 403) return true
  if (bizCode === 401 || bizCode === 403) return true
  return false
}

export function goLogin() {
  if (redirecting) return
  const now = Date.now()
  if (now - lastLoginRedirectAt < REDIRECT_GAP_MS) return
  const pages = getCurrentPages()
  const current = pages && pages.length ? pages[pages.length - 1] : null
  if (current && current.route === 'pages/login/login') return
  
  // 清除持久化登录态，避免认证失败后循环跳转
  try {
    uni.removeStorageSync('room-uniapp-user')
  } catch (e) {
    console.warn('清除用户信息失败:', e)
  }
  
  lastLoginRedirectAt = now
  redirecting = true
  if (unlockTimer) clearTimeout(unlockTimer)
  unlockTimer = setTimeout(() => {
    redirecting = false
  }, 5000)
  uni.reLaunch({
    url: '/pages/login/login',
    complete() {
      if (unlockTimer) clearTimeout(unlockTimer)
      redirecting = false
    },
  })
}
