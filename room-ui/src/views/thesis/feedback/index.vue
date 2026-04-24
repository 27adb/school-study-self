<template>
  <div class="app-container">
    <el-form :inline="true" size="small" class="mb8">
      <el-form-item label="用户ID"><el-input v-model="queryParams.userId" clearable placeholder="可选" style="width:120px" /></el-form-item>
      <el-form-item label="状态"><el-input v-model="queryParams.status" clearable placeholder="可选" style="width:120px" /></el-form-item>
      <el-form-item><el-button type="primary" icon="el-icon-search" @click="getList">搜索</el-button></el-form-item>
    </el-form>
    <el-table v-loading="loading" :data="rows" size="small">
      <el-table-column prop="id" label="ID" width="70" />
      <el-table-column prop="userId" label="用户" width="90" />
      <el-table-column prop="feedbackType" label="类型" width="100" />
      <el-table-column prop="content" label="内容" min-width="160" show-overflow-tooltip />
      <el-table-column prop="quietScore" label="安静" width="70" />
      <el-table-column prop="lightingScore" label="照明" width="70" />
      <el-table-column prop="appealEvidence" label="申诉凭证" min-width="120" show-overflow-tooltip />
      <el-table-column prop="status" label="状态" width="90" />
      <el-table-column prop="handleRemark" label="处理备注" min-width="120" show-overflow-tooltip />
      <el-table-column prop="createTime" label="时间" width="160" />
      <el-table-column label="操作" width="260" fixed="right">
        <template slot-scope="scope">
          <el-button
            size="mini"
            type="text"
            icon="el-icon-unlock"
            @click="handleUnlockByUser(scope.row)"
          >解除禁约</el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-check"
            :disabled="scope.row.status === '已处理'"
            @click="handleDone(scope.row)"
          >标记已处理</el-button>
        </template>
      </el-table-column>
    </el-table>
    <pagination v-show="total > 0" :total="total" :page.sync="queryParams.pageNum" :limit.sync="queryParams.pageSize" @pagination="getList" />
  </div>
</template>

<script>
import { listFeedback, updateFeedbackStatus, releaseBlacklistByUser } from '@/api/thesis/admin'
import { listReservation, updateReservation } from '@/api/reservation/reservation'
export default {
  name: 'ThesisFeedback',
  data() {
    return {
      loading: false,
      rows: [],
      total: 0,
      queryParams: { pageNum: 1, pageSize: 10, userId: null, status: null }
    }
  },
  created() { this.getList() },
  methods: {
    getList() {
      this.loading = true
      listFeedback(this.queryParams).then(res => {
        this.rows = res.rows || []
        this.total = res.total || 0
        this.loading = false
      })
    },
    handleDone(row) {
      updateFeedbackStatus(row.id, { status: '已处理' }).then(() => {
        this.$modal.msgSuccess('已标记处理')
        this.getList()
      })
    },
    handleUnlockByUser(row) {
      const uid = row.userId
      if (!uid) return this.$modal.msgWarning('缺少用户ID')
      this.$modal.confirm(`确认解除用户 ${uid} 的违约禁约状态？`).then(() => {
        return listReservation({ userId: uid, pageNum: 1, pageSize: 200 })
      }).then(async (res) => {
        const rows = res.rows || []
        const vioRows = rows.filter(r => r.status === '违约' || r.reservationStatus === '违约中')
        const jobs = []
        if (vioRows.length) {
          jobs.push(...vioRows.map(r => updateReservation({
            id: r.id,
            status: '正常',
            reservationStatus: '取消预约',
            remark: (r.remark || '') + '；管理员在反馈页解除禁约'
          })))
        }
        jobs.push(releaseBlacklistByUser({ userId: uid, remark: '管理员在反馈页解除禁约' }))
        await Promise.all(jobs)
        this.$modal.msgSuccess(vioRows.length ? `已解除禁约并恢复 ${vioRows.length} 条订单` : '已解除禁约')
        this.getList()
      }).catch(() => {})
    }
  }
}
</script>
