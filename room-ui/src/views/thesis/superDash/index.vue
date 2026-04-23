<template>
  <div class="app-container">
    <el-row :gutter="12" class="mb8">
      <el-col :span="24">
        <el-button type="warning" plain size="small" icon="el-icon-download" @click="exportCsv">导出看板数据(CSV)</el-button>
        <el-button type="success" plain size="small" icon="el-icon-download" @click="exportExcelServer">导出 Excel</el-button>
      </el-col>
    </el-row>
    <el-row :gutter="12">
      <el-col :span="12"><el-card header="今日座位负荷（预约占比%）"><div ref="chart1" style="height:280px" /></el-card></el-col>
      <el-col :span="12"><el-card header="月度预约量趋势"><div ref="chart2" style="height:280px" /></el-card></el-col>
    </el-row>
    <el-row :gutter="12" style="margin-top:12px">
      <el-col :span="12"><el-card header="各自习室舒适度分布"><div ref="chart3" style="height:280px" /></el-card></el-col>
      <el-col :span="12"><el-card header="有效学习时长排行（分钟，Top20）"><div ref="chart4" style="height:280px" /></el-card></el-col>
    </el-row>
    <el-row :gutter="12" style="margin-top:12px">
      <el-col :span="24"><el-card header="今日热门时段（按预约开始小时）"><div ref="chart5" style="height:260px" /></el-card></el-col>
    </el-row>
    <el-card header="高峰预警" style="margin-top:12px">
      <el-table :data="alerts" size="small">
        <el-table-column prop="roomId" label="room" />
        <el-table-column prop="ratePercent" label="预约率%" />
        <el-table-column prop="message" label="内容" />
        <el-table-column label="操作" width="100">
          <template slot-scope="s"><el-button type="text" size="mini" @click="read(s.row)">已读</el-button></template>
        </el-table-column>
      </el-table>
    </el-card>
    <el-card header="业务审计（关键操作留痕）" style="margin-top:12px">
      <el-form :inline="true" size="small" class="mb8">
        <el-form-item label="操作类型">
          <el-input v-model="auditQuery.actionType" placeholder="如 违规登记" clearable style="width:160px" />
        </el-form-item>
        <el-form-item label="用户ID">
          <el-input v-model="auditQuery.userId" placeholder="可选" clearable style="width:120px" />
        </el-form-item>
        <el-form-item label="开始">
          <el-date-picker v-model="auditQuery.beginTime" type="datetime" value-format="yyyy-MM-dd HH:mm:ss" placeholder="可选" style="width:180px" />
        </el-form-item>
        <el-form-item label="结束">
          <el-date-picker v-model="auditQuery.endTime" type="datetime" value-format="yyyy-MM-dd HH:mm:ss" placeholder="可选" style="width:180px" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" icon="el-icon-search" @click="loadAudit">查询</el-button>
        </el-form-item>
      </el-form>
      <el-table :data="auditRows" size="small" max-height="360">
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column prop="userId" label="用户ID" width="90" />
        <el-table-column prop="actionType" label="操作类型" min-width="120" />
        <el-table-column prop="refType" label="关联类型" width="100" />
        <el-table-column prop="refId" label="关联ID" width="90" />
        <el-table-column prop="detail" label="详情" min-width="160" show-overflow-tooltip />
        <el-table-column prop="createTime" label="时间" width="160" />
      </el-table>
    </el-card>
  </div>
</template>

