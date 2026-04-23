<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="自习室" prop="roomName">
        <el-select v-model="queryParams.roomName" placeholder="请选择自习室" clearable size="small" filterable>
          <el-option label="静思自习室" value="1" />
          <el-option label="致远阅览室" value="2" />
          <el-option label="明德研讨室" value="3" />
          <el-option label="博学电子阅览室" value="4" />
          <el-option label="晨曦早读室" value="5" />
        </el-select>
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="请选择状态" clearable size="small">
          <el-option label="待处理" value="待处理" />
          <el-option label="维修中" value="维修中" />
          <el-option label="已解决" value="已解决" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button v-hasPermi="['thesis:repair:add']" type="primary" plain icon="el-icon-plus" size="mini"
          @click="handleAdd">新建工单</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button v-hasPermi="['thesis:repair:remove']" type="danger" plain icon="el-icon-delete" size="mini"
          :disabled="multiple" @click="handleDelete">删除</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="rows" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column prop="id" label="ID" width="70" />
      <el-table-column prop="roomName" label="自习室" width="90" />
      <el-table-column prop="seatNumber" label="座位编号" width="90" />
      <el-table-column prop="faultType" label="故障类型" width="120" />
      <el-table-column prop="content" label="故障描述" :show-overflow-tooltip="true" />
      <el-table-column prop="status" label="状态" width="100">
        <template slot-scope="scope">
          <el-tag :type="getStatusTagType(scope.row.status)">{{ scope.row.status }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="assignee" label="处理人员" width="120" />
      <el-table-column prop="createTime" label="创建时间" width="160">
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.createTime, '{y}-{m}-{d} {h}:{i}:{s}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="280" fixed="right">
        <template slot-scope="scope">
          <el-button v-hasPermi="['thesis:repair:edit']" type="text" icon="el-icon-edit" size="small"
            @click="handleUpdate(scope.row)">编辑</el-button>
          <el-button v-hasPermi="['thesis:repair:edit']" type="text" icon="el-icon-check" size="small"
            @click="handleStatusChange(scope.row, '维修中')">维修中</el-button>
          <el-button v-hasPermi="['thesis:repair:edit']" type="text" icon="el-icon-circle-check" size="small"
            @click="handleStatusChange(scope.row, '已解决')">已解决</el-button>
          <el-button v-hasPermi="['thesis:repair:remove']" type="text" icon="el-icon-delete" size="small"
            @click="handleSingleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" :page.sync="queryParams.pageNum" :limit.sync="queryParams.pageSize"
      @pagination="getList" />

    <!-- 添加或修改报修工单对话框 -->
    <el-dialog :title="title" :visible.sync="open" width="600px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="80px">
        <el-row>
          <el-col :span="12">
            <el-form-item label="自习室" prop="roomName">
              <el-select v-model="form.roomName" placeholder="请选择自习室" filterable>
                <el-option label="静思自习室" value="1" />
                <el-option label="致远阅览室" value="2" />
                <el-option label="明德研讨室" value="3" />
                <el-option label="博学电子阅览室" value="4" />
                <el-option label="晨曦早读室" value="5" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="座位编号" prop="seatNumber">
              <el-select v-model="form.seatNumber" placeholder="请选择座位" filterable>
                <el-option label="A1" value="A1" />
                <el-option label="A2" value="A2" />
                <el-option label="A3" value="A3" />
                <el-option label="A4" value="A4" />
                <el-option label="A5" value="A5" />
                <el-option label="B1" value="B1" />
                <el-option label="B2" value="B2" />
                <el-option label="B3" value="B3" />
                <el-option label="B4" value="B4" />
                <el-option label="B5" value="B5" />
                <el-option label="C1" value="C1" />
                <el-option label="C2" value="C2" />
                <el-option label="C3" value="C3" />
                <el-option label="C4" value="C4" />
                <el-option label="C5" value="C5" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
            <el-form-item label="故障类型" prop="faultType">
              <el-select v-model="form.faultType" placeholder="请选择故障类型">
                <el-option label="桌椅损坏" value="桌椅损坏" />
                <el-option label="网络故障" value="网络故障" />
                <el-option label="电源插座" value="电源插座" />
                <el-option label="空调设备" value="空调设备" />
                <el-option label="照明设备" value="照明设备" />
                <el-option label="其他" value="其他" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="状态" prop="status">
              <el-select v-model="form.status" placeholder="请选择状态">
                <el-option label="待处理" value="待处理" />
                <el-option label="维修中" value="维修中" />
                <el-option label="已解决" value="已解决" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="24">
            <el-form-item label="处理人员" prop="assignee">
              <el-input v-model="form.assignee" placeholder="请输入处理人员（可选）" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="24">
            <el-form-item label="故障描述" prop="content">
              <el-input v-model="form.content" type="textarea" placeholder="请输入故障详细描述" rows="4" />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listRepair, addRepair, updateRepair, delRepair } from '@/api/thesis/admin'
