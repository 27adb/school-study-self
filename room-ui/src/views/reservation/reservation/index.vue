<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch">
      <el-form-item label="用户ID" prop="userId" v-show="false">
        <el-input v-model="queryParams.userId" placeholder="请输入用户ID" clearable @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item label="座位ID" prop="seatId" v-show="false">
        <el-input v-model="queryParams.seatId" placeholder="请输入座位ID" clearable @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item label="学号" prop="userName">
        <el-input v-model="queryParams.userName" placeholder="请输入学号" clearable @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="请选择状态" clearable>
          <el-option label="正常" value="正常" />
          <el-option label="违约" value="违约" />
        </el-select>
      </el-form-item>
      <el-form-item label="预约状态" prop="reservationStatus">
        <el-select v-model="queryParams.reservationStatus" placeholder="请选择状态" clearable>
          <el-option label="已预约" value="已预约" />
          <el-option label="使用中" value="使用中" />
          <el-option label="违约中" value="违约中" />
          <el-option label="取消预约" value="取消预约" />
          <el-option label="完成预约" value="完成预约" />
        </el-select>
      </el-form-item>
      <el-form-item label="订单审核" prop="auditStatus">
        <el-select v-model="queryParams.auditStatus" placeholder="请选择" clearable>
          <el-option label="无需审核" value="无需审核" />
          <el-option label="待审核" value="待审核" />
          <el-option label="已通过" value="已通过" />
          <el-option label="已拒绝" value="已拒绝" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <!-- <el-col :span="1.5">
        <el-button type="primary" plain icon="el-icon-plus" size="mini" @click="handleAdd"
          v-hasPermi="['reservation:reservation:add']">新增</el-button>
      </el-col> -->
      <!-- <el-col :span="1.5">
        <el-button type="success" plain icon="el-icon-edit" size="mini" :disabled="single" @click="handleUpdate"
          v-hasPermi="['reservation:reservation:edit']">修改</el-button>
      </el-col> -->
      <el-col :span="1.5">
        <el-button type="danger" plain icon="el-icon-delete" size="mini" :disabled="multiple" @click="handleDelete"
          v-hasPermi="['reservation:reservation:remove']">删除</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="warning" plain icon="el-icon-download" size="mini" @click="handleExport"
          v-hasPermi="['reservation:reservation:export']">导出</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="reservationList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <!-- <el-table-column label="编号" align="center" prop="id" /> -->
      <el-table-column label="用户ID" align="center" prop="userId" />
      <!-- <el-table-column label="座位ID" align="center" prop="seatId" /> -->
      <el-table-column label="状态" align="center" prop="status">
        <template slot-scope="scope">
          <el-tag v-if="scope.row.status == '正常'" type="success" size="small">正常</el-tag>
          <el-tag v-if="scope.row.status == '违约'" type="danger" size="small">违约</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="预约状态" align="center" prop="reservationStatus">
        <template slot-scope="scope">
          <el-tag v-if="scope.row.reservationStatus == '违约中'" type="warning" size="small">
            {{ scope.row.reservationStatus }}
          </el-tag>
          <span v-else>{{ scope.row.reservationStatus }}</span>
        </template>
      </el-table-column>
      <el-table-column label="订单审核" align="center" prop="auditStatus" width="100" />
      <el-table-column label="预约开始时间 ~ 预约结束时间" align="center" prop="reservationInTime" width="280">
        <template slot-scope="scope">
          <el-tag type="info">{{ scope.row.reservationInTime }} ~ {{ scope.row.reservationOutTime }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="签到时间 ~ 签退时间" align="center" prop="signInTime" width="280">
        <template slot-scope="scope">
          <el-tag type="info">{{ scope.row.signInTime }} ~ {{ scope.row.signOutTime }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="备注" align="center" prop="remark" show-overflow-tooltip width="180px" />
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template slot-scope="scope">
          <el-button size="mini" type="text" icon="el-icon-edit" @click="handleUpdate(scope.row)"
            v-hasPermi="['reservation:reservation:edit']">修改</el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-check"
            v-if="scope.row.auditStatus === '待审核'"
            v-hasPermi="['reservation:reservation:audit']"
            @click="handleAuditPass(scope.row)"
          >审核通过</el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-close"
            v-if="scope.row.auditStatus === '待审核'"
            v-hasPermi="['reservation:reservation:audit']"
            @click="handleAuditReject(scope.row)"
          >审核拒绝</el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-unlock"
            v-if="scope.row.reservationStatus == '违约中' || scope.row.status == '违约'"
            @click="handleUnlock(scope.row)"
          >解锁订单</el-button>
          <el-button size="mini" type="text" icon="el-icon-delete" @click="handleDelete(scope.row)"
            v-hasPermi="['reservation:reservation:remove']">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" :page.sync="queryParams.pageNum" :limit.sync="queryParams.pageSize"
      @pagination="getList" />

    <!-- 添加或修改自习室预约管理对话框 -->
    <el-dialog :title="title" :visible.sync="open" width="500px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="auto">
        <!-- <el-form-item label="用户ID" prop="userId">
          <el-input v-model="form.userId" placeholder="请输入用户ID" />
        </el-form-item>
        <el-form-item label="座位ID" prop="seatId">
          <el-input v-model="form.seatId" placeholder="请输入座位ID" />
        </el-form-item> -->
        <el-form-item label="状态" prop="status">
          <el-select v-model="form.status" placeholder="请选择状态" clearable>
            <el-option label="正常" value="正常" />
            <el-option label="违约" value="违约" />
          </el-select>
        </el-form-item>
        <el-form-item label="预约状态" prop="reservationStatus">
          <el-select v-model="form.reservationStatus" placeholder="请选择状态" clearable>
            <el-option label="已预约" value="已预约" />
            <el-option label="使用中" value="使用中" />
            <el-option label="违约中" value="违约中" />
            <el-option label="取消预约" value="取消预约" />
            <el-option label="完成预约" value="完成预约" />
          </el-select>
        </el-form-item>
        <el-form-item label="预约开始时间" prop="reservationInTime">
          <el-date-picker clearable v-model="form.reservationInTime" type="datetime" value-format="yyyy-MM-dd HH:mm:ss"
            placeholder="请选择预约开始时间">
          </el-date-picker>
        </el-form-item>
        <el-form-item label="预约结束时间" prop="reservationOutTime">
          <el-date-picker clearable v-model="form.reservationOutTime" type="datetime" value-format="yyyy-MM-dd HH:mm:ss"
            placeholder="请选择预约结束时间">
          </el-date-picker>
        </el-form-item>
        <el-form-item label="签到时间" prop="signInTime">
          <el-date-picker clearable v-model="form.signInTime" type="datetime" value-format="yyyy-MM-dd HH:mm:ss"
            placeholder="请选择签到时间">
          </el-date-picker>
        </el-form-item>
        <el-form-item label="签退时间" prop="signOutTime">
          <el-date-picker clearable v-model="form.signOutTime" type="datetime" value-format="yyyy-MM-dd HH:mm:ss"
            placeholder="请选择签退时间">
          </el-date-picker>
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="form.remark" type="textarea" :rows="4" maxlength="100" show-word-limit
            placeholder="请输入备注" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listReservation, getReservation, delReservation, addReservation, updateReservation, auditReservation } from "@/api/reservation/reservation"
import { listUser } from "@/api/system/user"
import { releaseBlacklistByUser } from "@/api/thesis/admin"

export default {
  name: "Reservation",
  data() {
    return {
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
      // 自习室预约管理表格数据
      reservationList: [],
      // 弹出层标题
      title: "",
      // 是否显示弹出层
      open: false,
      // 查询参数
      queryParams: {
        userName: null,
        pageNum: 1,
        pageSize: 10,
        userId: null,
        seatId: null,
        status: null,
        reservationStatus: null,
        auditStatus: null,
      },
      // 表单参数
      form: {},
      // 表单校验
      rules: {
        userId: [
          { required: true, message: "用户ID不能为空", trigger: "blur" }
        ],
        seatId: [
          { required: true, message: "座位ID不能为空", trigger: "blur" }
        ],
        status: [
          { required: true, message: "状态不能为空", trigger: "blur" }
        ],
        reservationStatus: [
          { required: true, message: "预约状态不能为空", trigger: "blur" }
        ],
        reservationInTime: [
          { required: true, message: "预约开始时间不能为空", trigger: "blur" }
        ],
        reservationOutTime: [
          { required: true, message: "预约结束时间不能为空", trigger: "blur" }
        ],
      }
    }
  },
  created() {
    this.getList()
  },
  methods: {
    /** 查询自习室预约管理列表 */
    getList() {
      this.loading = true
      listReservation(this.queryParams)
        .then(response => {
          this.reservationList = response.rows || []
          this.total = response.total || 0
        })
        .finally(() => {
          this.loading = false
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
        userId: null,
        seatId: null,
        status: null,
        reservationStatus: null,
        reservationInTime: null,
        reservationOutTime: null,
        signInTime: null,
        signOutTime: null,
        remark: null,
        auditStatus: null
      }
      this.resetForm("form")
    },
    /** 搜索按钮操作 */
    handleQuery() {
      this.queryParams.pageNum = 1
      const name = (this.queryParams.userName || '').trim()
      // 未按学号查询时，必须清空 userId；否则曾为 0 时会一直带上 user_id = 0，列表永远为空
      if (!name) {
        this.queryParams.userId = null
        this.getList()
        return
      }
      this.loading = true
      listUser({ userName: name, pageNum: 1, pageSize: 20 }).then(response => {
        const rows = response.rows || []
        const hit = rows.find(r => r.userName === name)
        if (hit) {
          this.queryParams.userId = hit.userId
          this.getList()
        } else {
          this.queryParams.userId = null
          this.reservationList = []
          this.total = 0
          this.loading = false
          this.$modal.msgWarning('未找到该学号对应的用户')
        }
      }).catch(() => {
        this.loading = false
      })
    },
    /** 重置按钮操作 */
    resetQuery() {
      this.queryParams.userId = null
      this.queryParams.seatId = null
      this.resetForm("queryForm")
      this.queryParams.pageNum = 1
      this.queryParams.pageSize = 10
      this.getList()
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
      this.title = "添加自习室预约管理"
    },
    /** 修改按钮操作 */
    handleUpdate(row) {
      this.reset()
      const id = row.id || this.ids
      getReservation(id).then(response => {
        this.form = response.data
        this.open = true
        this.title = "修改自习室预约管理"
      })
    },
    /** 提交按钮 */
    submitForm() {
      this.$refs["form"].validate(valid => {
        if (valid) {
          if (this.form.id != null) {
            updateReservation(this.form).then(response => {
              this.$modal.msgSuccess("修改成功")
              this.open = false
              this.getList()
            })
          } else {
            addReservation(this.form).then(response => {
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
      this.$modal.confirm('是否确认删除自习室预约管理编号为"' + ids + '"的数据项？').then(function () {
        return delReservation(ids)
      }).then(() => {
        this.getList()
        this.$modal.msgSuccess("删除成功")
      }).catch(() => { })
    },
    /** 导出按钮操作 */
    handleExport() {
      this.download('reservation/reservation/export', {
        ...this.queryParams
      }, `reservation_${new Date().getTime()}.xlsx`)
    },

    // 解锁订单：用于管理员解除学生禁约，让后续预约不再被“违约中>=3”限制
    handleUnlock(row) {
      const id = row.id
      this.$modal.confirm('确认解锁该订单？').then(() => {
        const jobs = [
          updateReservation({
            id,
            status: '正常',
            // 只要不是“违约中”，前端禁约校验就会放开
            reservationStatus: '取消预约',
          })
        ]
        if (row.userId) {
          jobs.push(releaseBlacklistByUser({ userId: row.userId, remark: '管理员在预约管理页解除禁约' }))
        }
        return Promise.all(jobs)
      }).then(() => {
        this.$modal.msgSuccess('解锁成功')
        this.getList()
      }).catch(() => { })
    },

    handleAuditPass(row) {
      this.$modal.confirm('确认审核通过该预约？').then(() => {
        return auditReservation({ id: row.id, auditStatus: '已通过' })
      }).then(() => {
        this.$modal.msgSuccess('操作成功')
        this.getList()
      }).catch(() => { })
    },

    handleAuditReject(row) {
      this.$modal.confirm('确认拒绝该预约？将自动取消并释放座位。').then(() => {
        return auditReservation({ id: row.id, auditStatus: '已拒绝' })
      }).then(() => {
        this.$modal.msgSuccess('已拒绝')
        this.getList()
      }).catch(() => { })
    }
  }
}
</script>
