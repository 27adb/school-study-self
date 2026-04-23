<template>
  <div class="app-container">
    <el-button v-hasPermi="['thesis:cleaning:add']" type="primary" style="margin-bottom:12px" @click="gen">根据使用率生成排班</el-button>
    <el-table v-loading="loading" :data="rows" size="small">
      <el-table-column prop="id" label="ID" width="70" />
      <el-table-column prop="roomId" label="自习室ID" width="90" />
      <el-table-column prop="planDate" label="日期" width="120" />
      <el-table-column prop="timeSlot" label="班次" width="100" />
      <el-table-column prop="cleaner" label="保洁" width="140" />
      <el-table-column prop="status" label="状态" width="100" />
      <el-table-column prop="reason" label="依据" />
      <el-table-column label="操作" width="120" fixed="right">
        <template slot-scope="s">
          <el-button v-hasPermi="['thesis:cleaning:edit']" type="text" size="mini" @click="openEdit(s.row)">指派/更新</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog title="保洁排班指派" :visible.sync="dlg" width="480px" append-to-body @close="dlgRow=null">
      <el-form v-if="dlgRow" label-width="100px" size="small">
        <el-form-item label="保洁人员"><el-input v-model="form.cleaner" placeholder="姓名或班组" /></el-form-item>
        <el-form-item label="执行状态">
          <el-select v-model="form.status" placeholder="请选择" style="width:100%">
            <el-option label="待执行" value="待执行" />
            <el-option label="执行中" value="执行中" />
            <el-option label="已完成" value="已完成" />
            <el-option label="已取消" value="已取消" />
          </el-select>
        </el-form-item>
        <el-form-item label="备注"><el-input v-model="form.reason" type="textarea" rows="2" /></el-form-item>
      </el-form>
      <div slot="footer">
        <el-button @click="dlg=false">取消</el-button>
        <el-button type="primary" @click="saveEdit">保存</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listCleaning, generateCleaning, updateCleaning } from '@/api/thesis/admin'

export default {
  name: 'ThesisCleaning',
  data() {
    return { loading: false, rows: [], dlg: false, dlgRow: null, form: {} }
  },
  created() { this.load() },
  methods: {
    load() {
      this.loading = true
      listCleaning({}).then(r => { this.rows = r.data || []; this.loading = false })
    },
    gen() {
      generateCleaning().then(r => { this.$modal.msgSuccess(r.msg || '完成'); this.load() })
    },
    openEdit(row) {
      this.dlgRow = row
      this.form = { id: row.id, cleaner: row.cleaner, status: row.status, reason: row.reason }
      this.dlg = true
    },
    saveEdit() {
      updateCleaning({ id: this.form.id, cleaner: this.form.cleaner, status: this.form.status, reason: this.form.reason })
        .then(() => { this.$modal.msgSuccess('已更新'); this.dlg = false; this.load() })
    }
  }
}
</script>
