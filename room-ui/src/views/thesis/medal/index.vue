<template>
  <div class="app-container">
    <el-row class="mb8">
      <el-button v-hasPermi="['thesis:medal:add']" type="primary" size="small" icon="el-icon-plus" @click="openAdd">新增勋章</el-button>
    </el-row>
    <el-table v-loading="loading" :data="rows" size="small">
      <el-table-column prop="code" label="编码" width="100" />
      <el-table-column prop="name" label="名称" width="140" />
      <el-table-column prop="needMinutes" label="所需分钟" width="110" />
      <el-table-column prop="perkDesc" label="权益说明" min-width="180" show-overflow-tooltip />
      <el-table-column prop="sortOrder" label="排序" width="70" />
      <el-table-column label="操作" width="160">
        <template slot-scope="s">
          <el-button v-hasPermi="['thesis:medal:edit']" type="text" size="mini" @click="openEdit(s.row)">编辑</el-button>
          <el-button v-hasPermi="['thesis:medal:remove']" type="text" size="mini" @click="rm(s.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <el-dialog :title="dlgTitle" :visible.sync="open" width="480px" append-to-body @close="form = {}">
      <el-form :model="form" label-width="100px" size="small">
        <el-form-item label="编码 code" required><el-input v-model="form.code" :disabled="!!form._edit" maxlength="32" /></el-form-item>
        <el-form-item label="名称" required><el-input v-model="form.name" maxlength="64" /></el-form-item>
        <el-form-item label="所需分钟" required><el-input-number v-model="form.needMinutes" :min="1" :max="999999" /></el-form-item>
        <el-form-item label="权益说明"><el-input v-model="form.perkDesc" type="textarea" :rows="2" /></el-form-item>
        <el-form-item label="排序"><el-input-number v-model="form.sortOrder" :min="0" :max="999" /></el-form-item>
      </el-form>
      <div slot="footer"><el-button type="primary" @click="submit">确定</el-button></div>
    </el-dialog>
  </div>
</template>

<script>
import { listMedalDef, addMedalDef, updateMedalDef, removeMedalDef } from '@/api/thesis/admin'
export default {
  name: 'ThesisMedal',
  data() {
    return {
      loading: false,
      rows: [],
      open: false,
      dlgTitle: '',
      form: {}
    }
  },
  created() { this.load() },
  methods: {
    load() {
      this.loading = true
      listMedalDef().then(res => {
        this.rows = res.data || []
        this.loading = false
      })
    },
    openAdd() {
      this.dlgTitle = '新增勋章'
      this.form = { code: '', name: '', needMinutes: 120, perkDesc: '', sortOrder: 0, _edit: false }
      this.open = true
    },
    openEdit(row) {
      this.dlgTitle = '编辑勋章'
      this.form = { ...row, _edit: true }
      this.open = true
    },
    submit() {
      const p = {
        code: this.form.code,
        name: this.form.name,
        needMinutes: this.form.needMinutes,
        perkDesc: this.form.perkDesc || '',
        sortOrder: this.form.sortOrder || 0
      }
      const req = this.form._edit ? updateMedalDef(p) : addMedalDef(p)
      req.then(() => { this.$modal.msgSuccess('保存成功'); this.open = false; this.load() })
    },
    rm(row) {
      this.$modal.confirm('确认删除勋章「' + row.name + '」？').then(() => {
        removeMedalDef(row.code).then(() => { this.$modal.msgSuccess('已删除'); this.load() })
      }).catch(() => {})
    }
  }
}
</script>
