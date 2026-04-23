<template>
  <div class="app-container">
    <el-row :gutter="20">
      <el-col :span="8">
        <el-card class="box-card">
          <h2 class="title">自习室信息</h2>
          <div class="room-info" v-if="roomData">
            <div class="info-item">
              <span class="info-label">自习室:</span>
              <span class="info-value">{{ roomData.name }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">位置:</span>
              <span class="info-value">{{ roomData.location }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">布局:</span>
              <span class="info-value">{{ roomData.rowsCount }}行 × {{ roomData.colsCount }}列</span>
            </div>
            <div class="info-item">
              <span class="info-label">座位数:</span>
              <span class="info-value">{{ total }}个</span>
            </div>
            <div class="info-item">
              <span class="info-label">开放时间:</span>
              <span class="info-value">{{ formatTime(roomData.openTime) }} - {{ formatTime(roomData.closeTime) }}</span>
            </div>
          </div>
          <el-divider></el-divider>
          <el-table class="room-list" :data="roomList" @row-click="roomSelect" :show-header="false"
            :row-class-name="tableRowClassName" height="170">
            <el-table-column prop="name" />
            <el-table-column prop="status" width="80">
              <template slot-scope="scope">
                <el-tag v-if="scope.row.status === '开放'" size="small" type="success">{{ scope.row.status }}</el-tag>
                <el-tag v-if="scope.row.status === '关闭'" size="small" type="danger">{{ scope.row.status }}</el-tag>
              </template>
            </el-table-column>
          </el-table>
          <el-divider></el-divider>
        </el-card>
      </el-col>
      <el-col :span="16">
        <el-card class="box-card">
          <h2 class="title">座位分布图</h2>
          <div class="legend">
            <div class="legend-item">
              <div class="legend-color" style="background-color: #67C23A;"></div>
              <span>正常</span>
            </div>
            <div class="legend-item">
              <div class="legend-color" style="background-color: #F56C6C;"></div>
              <span>故障</span>
            </div>
            <div class="legend-item">
              <div class="legend-color" style="border: 2px dashed #E9E9EB;"></div>
              <span>空位</span>
            </div>
          </div>
          <div class="seat-map-container" v-loading="loading">
            <div class="seat-map" :style="gridStyle">
              <div v-for="seat in seatGrid" :key="seat.id" class="seat" :class="getSeatClass(seat)"
                @click="setSeat(seat)">
                {{ seat.seatNum }}
              </div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="自习室ID" prop="roomId">
        <el-input v-model="queryParams.roomId" placeholder="请输入自习室ID" clearable @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-input v-model="queryParams.status" placeholder="请输入状态" clearable @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="el-icon-plus" size="mini" @click="handleAdd"
          v-hasPermi="['reservation:seat:add']">新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="success" plain icon="el-icon-edit" size="mini" :disabled="single" @click="handleUpdate"
          v-hasPermi="['reservation:seat:edit']">修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="danger" plain icon="el-icon-delete" size="mini" :disabled="multiple" @click="handleDelete"
          v-hasPermi="['reservation:seat:remove']">删除</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="warning" plain icon="el-icon-download" size="mini" @click="handleExport"
          v-hasPermi="['reservation:seat:export']">导出</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="seatList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="编号" align="center" prop="id" />
      <el-table-column label="座位号" align="center" prop="seatNum" />
      <el-table-column label="自习室ID" align="center" prop="roomId" />
      <el-table-column label="行号" align="center" prop="rowNum" />
      <el-table-column label="列号" align="center" prop="colNum" />
      <el-table-column label="状态" align="center" prop="status" />
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template slot-scope="scope">
          <el-button size="mini" type="text" icon="el-icon-edit" @click="handleUpdate(scope.row)"
            v-hasPermi="['reservation:seat:edit']">修改</el-button>
          <el-button size="mini" type="text" icon="el-icon-delete" @click="handleDelete(scope.row)"
            v-hasPermi="['reservation:seat:remove']">删除</el-button>
        </template>
</el-table-column>
</el-table>

<pagination v-show="total > 0" :total="total" :page.sync="queryParams.pageNum" :limit.sync="queryParams.pageSize"
  @pagination="getList" /> -->

    <!-- 添加或修改自习室座位对话框 -->
    <el-dialog :title="title" :visible.sync="open" width="500px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="位置">
          <el-tag>{{ roomData.name }}</el-tag>
          <span> - </span>
          <el-tag type="success">第 {{ form.rowNum }} 行 - 第 {{ form.colNum }} 个座位</el-tag>
        </el-form-item>
        <el-form-item label="座位号" prop="seatNum">
          <el-input v-model="form.seatNum" placeholder="请输入座位号" />
        </el-form-item>
        <!-- <el-form-item label="自习室ID" prop="roomId">
          <el-input v-model="form.roomId" placeholder="请输入自习室ID" />
        </el-form-item> -->
        <!-- <el-form-item label="行号" prop="rowNum">
          <el-input v-model="form.rowNum" placeholder="请输入行号" />
        </el-form-item>
        <el-form-item label="列号" prop="colNum">
          <el-input v-model="form.colNum" placeholder="请输入列号" />
        </el-form-item> -->
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio :label="0">正常</el-radio>
            <el-radio :label="1">故障</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="danger" v-if="form.id" @click="handleDelete(form)">删 除 座 位</el-button>
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listSeat, getSeat, delSeat, addSeat, updateSeat } from "@/api/reservation/seat"
import { listRoom } from "@/api/reservation/room"

export default {
  name: "Seat",
  data() {
    return {
      // 自习室信息
      roomList: [],
      roomData: {},

      // 遮罩层
      loading: true,
      // 选中数组
      ids: [],
      // 非单个禁用
      single: true,
      // 非多个禁用
      multiple: true,
      // 显示搜索条件
      showSearch: true,
      // 总条数
      total: 0,
      // 自习室座位表格数据
      seatList: [],
      // 弹出层标题
      title: "",
      // 是否显示弹出层
      open: false,
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        roomId: null,
        status: null
      },
      // 表单参数
      form: {},
      // 表单校验
      rules: {
        seatNum: [
          { required: true, message: "座位号不能为空", trigger: "blur" }
        ],
        roomId: [
          { required: true, message: "自习室ID不能为空", trigger: "blur" }
        ],
        rowNum: [
          { required: true, message: "行号不能为空", trigger: "blur" }
        ],
        colNum: [
          { required: true, message: "列号不能为空", trigger: "blur" }
        ],
        status: [
          { required: true, message: "状态不能为空", trigger: "blur" }
        ]
      }
    }
  },
  created() {
    // 获取自习室信息
    listRoom().then(response => {
      this.roomList = response.rows
      this.roomData = response.rows[0]
      this.queryParams.roomId = this.roomData.id
      this.queryParams.pageNum = 1
      this.getList()
    })
  },
  methods: {
    // 格式化时间，只显示时和分
    formatTime(time) {
      if (!time) return '';
      // 如果时间包含秒，则截取前5位（HH:mm）
      if (time.length > 5) {
        return time.substring(0, 5);
      }
      return time;
    },
    // 自习室选择
    roomSelect(row) {
      this.roomData = row
      this.queryParams.roomId = this.roomData.id
      this.queryParams.pageNum = 1
      this.getList()
    },
    tableRowClassName({ row }) {
      if (row.id == this.roomData.id) return 'on-row'
    },
    // 获取座位状态样式
    getSeatClass(seat) {
      if (seat.status === 0) return 'seat-normal';
      if (seat.status === 1) return 'seat-fault';
      if (seat.status === null) return 'seat-empty';
    },
    // 设置座位
    setSeat(seat) {
      this.reset()
      if (seat.status === null) {
        this.open = true
        this.title = "添加自习室座位"
        this.form.roomId = seat.roomId
        this.form.rowNum = seat.rowNum
        this.form.colNum = seat.colNum
      } else {
        getSeat(seat.id).then(response => {
          this.form = response.data
          this.open = true
          this.title = "修改自习室座位"
        })
      }
    },
    /** 查询自习室座位列表 */
    getList() {
      this.loading = true
      listSeat(this.queryParams).then(response => {
        this.queryParams.pageSize = response.total
        listSeat(this.queryParams).then(response => {
          this.seatList = response.rows
          this.total = response.total
          this.loading = false
        })
      })
    },
    // 取消按钮
    cancel() {
      this.open = false
      this.reset()
    },
    // 表单重置
    reset() {
      this.form = {
        id: null,
        seatNum: null,
        roomId: null,
        rowNum: null,
        colNum: null,
        status: null
      }
      this.resetForm("form")
    },
    /** 搜索按钮操作 */
    handleQuery() {
      this.queryParams.pageNum = 1
      this.getList()
    },
    /** 重置按钮操作 */
    resetQuery() {
      this.resetForm("queryForm")
      this.handleQuery()
    },
    // 多选框选中数据
    handleSelectionChange(selection) {
      this.ids = selection.map(item => item.id)
      this.single = selection.length !== 1
      this.multiple = !selection.length
    },
    /** 新增按钮操作 */
    handleAdd() {
      this.reset()
      this.open = true
      this.title = "添加自习室座位"
    },
    /** 修改按钮操作 */
    handleUpdate(row) {
      this.reset()
      const id = row.id || this.ids
      getSeat(id).then(response => {
        this.form = response.data
        this.open = true
        this.title = "修改自习室座位"
      })
    },
    /** 提交按钮 */
    submitForm() {
      this.$refs["form"].validate(valid => {
        if (valid) {
          if (this.form.id != null) {
            updateSeat(this.form).then(response => {
              this.$modal.msgSuccess("修改成功")
              this.open = false
              this.getList()
            })
          } else {
            addSeat(this.form).then(response => {
              this.$modal.msgSuccess("新增成功")
              this.open = false
              this.getList()
            })
          }
        }
      })
    },
    /** 删除按钮操作 */
    handleDelete(row) {
      const ids = row.id || this.ids
      this.$modal.confirm('是否确认删除自习室座位编号为"' + ids + '"的数据项？').then(function () {
        return delSeat(ids)
      }).then(() => {
        this.open = false
        this.getList()
        this.$modal.msgSuccess("删除成功")
      }).catch(() => { })
    },
    /** 导出按钮操作 */
    handleExport() {
      this.download('reservation/seat/export', {
        ...this.queryParams
      }, `seat_${new Date().getTime()}.xlsx`)
    }
  },
  computed: {
    // 根据自习室布局生成座位网格
    gridStyle() {
      if (!this.roomData) return {}
      return {
        gridTemplateColumns: `repeat(${this.roomData.colsCount}, 1fr)`
      }
    },
    // 根据自习室布局生成座位网格
    seatGrid() {
      const rows = this.roomData.rowsCount // 行数
      const cols = this.roomData.colsCount // 列数
      // 创建一个空座位网格，用于填充
      const grid = []
      // 生成所有位置（包括空位）
      for (let rowNum = 1; rowNum <= rows; rowNum++) {
        for (let colNum = 1; colNum <= cols; colNum++) {
          // 默认创建空位
          grid.push({
            roomId: this.roomData.id,
            rowNum,
            colNum,
            status: null,
          })
        }
      }
      // 用实际座位数据替换空位
      this.seatList.forEach(seat => {
        // 座位编号 = (行号 - 1) × 列数 + 列号
        const index = (seat.rowNum - 1) * cols + seat.colNum - 1
        if (index >= 0 && index < grid.length) {
          grid[index] = seat
        }
      })
      // console.log(grid)
      return grid
    }
  },
}
</script>