export default {
  name: 'ThesisRepair',
  data() {
    return {
      loading: false,
      showSearch: true,
      rows: [],
      total: 0,
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        roomName: null,
        status: null
      },
      multiple: true,
      ids: [],
      open: false,
      title: '',
      form: {},
      rules: {
        roomName: [{ required: true, message: '自习室不能为空', trigger: 'change' }],
        seatNumber: [{ required: true, message: '座位编号不能为空', trigger: 'change' }],
        faultType: [{ required: true, message: '故障类型不能为空', trigger: 'change' }],
        content: [{ required: true, message: '故障描述不能为空', trigger: 'blur' }]
      }
    }
  },
  created() { this.getList() },
  methods: {
    getList() {
      this.loading = true
      listRepair(this.queryParams).then(r => {
        // 适配分页响应格式 TableDataInfo
        if (r.data && r.data.rows) {
          this.rows = r.data.rows
          this.total = r.data.total
        } else if (r.data && Array.isArray(r.data)) {
          // 兼容旧格式
          this.rows = r.data
          this.total = r.data.length
        } else {
          this.rows = []
          this.total = 0
        }
        this.loading = false
      })
    },
    handleQuery() {
      this.queryParams.pageNum = 1
      this.getList()
    },
    resetQuery() {
      this.reset('queryForm')
      this.handleQuery()
    },
    handleSelectionChange(selection) {
      this.ids = selection.map(item => item.id)
      this.multiple = !selection.length
    },
    handleAdd() {
      this.reset()
      this.open = true
      this.title = '新建报修工单'
    },
    handleUpdate(row) {
      this.reset()
      this.form = JSON.parse(JSON.stringify(row))
      this.open = true
      this.title = '编辑报修工单'
    },
    submitForm() {
      this.$refs['form'].validate(valid => {
        if (valid) {
          if (this.form.id != null) {
            updateRepair(this.form).then(response => {
              this.msgSuccess('修改成功')
              this.open = false
              this.getList()  // 刷新列表
            })
          } else {
            addRepair(this.form).then(response => {
              this.msgSuccess('新建成功')
              this.open = false
              this.queryParams.pageNum = 1  // 重置到第一页
              this.getList()  // 刷新列表
            })
          }
        }
      })
    },
    cancel() {
      this.open = false
      this.reset()
    },
    reset() {
      this.form = {
        id: null,
        roomName: null,
        seatNumber: null,
        faultType: null,
        content: null,
        status: '待处理',
        assignee: null
      };
    },
    handleStatusChange(row, status) {
      const data = { id: row.id, status: status }
      updateRepair(data).then(() => {
        this.msgSuccess('状态更新成功')
        this.getList()
      })
    },
    handleSingleDelete(row) {
      this.$confirm('是否确认删除报修工单编号为"' + row.id + '"的数据项？', '警告', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        return delRepair(row.id)
      }).then(() => {
        this.getList()  // 刷新列表
        this.msgSuccess('删除成功')
      }).catch(() => {})
    },
    handleDelete() {
      this.$confirm('是否确认删除选中的报修工单数据项？', '警告', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        return delRepair(this.ids.join(','))
      }).then(() => {
        this.getList()  // 刷新列表
        this.msgSuccess('删除成功')
      }).catch(() => {})
    },
    getStatusTagType(status) {
      if (status === '待处理') return 'info'
      if (status === '维修中') return 'warning'
      if (status === '已解决') return 'success'
      return ''
    }
  }
}
</script>
