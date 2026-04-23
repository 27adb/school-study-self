<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch">
      <el-form-item label="名称" prop="name">
        <el-input v-model="queryParams.name" placeholder="请输入名称" clearable @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item label="位置" prop="location">
        <el-input v-model="queryParams.location" placeholder="请输入位置" clearable @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="请选择状态">
          <el-option label="开放" value="开放" />
          <el-option label="关闭" value="关闭" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="el-icon-plus" size="mini" @click="handleAdd"
          v-hasPermi="['reservation:room:add']">新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="success" plain icon="el-icon-edit" size="mini" :disabled="single" @click="handleUpdate"
          v-hasPermi="['reservation:room:edit']">修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="danger" plain icon="el-icon-delete" size="mini" :disabled="multiple" @click="handleDelete"
          v-hasPermi="['reservation:room:remove']">删除</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="warning" plain icon="el-icon-download" size="mini" @click="handleExport"
          v-hasPermi="['reservation:room:export']">导出</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="roomList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="编号" align="center" prop="id" />
      <el-table-column label="名称" align="center" prop="name" />
      <el-table-column label="图片" align="center" prop="image" width="100">
        <template slot-scope="scope">
          <image-preview :src="scope.row.image" :width="50" :height="50" />
        </template>
      </el-table-column>
      <el-table-column label="位置" align="center" prop="location" />
      <el-table-column label="布局" align="center" prop="rowsCount">
        <template slot-scope="scope">
          <el-tag size="small">{{ scope.row.rowsCount }}行 × {{ scope.row.colsCount }}列</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="开放时间" align="center" prop="openTime" width="180">
        <template slot-scope="scope">
          <span>{{ scope.row.openTime }} 至 {{ scope.row.closeTime }}</span>
        </template>
      </el-table-column>
      <el-table-column label="状态" align="center" prop="status">
        <template slot-scope="scope">
          <el-tag v-if="scope.row.status === '开放'" size="small" type="success">{{ scope.row.status }}</el-tag>
          <el-tag v-if="scope.row.status === '关闭'" size="small" type="danger">{{ scope.row.status }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="舒适度" align="center" prop="comfortScore" width="90" />
      <el-table-column label="签到坐标" align="center" min-width="180">
        <template slot-scope="scope">
          <span v-if="scope.row.latitude != null && scope.row.longitude != null">
            {{ scope.row.latitude }}, {{ scope.row.longitude }}
          </span>
          <span v-else>-</span>
        </template>
      </el-table-column>
      <el-table-column label="签到半径(米)" align="center" prop="signRadiusMeter" width="120" />
      <el-table-column label="区域" align="center" prop="areaZone" width="100" show-overflow-tooltip />
      <el-table-column label="拼座规则说明" align="center" prop="seatRuleNote" min-width="140" show-overflow-tooltip />
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template slot-scope="scope">
          <el-button size="mini" type="text" icon="el-icon-edit" @click="handleUpdate(scope.row)"
            v-hasPermi="['reservation:room:edit']">修改</el-button>
          <el-button size="mini" type="text" icon="el-icon-delete" @click="handleDelete(scope.row)"
            v-hasPermi="['reservation:room:remove']">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" :page.sync="queryParams.pageNum" :limit.sync="queryParams.pageSize"
      @pagination="getList" />

    <!-- 添加或修改自习室对话框 -->
    <el-dialog :title="title" :visible.sync="open" width="500px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="auto">
        <el-form-item label="名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入名称" />
        </el-form-item>
        <el-form-item label="图片" prop="image">
          <image-upload v-model="form.image" :limit="1" />
        </el-form-item>
        <el-form-item label="位置" prop="location">
          <el-input v-model="form.location" placeholder="请输入位置" />
        </el-form-item>
        <el-form-item label="行数" prop="rowsCount">
          <el-input-number v-model="form.rowsCount" :min="0" :max="8" label="请输入行数" />
        </el-form-item>
        <el-form-item label="列数" prop="colsCount">
          <el-input-number v-model="form.colsCount" :min="0" :max="8" label="请输入列数" />
        </el-form-item>
        <el-form-item label="开放时间" prop="openTime">
          <el-time-picker v-model="form.openTime" value-format="HH:mm:ss" placeholder="请选择开放时间" />
        </el-form-item>
        <el-form-item label="关闭时间" prop="closeTime">
          <el-time-picker v-model="form.closeTime" value-format="HH:mm:ss" placeholder="请选择关闭时间" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio label="开放">开放</el-radio>
            <el-radio label="关闭">关闭</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="舒适度(1-5)" prop="comfortScore">
          <el-input-number v-model="form.comfortScore" :min="1" :max="5" :step="0.1" :precision="1" />
        </el-form-item>
        <el-form-item label="区域划分" prop="areaZone">
          <el-input v-model="form.areaZone" placeholder="如：静音区、研讨区" maxlength="32" show-word-limit />
        </el-form-item>
        <el-form-item label="拼座/座位说明" prop="seatRuleNote">
          <el-input v-model="form.seatRuleNote" type="textarea" :rows="2" placeholder="拼座规则、座位类型占比说明" maxlength="500" show-word-limit />
        </el-form-item>
        <el-form-item label="签到纬度" prop="latitude">
          <el-input-number
            v-model="form.latitude"
            :min="-90"
            :max="90"
            :precision="6"
            :step="0.000001"
            controls-position="right"
            style="width: 100%;"
          />
        </el-form-item>
        <el-form-item label="签到经度" prop="longitude">
          <el-input-number
            v-model="form.longitude"
            :min="-180"
            :max="180"
            :precision="6"
            :step="0.000001"
            controls-position="right"
            style="width: 100%;"
          />
        </el-form-item>
        <el-form-item label="地图选点">
          <el-button type="primary" plain icon="el-icon-location-outline" @click="openMapPicker">打开地图选点</el-button>
          <el-button type="success" plain icon="el-icon-edit" @click="openCoordPrompt">粘贴坐标回填</el-button>
          <div style="color: #909399; font-size: 12px; line-height: 1.6; margin-top: 6px;">
            建议流程：先点“打开地图选点”，在地图点击目标位置并复制坐标，再点“粘贴坐标回填”自动填入经纬度。
          </div>
        </el-form-item>
        <el-form-item label="签到半径(米)" prop="signRadiusMeter">
          <el-input-number v-model="form.signRadiusMeter" :min="10" :max="2000" :step="5" controls-position="right" style="width: 100%;" />
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
import { listRoom, getRoom, delRoom, addRoom, updateRoom } from "@/api/reservation/room"

export default {
  name: "Room",
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
      // 自习室表格数据
      roomList: [],
      // 弹出层标题
      title: "",
      // 是否显示弹出层
      open: false,
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        name: null,
        location: null,
        status: null
      },
      // 表单参数
      form: {},
      // 表单校验
      rules: {
        name: [
          { required: true, message: "名称不能为空", trigger: "blur" }
        ],
        image: [
          { required: true, message: "图片不能为空", trigger: "blur" }
        ],
        location: [
          { required: true, message: "位置不能为空", trigger: "blur" }
        ],
        rowsCount: [
          { required: true, message: "行数不能为空", trigger: "blur" }
        ],
        colsCount: [
          { required: true, message: "列数不能为空", trigger: "blur" }
        ],
        openTime: [
          { required: true, message: "开放时间不能为空", trigger: "blur" }
        ],
        closeTime: [
          { required: true, message: "关闭时间不能为空", trigger: "blur" }
        ],
        status: [
          { required: true, message: "状态不能为空", trigger: "blur" }
        ],
        latitude: [
          { required: true, message: "签到纬度不能为空", trigger: "blur" }
        ],
        longitude: [
          { required: true, message: "签到经度不能为空", trigger: "blur" }
        ],
        signRadiusMeter: [
          { required: true, message: "签到半径不能为空", trigger: "blur" }
        ]
      }
    }
  },
  created() {
    this.getList()
  },
  methods: {
    /** 查询自习室列表 */
    getList() {
      this.loading = true
      listRoom(this.queryParams).then(response => {
        this.roomList = response.rows
        this.total = response.total
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
        name: null,
        image: null,
        location: null,
        rowsCount: null,
        colsCount: null,
        openTime: null,
        closeTime: null,
        status: null,
        comfortScore: 4.5,
        areaZone: null,
        seatRuleNote: null,
        latitude: null,
        longitude: null,
        signRadiusMeter: 200
      }
      this.resetForm("form")
    },
    parseLngLat(raw) {
      const text = String(raw || "").trim()
      if (!text) return null
      const nums = text.match(/-?\d+(?:\.\d+)?/g)
      if (!nums || nums.length < 2) return null
      const a = Number(nums[0])
      const b = Number(nums[1])
      if (!Number.isFinite(a) || !Number.isFinite(b)) return null

      // 默认按“经度,纬度”解析；若顺序看起来是“纬度,经度”则自动纠正
      let lng = a
      let lat = b
      const looksLikeLatLng = Math.abs(a) <= 90 && Math.abs(b) <= 180
      const looksLikeLngLat = Math.abs(a) <= 180 && Math.abs(b) <= 90
      if (!looksLikeLngLat && looksLikeLatLng) {
        lat = a
        lng = b
      }
      if (Math.abs(lat) > 90 || Math.abs(lng) > 180) return null
      return { lng, lat }
    },
    openMapPicker() {
      const url = "https://api.map.baidu.com/lbsapi/getpoint/index.html"
      window.open(url, "_blank")
      this.$modal.msgSuccess("地图选点页已打开，选点后复制坐标回来回填")
    },
    openCoordPrompt() {
      this.$prompt("请输入或粘贴坐标（支持：经度,纬度 或 纬度,经度）", "坐标回填", {
        confirmButtonText: "回填",
        cancelButtonText: "取消",
        inputPlaceholder: "例如：121.473701,31.230416",
      }).then(({ value }) => {
        const pos = this.parseLngLat(value)
        if (!pos) {
          this.$modal.msgError("坐标格式不正确，请输入两个数字坐标")
          return
        }
        this.form.longitude = Number(pos.lng.toFixed(6))
        this.form.latitude = Number(pos.lat.toFixed(6))
        this.$modal.msgSuccess("坐标已回填")
      }).catch(() => {})
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
      this.title = "添加自习室"
    },
    /** 修改按钮操作 */
    handleUpdate(row) {
      this.reset()
      const id = row.id || this.ids
      getRoom(id).then(response => {
        this.form = response.data
        this.open = true
        this.title = "修改自习室"
      })
    },
    /** 提交按钮 */
    submitForm() {
      this.$refs["form"].validate(valid => {
        if (valid) {
          if (this.form.id != null) {
            updateRoom(this.form).then(response => {
              this.$modal.msgSuccess("修改成功")
              this.open = false
              this.getList()
            })
          } else {
            addRoom(this.form).then(response => {
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
      this.$modal.confirm('是否确认删除自习室编号为"' + ids + '"的数据项？').then(function () {
        return delRoom(ids)
      }).then(() => {
        this.getList()
        this.$modal.msgSuccess("删除成功")
      }).catch(() => { })
    },
    /** 导出按钮操作 */
    handleExport() {
      this.download('reservation/room/export', {
        ...this.queryParams
      }, `room_${new Date().getTime()}.xlsx`)
    }
  }
}
</script>