import request, { baseURL, normalizeAuthToken } from '@/utils/request'
import { useUserStore } from '@/stores/modules/user'

export function updateUserProfile(data) {
  return request({
    url: '/system/user/profile',
    method: 'put',
    data,
  })
}

export function updateUserPwd(oldPassword, newPassword) {
  return request({
    url: '/system/user/profile/updatePwd',
    method: 'put',
    data: { oldPassword, newPassword },
  })
}

export function uploadAvatar(filePath) {
  const userStore = useUserStore()
  const url = `${String(baseURL).replace(/\/$/, '')}/system/user/profile/avatar`
  return new Promise((resolve, reject) => {
    uni.uploadFile({
      url,
      filePath,
      name: 'avatarfile',
      header: { Authorization: normalizeAuthToken(userStore.token) },
      success(res) {
        try {
          const data = typeof res.data === 'string' ? JSON.parse(res.data) : res.data
          resolve({ data })
        } catch (e) {
          reject(e)
        }
      },
      fail: reject,
    })
  })
}