<style lang="scss" scoped>
.box-card {
  min-height: 600px;
}

.title {
  margin: 10px 0 20px;
  color: #409EFF;
  font-size: 20px;
  font-weight: bold;
  text-align: center;
}

.room-info {
  margin-bottom: 25px;

  .info-item {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 10px;
    padding: 10px 15px;
    font-size: 14px;
    background: #f8fafc;
    border-radius: 8px;
    transition: background 0.3s;
  }

  .info-item:hover {
    background: #f0f5ff;
  }

  .info-label {
    font-weight: bold;
    color: #4a5568;
  }

  .info-value {
    color: #2d3748;
    font-weight: 500;
  }
}

// 座位图例
.legend {
  display: flex;
  justify-content: space-around;
  margin: 20px auto;
  max-width: 400px;

  .legend-item {
    display: flex;
    align-items: center;
    gap: 5px;
    font-size: 0.9rem;
  }

  .legend-color {
    width: 16px;
    height: 16px;
    border-radius: 4px;
  }
}

// 座位地图
.seat-map-container {
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 20px auto;
  max-width: 600px;
  max-height: 600px;
  overflow: auto;

  .seat-map {
    display: grid;
    gap: 10px;
    padding: 15px;
    background: #f7fafc;
    border-radius: 8px;
    box-shadow: inset 0 0 10px rgba(0, 0, 0, 0.05);
    justify-content: center;
  }

  .seat {
    width: 45px;
    height: 45px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 6px;
    font-weight: bold;
    cursor: pointer;
    transition: all 0.2s;
    box-shadow: 0 2px 5px rgba(0, 0, 0, 0.2);
    font-size: 0.8rem;
  }

  .seat:hover {
    transform: scale(1.1);
  }

  .seat-normal {
    background: #67C23A99;
    color: #FFFFFF;
    border: 2px solid #67C23A;
  }

  .seat-fault {
    background: #F56C6C99;
    color: #FFFFFF;
    border: 2px solid #F56C6C;
  }

  .seat-empty {
    border: 2px dashed #E9E9EB;
    box-shadow: none;
  }

  @media (max-width: 1200px) {
    .seat {
      width: 40px;
      height: 40px;
    }
  }

  @media (max-width: 1080px) {
    .seat {
      width: 30px;
      height: 30px;
    }
  }
}
</style>

<style>
.el-table .on-row {
  color: #ffffff;
  font-weight: bold;
  background: #409EFF;
}
</style>