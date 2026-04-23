import { createSSRApp } from 'vue'
import { createPinia } from 'pinia'
import { createPersistedState } from 'pinia-plugin-persistedstate'
import App from './App.vue'

const uniStorage = {
  getItem(key) {
    const v = uni.getStorageSync(key)
    if (v === '' || v === undefined || v === null) return null
    return typeof v === 'string' ? v : JSON.stringify(v)
  },
  setItem(key, value) {
    uni.setStorageSync(key, value)
  },
}

export function createApp() {
  const app = createSSRApp(App)
  const pinia = createPinia()
  pinia.use(
    createPersistedState({
      storage: uniStorage,
    })
  )
  app.use(pinia)
  return { app }
}
