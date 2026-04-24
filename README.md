<p align="center"><img alt="logo" src="./room-ui/public/favicon.ico"></p>
<h1 align="center" style="margin: 20px 0 30px; font-weight: bold;">校园自习室预约管理系统</h1>

## 项目说明

这是一个基于 `Spring Boot + Vue2 + uni-app + MySQL + Redis` 的校园自习室预约管理系统，包含：

- 管理端 Web：自习室、座位、预约、用户、角色、违规、黑名单、保洁、报修、统计看板
- 学生端 UniApp：预约座位、取消预约、扫码签到/签退、课表冲突校验、反馈申诉、提醒、勋章、拼座
- 后端业务：自动违规判定、黑名单限制、学习时长累计、勋章发放、业务审计、高峰预警

## 目录结构

- `room-admin`：Spring Boot 启动模块
- `room-framework` / `room-system` / `room-common` / `room-quartz` / `room-generator`：若依后端模块
- `room-ui`：管理端前端
- `room-uniapp`：学生端 UniApp / 微信小程序端
- `sql`：完整建库脚本与增量脚本

## 环境要求

- JDK 8
- MySQL 8.x
- Redis 6.x 及以上
- Maven 3.8+
- Node.js 18+（建议 18/20）
- npm 9+

## 数据库初始化

推荐直接执行以下完整脚本之一：

- `sql/full_database.sql`
- 或 `sql/study_room_complete.sql`

默认数据库名：

- `study_room`

默认后端数据库连接配置位于：

- `room-admin/src/main/resources/application-druid.yml`

默认账号密码：

- MySQL：`root / 123456`

## 默认测试账号

- 超级管理员：`admin / admin123`
- 自习室管理员：`room_admin / admin123`
- 学生用户：`student / student123`

## 启动方式

### 1. 启动后端

```bash
mvn clean package -DskipTests
mvn -pl room-admin spring-boot:run
```

后端默认地址：

- `http://localhost:8080`

### 2. 启动管理端 Web

```bash
cd room-ui
npm install
npm run dev
```

管理端默认地址：

- `http://localhost:80`

### 3. 启动 UniApp / 微信小程序端

```bash
cd room-uniapp
npm install
npm run dev:mp-weixin
```

开发说明：

- `room-uniapp/.env.development` 默认指向 `127.0.0.1:8080`
- 如果使用真机调试，请把该文件中的地址改成电脑局域网 IP

## 已覆盖功能

- 学生预约座位、取消预约、扫码签到、扫码签退
- 预约冲突校验、课表冲突校验、黑名单限制
- 自动判定未签到/未签退违规并写入违规记录
- 自动拉黑与管理员解除禁约
- 管理员管理自习室、座位、预约订单、审核订单
- 管理员管理用户、角色、菜单、公告、配置
- 违规处理、黑名单管理、反馈申诉、报修工单、保洁排班
- 数据统计、学习时长排行、勋章体系、提醒通知、高峰预警

## 备注

- 本仓库同时保留了若依原生系统管理模块，毕业设计需要的用户/角色/权限管理可直接使用
- 若本机未安装 Maven 或前端依赖未安装，需先补齐运行环境后再执行构建
