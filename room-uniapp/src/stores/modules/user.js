import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useUserStore = defineStore(
  'room-uniapp-user',
  () => {
    const token = ref('')
    const setToken = (t) => {
      token.value = t
    }
    const removeToken = () => {
      token.value = ''
    }

    const user = ref({})
    const setUser = (u) => {
      user.value = u
    }
    const removeUser = () => {
      user.value = {}
    }

    const roles = ref([])
    const setRoles = (arr) => {
      roles.value = Array.isArray(arr) ? arr : []
    }
    const removeRoles = () => {
      roles.value = []
    }

    const hasRole = (keys) => {
      const arr = Array.isArray(keys) ? keys : [keys]
      return arr.some((k) => roles.value.includes(k))
    }

    // admin 视为超管，兼具两类管理能力
    const isSuperAdmin = () => hasRole(['admin'])
    const isRoomAdmin = () => hasRole(['room_admin', 'roomAdmin', 'reservation_admin', 'admin'])
    const isSystemAdmin = () => hasRole(['system_admin', 'systemAdmin', 'admin'])
    const isAdmin = () => isRoomAdmin() || isSystemAdmin()

    return {
      token,
      setToken,
      removeToken,
      user,
      setUser,
      removeUser,
      roles,
      setRoles,
      removeRoles,
      hasRole,
      isSuperAdmin,
      isRoomAdmin,
      isSystemAdmin,
      isAdmin,
    }
  },
  { persist: true }
)
