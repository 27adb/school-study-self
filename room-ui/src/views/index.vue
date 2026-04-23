<template>
  <div class="app-container home">
    <h1 class="title">自习室预约平台-管理后台</h1>
    <el-row :gutter="20">
      <el-col :sm="24" :lg="12" style="padding-left: 20px">
        <h2>自习室预约平台</h2>
        <p><b>当前版本:</b> <span>v{{ version }}</span></p>
      </el-col>
    </el-row>
    <el-divider />

    <!-- 欢迎首页内容 -->
    <el-row :gutter="20">
      <el-col :xs="24" :sm="24">
        <el-card class="welcome-card">
          <div class="welcome-content">
            <div class="welcome-icon">
              <i class="el-icon-s-home"></i>
            </div>
            <h2>欢迎使用自习室预约平台管理后台</h2>
            <p class="welcome-desc">
              在这里你可以高效管理自习室、座位、预约记录、用户信息等全部功能模块
            </p>
            <div class="welcome-info">
              <div class="info-item">
                <i class="el-icon-user"></i>
                <span>用户管理</span>
              </div>
              <div class="info-item">
                <i class="el-icon-office-building"></i>
                <span>自习室管理</span>
              </div>
              <div class="info-item">
                <i class="el-icon-tickets"></i>
                <span>预约管理</span>
              </div>
              <div class="info-item">
                <i class="el-icon-setting"></i>
                <span>系统设置</span>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script>
export default {
  name: "Index",
  data() {
    return {
      // 版本号
      version: "1.0.1"
    }
  },
  methods: {
    goTarget(href) {
      window.open(href, "_blank")
    }
  }
}
</script>

<style lang="scss" scoped>
.home {
  color: #676a6c;

  .title {
    font-size: 25px;
    text-align: center;
  }
}

// 欢迎卡片样式
.welcome-card {
  margin-top: 10px;
  text-align: center;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);

  .welcome-content {
    padding: 40px 20px;

    .welcome-icon {
      font-size: 60px;
      color: #409eff;
      margin-bottom: 20px;
    }

    h2 {
      font-size: 24px;
      color: #303133;
      margin-bottom: 15px;
    }

    .welcome-desc {
      font-size: 15px;
      color: #606266;
      max-width: 700px;
      margin: 0 auto 30px;
      line-height: 1.6;
    }

    .welcome-info {
      display: flex;
      justify-content: center;
      flex-wrap: wrap;
      gap: 30px;
      margin-top: 20px;

      .info-item {
        display: flex;
        flex-direction: column;
        align-items: center;
        font-size: 14px;
        color: #676a6c;

        i {
          font-size: 26px;
          color: #67c23a;
          margin-bottom: 8px;
        }
      }
    }
  }
}
</style>
