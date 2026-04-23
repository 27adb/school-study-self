import { listReservation } from '@/api/reservation'

const SIGN_IN_GRACE_MINUTES = 15
const CHECK_COOLDOWN_MS = 30 * 1000
let running = false
let lastRunAt = 0

function parseDate(v) {
  if (!v) return null
  const d = new Date(String(v).replace(/-/g, '/'))
  return Number.isNaN(d.getTime()) ? null : d
}

function signInDeadline(inTime) {
  const d = parseDate(inTime)
  if (!d) return null
  return new Date(d.getTime() + SIGN_IN_GRACE_MINUTES * 60 * 1000)
}

/**
 * 学生端违规处理标准规则：
 * 1) 已预约且超过预约开始 15 分钟未签到 -> 识别为应违约
 * 2) 使用中且超过预约结束时间未签退 -> 识别为应违约
 *
 * 说明：当前后端接口不允许学生端自动改预约状态（会返回“仅支持取消预约”），
 * 因此这里仅做检测与提示，不执行状态写回，避免循环请求。
 */
export async function runStudentViolationCheck(userId) {
  if (!userId) return { noShowMarked: 0, overtimeMarked: 0 }
  const now = Date.now()
  if (running || now - lastRunAt < CHECK_COOLDOWN_MS) {
    return { noShowMarked: 0, overtimeMarked: 0 }
  }
  running = true
  lastRunAt = now
  try {
    const res = await listReservation({ userId, pageNum: 1, pageSize: 200 })
    const rows = res?.data?.rows || []
    let noShowMarked = 0
    let overtimeMarked = 0

    for (const item of rows) {
      const status = item?.reservationStatus
      if (status === '已预约') {
        const deadline = signInDeadline(item.reservationInTime)
        if (deadline && now > deadline.getTime()) {
          noShowMarked += 1
        }
      } else if (status === '使用中') {
        const outAt = parseDate(item.reservationOutTime)
        if (outAt && now > outAt.getTime()) {
          overtimeMarked += 1
        }
      }
    }
    return { noShowMarked, overtimeMarked }
  } finally {
    running = false
  }
}

