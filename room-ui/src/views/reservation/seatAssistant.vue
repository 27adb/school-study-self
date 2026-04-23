<template>
  <div class="app-container">
    <el-card class="box-card">
      <div slot="header" class="clearfix">
        <span>预约辅助：座位统计与反馈</span>
      </div>
      <div class="toolbar">
        <el-select v-model="roomId" placeholder="选择自习室" style="width: 260px" @change="loadData">
          <el-option v-for="r in rooms" :key="r.id" :label="r.name" :value="r.id" />
        </el-select>
        <span class="stat">总座位 {{ overview.totalSeats || 0 }}</span>
        <span class="stat">空闲 {{ overview.freeSeats || 0 }}</span>
        <span class="stat">占用 {{ (overview.usingSeats || 0) + (overview.reservedSeats || 0) }}</span>
        <span class="stat">故障 {{ overview.faultSeats || 0 }}</span>
      </div>
      <div ref="seatChart" style="height: 360px" />
    </el-card>

    <el-card class="box-card" style="margin-top: 12px">
      <div slot="header"><span>座位状态调整</span></div>
      <el-table v-loading="loading" :data="seats" size="small" height="280">
        <el-table-column prop="seatNum" label="座位号" width="120" />
        <el-table-column label="位置">
          <template slot-scope="scope">{{ scope.row.rowNum }}行{{ scope.row.colNum }}列</template>
        </el-table-column>
        <el-table-column label="状态" width="120">
          <template slot-scope="scope">{{ scope.row.status === 1 ? '故障' : '正常' }}</template>
        </el-table-column>
        <el-table-column label="操作" width="140">
          <template slot-scope="scope">
            <el-button size="mini" @click="toggleSeat(scope.row)">{{ scope.row.status === 1 ? '恢复' : '故障' }}</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-card class="box-card" style="margin-top: 12px">
      <div slot="header"><span>反馈申诉处理</span></div>
      <el-table :data="feedback" size="small" height="280">
        <el-table-column prop="feedbackType" label="类型" width="120" />
        <el-table-column prop="content" label="内容" show-overflow-tooltip />
        <el-table-column prop="createBy" label="提交人" width="120" />
        <el-table-column prop="status" label="状态" width="100" />
        <el-table-column label="操作" width="140">
          <template slot-scope="scope">
            <el-button
              v-if="scope.row.status !== '已处理'"
              size="mini"
              type="primary"
              @click="finishFeedback(scope.row)"
            >标记已处理</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script>
import * as echarts from 'echarts'
import {
  listRoomAssistant,
  listSeatAssistant,
  updateSeatAssistant,
  getOverview,
  listFeedbackAssistant,
  updateFeedbackStatus,
} from '@/api/assistant'

export default {
  name: 'SeatAssistant',
  data() {
    return {
      loading: false,
      rooms: [],
      roomId: null,
      seats: [],
      feedback: [],
      overview: {
        totalSeats: 0,
        freeSeats: 0,
        usingSeats: 0,
        reservedSeats: 0,
        faultSeats: 0,
      },
      chart: null,
    }
  },
  created() {
    this.loadRooms()
  },
  beforeDestroy() {
    if (this.chart) {
      this.chart.dispose()
      this.chart = null
    }
  },
  methods: {
    loadRooms() {
      listRoomAssistant({ pageNum: 1, pageSize: 1000 }).then((res) => {
        this.rooms = res.rows || []
        if (!this.roomId && this.rooms.length) {
          this.roomId = this.rooms[0].id
        }
        this.loadData()
      })
    },
    loadData() {
      if (!this.roomId) return
      this.loading = true
      Promise.all([
        listSeatAssistant({ roomId: this.roomId, pageNum: 1, pageSize: 2000 }),
        getOverview(this.roomId),
        listFeedbackAssistant({ pageNum: 1, pageSize: 50 }),
      ])
        .then(([seatRes, overviewRes, fbRes]) => {
          this.seats = seatRes.rows || []
          if (overviewRes.code === 200) {
            this.overview = overviewRes.data || this.overview
          }
          this.feedback = fbRes.rows || []
          this.$nextTick(() => this.renderChart())
        })
        .finally(() => {
          this.loading = false
        })
    },
    renderChart() {
      const el = this.$refs.seatChart
      if (!el) return
      if (!this.chart) {
        this.chart = echarts.init(el, 'macarons')
      }
      this.chart.setOption({
        title: { text: '座位状态统计', left: 'center' },
        tooltip: { trigger: 'item' },
        legend: { bottom: 0 },
        series: [
          {
            type: 'pie',
            radius: ['35%', '62%'],
            data: [
              { name: '空闲', value: this.overview.freeSeats || 0 },
              { name: '使用中', value: this.overview.usingSeats || 0 },
              { name: '已预约', value: this.overview.reservedSeats || 0 },
              { name: '故障', value: this.overview.faultSeats || 0 },
            ],
          },
        ],
      })
    },
    toggleSeat(seat) {
      const status = seat.status === 1 ? 0 : 1
      updateSeatAssistant({ id: seat.id, status }).then((res) => {
        if (res.code === 200) {
          this.$modal.msgSuccess('已更新座位状态')
          this.loadData()
        }
      })
    },
    finishFeedback(row) {
      updateFeedbackStatus(row.id, { status: '已处理' }).then((res) => {
        if (res.code === 200) {
          this.$modal.msgSuccess('已标记处理')
          this.loadData()
        }
      })
    },
  },
}
</script>

<style scoped>
.toolbar {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 12px;
  margin-bottom: 8px;
}
.stat {
  font-size: 14px;
  color: #606266;
}
</style>