<script>
import * as echarts from 'echarts'
import { dashboardSummary, listBizAudit, exportDashboardExcel } from '@/api/thesis/admin'
import request from '@/utils/request'
import { blobValidate } from '@/utils/ruoyi'
import { saveAs } from 'file-saver'
export default {
  name: 'ThesisSuperDash',
  data() {
    return {
      alerts: [],
      auditRows: [],
      auditQuery: { actionType: null, userId: null, beginTime: null, endTime: null },
      lastSummary: null,
      c1: null, c2: null, c3: null, c4: null, c5: null
    }
  },
  mounted() {
    this.load()
    this.loadAudit()
  },
  beforeDestroy() {
    ;[this.c1, this.c2, this.c3, this.c4, this.c5].forEach(c => { if (c) c.dispose() })
  },
  methods: {
    load() {
      dashboardSummary().then(r => {
        this.lastSummary = r
        this.alerts = r.alerts || []
        const usage = r.roomUsage || []
        const names = usage.map(x => x.name)
        const rates = usage.map(x => {
          const t = x.totalSeats || 1; const rv = x.reservedToday || 0
          return Math.round(rv * 100 / t)
        })
        const comfort = r.comfort || []
        const studyRank = r.studyRank || []
        const hourly = r.hourly || []
        const hours = Array.from({ length: 24 }, (_, i) => i + '时')
        const hourCnt = Array(24).fill(0)
        hourly.forEach(h => {
          const hr = Number(h.hr)
          if (!isNaN(hr) && hr >= 0 && hr < 24) hourCnt[hr] = Number(h.cnt) || 0
        })
        this.$nextTick(() => {
          if (!this.c1) this.c1 = echarts.init(this.$refs.chart1)
          this.c1.setOption({ tooltip: {}, xAxis: { type: 'category', data: names }, yAxis: { type: 'value', max: 100 }, series: [{ type: 'bar', data: rates, name: '预约占比%' }] })
          const m = r.monthly || []
          if (!this.c2) this.c2 = echarts.init(this.$refs.chart2)
          this.c2.setOption({ tooltip: {}, xAxis: { type: 'category', data: m.map(i => i.ym) }, yAxis: { type: 'value' }, series: [{ type: 'line', data: m.map(i => i.cnt), name: '预约数' }] })
          if (!this.c3) this.c3 = echarts.init(this.$refs.chart3)
          const cnames = comfort.map(x => x.name)
          const cscores = comfort.map(x => x.comfortScore != null ? Number(x.comfortScore) : 0)
          this.c3.setOption({ tooltip: {}, xAxis: { type: 'category', data: cnames }, yAxis: { type: 'value', max: 5 }, series: [{ type: 'bar', data: cscores, name: '舒适度' }] })
          if (!this.c4) this.c4 = echarts.init(this.$refs.chart4)
          const top = studyRank.slice(0, 20)
          this.c4.setOption({ tooltip: {}, xAxis: { type: 'category', data: top.map(u => 'u' + u.userId), axisLabel: { rotate: 40 } }, yAxis: { type: 'value' }, series: [{ type: 'bar', data: top.map(u => u.totalMinutes || 0), name: '分钟' }] })
          if (!this.c5) this.c5 = echarts.init(this.$refs.chart5)
          this.c5.setOption({ tooltip: {}, xAxis: { type: 'category', data: hours }, yAxis: { type: 'value' }, series: [{ type: 'bar', data: hourCnt, name: '预约笔数' }] })
        })
      })
    },
    loadAudit() {
      const q = {}
      if (this.auditQuery.actionType) q.actionType = this.auditQuery.actionType
      if (this.auditQuery.userId) q.userId = this.auditQuery.userId
      if (this.auditQuery.beginTime) q.beginTime = this.auditQuery.beginTime
      if (this.auditQuery.endTime) q.endTime = this.auditQuery.endTime
      listBizAudit(q).then(res => {
        this.auditRows = (res && res.data) ? res.data : []
      })
    },
    read(row) {
      request({ url: '/thesis/admin/alert/read/' + row.id, method: 'post' }).then(() => this.load())
    },
    exportCsv() {
      if (!this.lastSummary) {
        this.$message.warning('请先等待数据加载')
        return
      }
      const r = this.lastSummary
      const lines = []
      lines.push('section,key,value')
      ;(r.roomUsage || []).forEach((x, i) => {
        lines.push(`roomUsage,${i},${JSON.stringify(x)}`)
      })
      ;(r.monthly || []).forEach((x, i) => {
        lines.push(`monthly,${i},${JSON.stringify(x)}`)
      })
      ;(r.comfort || []).forEach((x, i) => {
        lines.push(`comfort,${i},${JSON.stringify(x)}`)
      })
      ;(r.studyRank || []).forEach((x, i) => {
        lines.push(`studyRank,${i},${JSON.stringify(x)}`)
      })
      ;(r.hourly || []).forEach((x, i) => {
        lines.push(`hourly,${i},${JSON.stringify(x)}`)
      })
      const blob = new Blob(['\ufeff' + lines.join('\n')], { type: 'text/csv;charset=utf-8' })
      const a = document.createElement('a')
      a.href = URL.createObjectURL(blob)
      a.download = 'dashboard_global_' + new Date().toISOString().slice(0, 10) + '.csv'
      a.click()
      URL.revokeObjectURL(a.href)
    },
    async exportExcelServer() {
      try {
        const data = await exportDashboardExcel()
        if (blobValidate(data)) {
          saveAs(new Blob([data]), 'dashboard_global_' + new Date().toISOString().slice(0, 10) + '.xlsx')
        } else {
          const resText = await data.text()
          const rspObj = JSON.parse(resText)
          this.$message.error(rspObj.msg || '导出失败')
        }
      } catch (e) {
        this.$message.error('导出失败')
      }
    }
  }
}
</script>
