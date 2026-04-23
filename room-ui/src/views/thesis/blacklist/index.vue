<template>
  <div class="app-container">
    <el-table v-loading="loading" :data="rows" size="small">
      <el-table-column prop="id" label="ID" width="70" />
      <el-table-column prop="userId" label="用户" width="90" />
      <el-table-column prop="reason" label="原因" />
      <el-table-column prop="untilDate" label="截止" width="120" />
      <el-table-column prop="status" label="状态" width="80" />
      <el-table-column label="操作" width="120">
        <template slot-scope="s">
          <el-button v-hasPermi="['thesis:blacklist:edit']" type="text" @click="lift(s.row)">解除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <el-card style="margin-top:12px">
      <div slot="header">加入黑名单</div>
      <el-form inline size="small">
        <el-input v-model="b.userId" placeholder="用户ID" style="width:120px" />
        <el-input v-model="b.reason" placeholder="原因" style="width:200px;margin-left:8px" />
        <el-date-picker v-model="b.untilDate" type="date" value-format="yyyy-MM-dd" placeholder="解禁日" style="margin-left:8px" />
        <el-button v-hasPermi="['thesis:blacklist:add']" type="primary" style="margin-left:8px" @click="add">添加</el-button>
      </el-form>
    </el-card>
  </div>
</template>

<script>
import { listBlacklist, addBlacklist, updateBlacklist } from '@/api/thesis/admin'
export default {
  name: 'ThesisBlacklist',
  data() { return { loading: false, rows: [], b: {} } },
  created() { this.load() },
  methods: {
    load() {
      this.loading = true
      listBlacklist({}).then(r => { this.rows = r.data || []; this.loading = false })
    },
    add() {
      const p = { userId: parseInt(this.b.userId, 10), reason: this.b.reason, untilDate: this.b.untilDate, status: '0' }
      addBlacklist(p).then(() => { this.$modal.msgSuccess('OK'); this.b = {}; this.load() })
    },
    lift(row) {
      updateBlacklist({ id: row.id, userId: row.userId, status: '1' }).then(() => this.load())
    }
  }
}
</script>
