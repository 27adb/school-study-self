<template>
  <div class="app-container">
    <el-form :inline="true">
      <el-form-item label="用户ID"><el-input v-model="query.userId" clearable placeholder="用户ID" /></el-form-item>
      <el-form-item><el-button type="primary" @click="load">查询</el-button></el-form-item>
    </el-form>
    <el-table v-loading="loading" :data="rows" size="small">
      <el-table-column prop="id" label="ID" width="70" />
      <el-table-column prop="userId" label="用户" width="90" />
      <el-table-column prop="violationType" label="类型" width="120" />
      <el-table-column prop="description" label="说明" min-width="140" show-overflow-tooltip />
      <el-table-column prop="signLog" label="追溯（签到/反馈摘录）" min-width="220" show-overflow-tooltip />
      <el-table-column prop="evidenceUrls" label="凭证" width="120" show-overflow-tooltip />
      <el-table-column prop="createTime" label="时间" width="160" />
      <el-table-column label="操作" width="90" fixed="right">
        <template slot-scope="s">
          <el-button v-hasPermi="['thesis:violation:remove']" type="text" @click="removeRow(s.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <el-card class="box-card" style="margin-top:12px">
      <div slot="header">新增违规追溯卡</div>
      <el-form label-width="100px" size="small">
        <el-form-item label="用户ID"><el-input v-model="form.userId" /></el-form-item>
        <el-form-item label="预约单ID"><el-input v-model="form.reservationId" /></el-form-item>
        <el-form-item label="类型"><el-input v-model="form.violationType" placeholder="未签到/喧哗" /></el-form-item>
        <el-form-item label="说明"><el-input v-model="form.description" type="textarea" /></el-form-item>
        <el-form-item label="凭证URL"><el-input v-model="form.evidenceUrls" /></el-form-item>
        <el-form-item><el-button v-hasPermi="['thesis:violation:add']" type="primary" @click="submit">保存</el-button></el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script>
import { listViolation, addViolation, delViolation } from '@/api/thesis/admin'
export default {
  name: 'ThesisViolation',
  data() {
    return { loading: false, rows: [], query: {}, form: {} }
  },
  created() { this.load() },
  methods: {
    load() {
      this.loading = true
      listViolation(this.query).then(r => { this.rows = r.data || []; this.loading = false })
    },
    submit() {
      const p = { ...this.form }
      p.userId = parseInt(p.userId, 10)
      if (p.reservationId) p.reservationId = parseInt(p.reservationId, 10)
      addViolation(p).then(() => { this.$modal.msgSuccess('已保存'); this.form = {}; this.load() })
    },
    removeRow(row) {
      this.$modal.confirm('确认删除？').then(() => delViolation(row.id).then(() => { this.load() }))
    }
  }
}
</script>
