/*
  自习室座位预约系统 — 完整数据库脚本（表结构 + 初始化数据）
  ------------------------------------------------------------------
  适用：MySQL 8.x（与项目 study_room 库一致）
  用法示例：
    CREATE DATABASE IF NOT EXISTS study_room DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
    USE study_room;
    SOURCE full_database.sql;
    或：mysql -u root -p study_room < sql/full_database.sql
  本文件在 Navicat 导出库基础上合并了论文扩展：room/room_reservation 扩展字段、
  room_feedback_record 与业务表、sys_menu(2020/2100～2150)、sys_config(9～18)、
  三角色 sys_role_menu（末尾为 role_id=1 绑定全部菜单）。
  ------------------------------------------------------------------
  Navicat Premium Data Transfer（原始元信息）
  Source Server Version : 80042
  Date: 25/11/2025 22:12:00
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for gen_table
-- ----------------------------
DROP TABLE IF EXISTS `gen_table`;
CREATE TABLE `gen_table`  (
  `table_id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `table_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '表名称',
  `table_comment` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '表描述',
  `sub_table_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '关联子表的表名',
  `sub_table_fk_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '子表关联的外键名',
  `class_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '实体类名称',
  `tpl_category` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT 'crud' COMMENT '使用的模板（crud单表操作 tree树表操作）',
  `tpl_web_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '前端模板类型（element-ui模版 element-plus模版）',
  `package_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '生成包路径',
  `module_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '生成模块名',
  `business_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '生成业务名',
  `function_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '生成功能名',
  `function_author` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '生成功能作者',
  `gen_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '0' COMMENT '生成代码方式（0zip压缩包 1自定义路径）',
  `gen_path` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '/' COMMENT '生成路径（不填默认项目路径）',
  `options` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '其它生成选项',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`table_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 23 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '代码生成业务表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of gen_table
-- ----------------------------
INSERT INTO `gen_table` VALUES (20, 'room', '自习室表', NULL, NULL, 'Room', 'crud', 'element-ui', 'com.room.reservation', 'room', 'room', '自习室管理', 'FMBOY', '0', '/', '{\"parentMenuId\":3}', 'admin', '2025-11-16 23:07:59', '', '2025-11-16 23:16:05', NULL);
INSERT INTO `gen_table` VALUES (21, 'room_reservation', '自习室预约表', NULL, NULL, 'RoomReservation', 'crud', 'element-ui', 'com.room.reservation', 'reservation', 'reservation', '自习室预约管理', 'FMBOY', '0', '/', '{\"parentMenuId\":3}', 'admin', '2025-11-16 23:07:59', '', '2025-11-16 23:14:26', NULL);
INSERT INTO `gen_table` VALUES (22, 'room_seat', '自习室座位表', NULL, NULL, 'RoomSeat', 'crud', '', 'com.room.system', 'system', 'seat', '自习室座位', 'ruoyi', '0', '/', NULL, 'admin', '2025-11-16 23:07:59', '', NULL, NULL);

-- ----------------------------
-- Table structure for gen_table_column
-- ----------------------------
DROP TABLE IF EXISTS `gen_table_column`;
CREATE TABLE `gen_table_column`  (
  `column_id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `table_id` bigint NULL DEFAULT NULL COMMENT '归属表编号',
  `column_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '列名称',
  `column_comment` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '列描述',
  `column_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '列类型',
  `java_type` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT 'JAVA类型',
  `java_field` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT 'JAVA字段名',
  `is_pk` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '是否主键（1是）',
  `is_increment` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '是否自增（1是）',
  `is_required` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '是否必填（1是）',
  `is_insert` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '是否为插入字段（1是）',
  `is_edit` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '是否编辑字段（1是）',
  `is_list` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '是否列表字段（1是）',
  `is_query` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '是否查询字段（1是）',
  `query_type` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT 'EQ' COMMENT '查询方式（等于、不等于、大于、小于、范围）',
  `html_type` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '显示类型（文本框、文本域、下拉框、复选框、单选框、日期控件）',
  `dict_type` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '字典类型',
  `sort` int NULL DEFAULT NULL COMMENT '排序',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`column_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 185 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '代码生成业务表字段' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of gen_table_column
-- ----------------------------
INSERT INTO `gen_table_column` VALUES (160, 20, 'id', '编号', 'int', 'Long', 'id', '1', '1', '0', '0', NULL, NULL, NULL, 'EQ', 'input', '', 1, 'admin', '2025-11-16 23:07:59', '', '2025-11-16 23:16:05');
INSERT INTO `gen_table_column` VALUES (161, 20, 'name', '名称', 'varchar(100)', 'String', 'name', '0', '0', '1', '1', '1', '1', '1', 'LIKE', 'input', '', 2, 'admin', '2025-11-16 23:07:59', '', '2025-11-16 23:16:05');
INSERT INTO `gen_table_column` VALUES (162, 20, 'image', '图片', 'varchar(100)', 'String', 'image', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'imageUpload', '', 3, 'admin', '2025-11-16 23:07:59', '', '2025-11-16 23:16:05');
INSERT INTO `gen_table_column` VALUES (163, 20, 'location', '位置', 'varchar(100)', 'String', 'location', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 4, 'admin', '2025-11-16 23:07:59', '', '2025-11-16 23:16:05');
INSERT INTO `gen_table_column` VALUES (164, 20, 'rows_count', '行数', 'int', 'Long', 'rowsCount', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 5, 'admin', '2025-11-16 23:07:59', '', '2025-11-16 23:16:05');
INSERT INTO `gen_table_column` VALUES (165, 20, 'cols_count', '列数', 'int', 'Long', 'colsCount', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 6, 'admin', '2025-11-16 23:07:59', '', '2025-11-16 23:16:05');
INSERT INTO `gen_table_column` VALUES (166, 20, 'open_time', '开放时间', 'time', 'Date', 'openTime', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'datetime', '', 7, 'admin', '2025-11-16 23:07:59', '', '2025-11-16 23:16:05');
INSERT INTO `gen_table_column` VALUES (167, 20, 'close_time', '关闭时间', 'time', 'Date', 'closeTime', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'datetime', '', 8, 'admin', '2025-11-16 23:07:59', '', '2025-11-16 23:16:05');
INSERT INTO `gen_table_column` VALUES (168, 20, 'status', '状态', 'varchar(10)', 'String', 'status', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'radio', '', 9, 'admin', '2025-11-16 23:07:59', '', '2025-11-16 23:16:05');
INSERT INTO `gen_table_column` VALUES (169, 21, 'id', '编号', 'int', 'Long', 'id', '1', '1', '0', '0', NULL, '1', NULL, 'EQ', 'input', '', 1, 'admin', '2025-11-16 23:07:59', '', '2025-11-16 23:14:26');
INSERT INTO `gen_table_column` VALUES (170, 21, 'user_id', '用户ID', 'int', 'Long', 'userId', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 2, 'admin', '2025-11-16 23:07:59', '', '2025-11-16 23:14:26');
INSERT INTO `gen_table_column` VALUES (171, 21, 'seat_id', '座位ID', 'int', 'Long', 'seatId', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 3, 'admin', '2025-11-16 23:07:59', '', '2025-11-16 23:14:26');
INSERT INTO `gen_table_column` VALUES (172, 21, 'status', '状态', 'varchar(10)', 'String', 'status', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 4, 'admin', '2025-11-16 23:07:59', '', '2025-11-16 23:14:26');
INSERT INTO `gen_table_column` VALUES (173, 21, 'reservation_status', '预约状态', 'varchar(10)', 'String', 'reservationStatus', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 5, 'admin', '2025-11-16 23:07:59', '', '2025-11-16 23:14:26');
INSERT INTO `gen_table_column` VALUES (174, 21, 'reservation_in_time', '预约开始时间', 'datetime', 'Date', 'reservationInTime', '0', '0', '1', '1', '1', '1', '0', 'EQ', 'datetime', '', 6, 'admin', '2025-11-16 23:07:59', '', '2025-11-16 23:14:26');
INSERT INTO `gen_table_column` VALUES (175, 21, 'reservation_out_time', '预约结束时间', 'datetime', 'Date', 'reservationOutTime', '0', '0', '1', '1', '1', '1', '0', 'EQ', 'datetime', '', 7, 'admin', '2025-11-16 23:07:59', '', '2025-11-16 23:14:26');
INSERT INTO `gen_table_column` VALUES (176, 21, 'sign_in_time', '签到时间', 'datetime', 'Date', 'signInTime', '0', '0', '0', '1', '1', '1', '0', 'EQ', 'datetime', '', 8, 'admin', '2025-11-16 23:07:59', '', '2025-11-16 23:14:26');
INSERT INTO `gen_table_column` VALUES (177, 21, 'sign_out_time', '签退时间', 'datetime', 'Date', 'signOutTime', '0', '0', '0', '1', '1', '1', '0', 'EQ', 'datetime', '', 9, 'admin', '2025-11-16 23:07:59', '', '2025-11-16 23:14:26');
INSERT INTO `gen_table_column` VALUES (178, 21, 'remark', '备注', 'varchar(100)', 'String', 'remark', '0', '0', '0', '1', '1', '1', NULL, 'EQ', 'input', '', 10, 'admin', '2025-11-16 23:07:59', '', '2025-11-16 23:14:26');
INSERT INTO `gen_table_column` VALUES (179, 22, 'id', NULL, 'int', 'Long', 'id', '1', '1', '0', '1', NULL, NULL, NULL, 'EQ', 'input', '', 1, 'admin', '2025-11-16 23:07:59', '', NULL);
INSERT INTO `gen_table_column` VALUES (180, 22, 'seat_num', '座位号', 'varchar(10)', 'String', 'seatNum', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 2, 'admin', '2025-11-16 23:07:59', '', NULL);
INSERT INTO `gen_table_column` VALUES (181, 22, 'room_id', '自习室ID', 'int', 'Long', 'roomId', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 3, 'admin', '2025-11-16 23:07:59', '', NULL);
INSERT INTO `gen_table_column` VALUES (182, 22, 'row_num', '行号', 'int', 'Long', 'rowNum', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 4, 'admin', '2025-11-16 23:07:59', '', NULL);
INSERT INTO `gen_table_column` VALUES (183, 22, 'col_num', '列号', 'int', 'Long', 'colNum', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 5, 'admin', '2025-11-16 23:07:59', '', NULL);
INSERT INTO `gen_table_column` VALUES (184, 22, 'status', '状态', 'int', 'Long', 'status', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'radio', '', 6, 'admin', '2025-11-16 23:07:59', '', NULL);

-- ----------------------------
-- Table structure for qrtz_blob_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_blob_triggers`;
CREATE TABLE `qrtz_blob_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `blob_data` blob NULL COMMENT '存放持久化Trigger对象',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  CONSTRAINT `qrtz_blob_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `qrtz_triggers` (`sched_name`, `trigger_name`, `trigger_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = 'Blob类型的触发器表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_blob_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_calendars
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_calendars`;
CREATE TABLE `qrtz_calendars`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '调度名称',
  `calendar_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '日历名称',
  `calendar` blob NOT NULL COMMENT '存放持久化calendar对象',
  PRIMARY KEY (`sched_name`, `calendar_name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '日历信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_calendars
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_cron_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_cron_triggers`;
CREATE TABLE `qrtz_cron_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `cron_expression` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'cron表达式',
  `time_zone_id` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '时区',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  CONSTRAINT `qrtz_cron_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `qrtz_triggers` (`sched_name`, `trigger_name`, `trigger_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = 'Cron类型的触发器表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_cron_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_fired_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_fired_triggers`;
CREATE TABLE `qrtz_fired_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '调度名称',
  `entry_id` varchar(95) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '调度器实例id',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `instance_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '调度器实例名',
  `fired_time` bigint NOT NULL COMMENT '触发的时间',
  `sched_time` bigint NOT NULL COMMENT '定时器制定的时间',
  `priority` int NOT NULL COMMENT '优先级',
  `state` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '状态',
  `job_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '任务名称',
  `job_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '任务组名',
  `is_nonconcurrent` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '是否并发',
  `requests_recovery` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '是否接受恢复执行',
  PRIMARY KEY (`sched_name`, `entry_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '已触发的触发器表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_fired_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_job_details
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_job_details`;
CREATE TABLE `qrtz_job_details`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '调度名称',
  `job_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '任务名称',
  `job_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '任务组名',
  `description` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '相关介绍',
  `job_class_name` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '执行任务类名称',
  `is_durable` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '是否持久化',
  `is_nonconcurrent` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '是否并发',
  `is_update_data` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '是否更新数据',
  `requests_recovery` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '是否接受恢复执行',
  `job_data` blob NULL COMMENT '存放持久化job对象',
  PRIMARY KEY (`sched_name`, `job_name`, `job_group`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '任务详细信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_job_details
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_locks
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_locks`;
CREATE TABLE `qrtz_locks`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '调度名称',
  `lock_name` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '悲观锁名称',
  PRIMARY KEY (`sched_name`, `lock_name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '存储的悲观锁信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_locks
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_paused_trigger_grps
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_paused_trigger_grps`;
CREATE TABLE `qrtz_paused_trigger_grps`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '调度名称',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  PRIMARY KEY (`sched_name`, `trigger_group`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '暂停的触发器表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_paused_trigger_grps
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_scheduler_state
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_scheduler_state`;
CREATE TABLE `qrtz_scheduler_state`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '调度名称',
  `instance_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '实例名称',
  `last_checkin_time` bigint NOT NULL COMMENT '上次检查时间',
  `checkin_interval` bigint NOT NULL COMMENT '检查间隔时间',
  PRIMARY KEY (`sched_name`, `instance_name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '调度器状态表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_scheduler_state
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_simple_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_simple_triggers`;
CREATE TABLE `qrtz_simple_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `repeat_count` bigint NOT NULL COMMENT '重复的次数统计',
  `repeat_interval` bigint NOT NULL COMMENT '重复的间隔时间',
  `times_triggered` bigint NOT NULL COMMENT '已经触发的次数',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  CONSTRAINT `qrtz_simple_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `qrtz_triggers` (`sched_name`, `trigger_name`, `trigger_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '简单触发器的信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_simple_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_simprop_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_simprop_triggers`;
CREATE TABLE `qrtz_simprop_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `str_prop_1` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT 'String类型的trigger的第一个参数',
  `str_prop_2` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT 'String类型的trigger的第二个参数',
  `str_prop_3` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT 'String类型的trigger的第三个参数',
  `int_prop_1` int NULL DEFAULT NULL COMMENT 'int类型的trigger的第一个参数',
  `int_prop_2` int NULL DEFAULT NULL COMMENT 'int类型的trigger的第二个参数',
  `long_prop_1` bigint NULL DEFAULT NULL COMMENT 'long类型的trigger的第一个参数',
  `long_prop_2` bigint NULL DEFAULT NULL COMMENT 'long类型的trigger的第二个参数',
  `dec_prop_1` decimal(13, 4) NULL DEFAULT NULL COMMENT 'decimal类型的trigger的第一个参数',
  `dec_prop_2` decimal(13, 4) NULL DEFAULT NULL COMMENT 'decimal类型的trigger的第二个参数',
  `bool_prop_1` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT 'Boolean类型的trigger的第一个参数',
  `bool_prop_2` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT 'Boolean类型的trigger的第二个参数',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  CONSTRAINT `qrtz_simprop_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `qrtz_triggers` (`sched_name`, `trigger_name`, `trigger_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '同步机制的行锁表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_simprop_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_triggers`;
CREATE TABLE `qrtz_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '触发器的名字',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '触发器所属组的名字',
  `job_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'qrtz_job_details表job_name的外键',
  `job_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'qrtz_job_details表job_group的外键',
  `description` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '相关介绍',
  `next_fire_time` bigint NULL DEFAULT NULL COMMENT '上一次触发时间（毫秒）',
  `prev_fire_time` bigint NULL DEFAULT NULL COMMENT '下一次触发时间（默认为-1表示不触发）',
  `priority` int NULL DEFAULT NULL COMMENT '优先级',
  `trigger_state` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '触发器状态',
  `trigger_type` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '触发器的类型',
  `start_time` bigint NOT NULL COMMENT '开始时间',
  `end_time` bigint NULL DEFAULT NULL COMMENT '结束时间',
  `calendar_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '日程表名称',
  `misfire_instr` smallint NULL DEFAULT NULL COMMENT '补偿执行的策略',
  `job_data` blob NULL COMMENT '存放持久化job对象',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  INDEX `sched_name`(`sched_name`, `job_name`, `job_group`) USING BTREE,
  CONSTRAINT `qrtz_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `job_name`, `job_group`) REFERENCES `qrtz_job_details` (`sched_name`, `job_name`, `job_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '触发器详细信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for room
-- ----------------------------
DROP TABLE IF EXISTS `room`;
CREATE TABLE `room`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '名称',
  `image` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '图片',
  `location` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '位置',
  `rows_count` int NOT NULL COMMENT '行数',
  `cols_count` int NOT NULL COMMENT '列数',
  `open_time` time NOT NULL COMMENT '开放时间',
  `close_time` time NOT NULL COMMENT '关闭时间',
  `status` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '状态',
  `comfort_score` decimal(3,1) NULL DEFAULT 4.5 COMMENT '区域舒适度评分(约1-5分)',
  `area_zone` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '静音区/研讨区等',
  `seat_rule_note` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '拼座与座位类型说明',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE utf8mb4_bin COMMENT = '自习室表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of room
-- ----------------------------
INSERT INTO `room` VALUES (1, '静思自习室', '/profile/upload/2025/11/25/1_20251125201236A001.jpg', '图书馆A区3楼', 4, 5, '08:00:00', '20:00:00', '开放', 4.5, '静音区', NULL);
INSERT INTO `room` VALUES (2, '致远阅览室', '/profile/upload/2025/11/25/2_20251125201245A002.jpg', '教学楼B座2楼', 5, 5, '06:00:00', '22:00:00', '开放', 4.5, NULL, NULL);
INSERT INTO `room` VALUES (3, '明德研讨室', '/profile/upload/2025/11/25/3_20251125201308A003.jpeg', '学生活动中心1楼', 6, 8, '09:00:00', '18:00:00', '开放', 4.5, '研讨区', NULL);
INSERT INTO `room` VALUES (4, '博学电子阅览室', '/profile/upload/2025/11/25/4_20251125201315A004.jpg', '信息楼5楼', 5, 6, '08:00:00', '22:00:00', '开放', 4.5, NULL, NULL);
INSERT INTO `room` VALUES (5, '晨曦早读室', '/profile/upload/2025/11/25/5_20251125201325A005.jpg', '东校区体育馆旁', 6, 8, '06:00:00', '12:00:00', '开放', 4.5, NULL, NULL);

-- ----------------------------
-- Table structure for room_reservation
-- ----------------------------
DROP TABLE IF EXISTS `room_reservation`;
CREATE TABLE `room_reservation`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL COMMENT '用户ID',
  `seat_id` int NOT NULL COMMENT '座位ID',
  `status` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '状态',
  `reservation_status` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '预约状态',
  `reservation_in_time` datetime NOT NULL COMMENT '预约开始时间',
  `reservation_out_time` datetime NOT NULL COMMENT '预约结束时间',
  `sign_in_time` datetime NULL DEFAULT NULL COMMENT '签到时间',
  `sign_out_time` datetime NULL DEFAULT NULL COMMENT '签退时间',
  `remark` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '备注',
  `audit_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '无需审核' COMMENT '订单审核',
  `carpool_group_id` bigint NULL DEFAULT NULL COMMENT '拼座组ID',
  `share_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '分享码',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 51 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '自习室预约表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of room_reservation
-- ----------------------------

-- ----------------------------
-- Table structure for room_seat
-- ----------------------------
DROP TABLE IF EXISTS `room_seat`;
CREATE TABLE `room_seat`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `seat_num` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '座位号',
  `room_id` int NOT NULL COMMENT '自习室ID',
  `row_num` int NOT NULL COMMENT '行号',
  `col_num` int NOT NULL COMMENT '列号',
  `status` int NOT NULL COMMENT '状态',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 135 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '自习室座位表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of room_seat
-- ----------------------------
INSERT INTO `room_seat` VALUES (1, 'A1', 1, 1, 1, 0);
INSERT INTO `room_seat` VALUES (2, 'A2', 1, 1, 2, 0);
INSERT INTO `room_seat` VALUES (6, 'B3', 1, 2, 3, 0);
INSERT INTO `room_seat` VALUES (7, 'B2', 1, 2, 2, 0);
INSERT INTO `room_seat` VALUES (8, 'A5', 1, 1, 5, 0);
INSERT INTO `room_seat` VALUES (9, 'B4', 1, 2, 4, 0);
INSERT INTO `room_seat` VALUES (10, 'A3', 1, 1, 3, 0);
INSERT INTO `room_seat` VALUES (11, 'A4', 1, 1, 4, 0);
INSERT INTO `room_seat` VALUES (13, 'B1', 1, 2, 1, 0);
INSERT INTO `room_seat` VALUES (14, 'B5', 1, 2, 5, 0);
INSERT INTO `room_seat` VALUES (15, 'C1', 1, 3, 1, 0);
INSERT INTO `room_seat` VALUES (17, 'C5', 1, 3, 5, 0);
INSERT INTO `room_seat` VALUES (18, 'C2', 1, 3, 2, 0);
INSERT INTO `room_seat` VALUES (19, 'C4', 1, 3, 4, 0);
INSERT INTO `room_seat` VALUES (23, 'A1', 5, 1, 1, 0);
INSERT INTO `room_seat` VALUES (24, 'A2', 5, 1, 2, 0);
INSERT INTO `room_seat` VALUES (25, 'A3', 5, 1, 3, 0);
INSERT INTO `room_seat` VALUES (26, 'A4', 5, 1, 4, 0);
INSERT INTO `room_seat` VALUES (27, 'A5', 5, 1, 5, 0);
INSERT INTO `room_seat` VALUES (28, 'A6', 5, 1, 6, 0);
INSERT INTO `room_seat` VALUES (29, 'A7', 5, 1, 7, 0);
INSERT INTO `room_seat` VALUES (30, 'A8', 5, 1, 8, 0);
INSERT INTO `room_seat` VALUES (31, 'B1', 5, 1, 9, 0);
INSERT INTO `room_seat` VALUES (32, 'B2', 5, 1, 10, 0);
INSERT INTO `room_seat` VALUES (33, 'C3', 5, 3, 3, 0);
INSERT INTO `room_seat` VALUES (34, 'C8', 5, 3, 8, 0);
INSERT INTO `room_seat` VALUES (36, 'A1', 2, 1, 1, 0);
INSERT INTO `room_seat` VALUES (37, 'C3', 1, 3, 3, 0);
INSERT INTO `room_seat` VALUES (39, 'D1', 1, 4, 1, 0);
INSERT INTO `room_seat` VALUES (40, 'D2', 1, 4, 2, 0);
INSERT INTO `room_seat` VALUES (41, 'D3', 1, 4, 3, 0);
INSERT INTO `room_seat` VALUES (42, 'D4', 1, 4, 4, 0);
INSERT INTO `room_seat` VALUES (43, 'D5', 1, 4, 5, 0);
INSERT INTO `room_seat` VALUES (44, 'A2', 2, 1, 2, 0);
INSERT INTO `room_seat` VALUES (45, 'A3', 2, 1, 3, 0);
INSERT INTO `room_seat` VALUES (46, 'A4', 2, 1, 4, 0);
INSERT INTO `room_seat` VALUES (47, 'A5', 2, 1, 5, 0);
INSERT INTO `room_seat` VALUES (48, 'B1', 2, 2, 1, 0);
INSERT INTO `room_seat` VALUES (49, 'B2', 2, 2, 2, 0);
INSERT INTO `room_seat` VALUES (50, 'B3', 2, 2, 3, 0);
INSERT INTO `room_seat` VALUES (51, 'B4', 2, 2, 4, 0);
INSERT INTO `room_seat` VALUES (52, 'B5', 2, 2, 5, 0);
INSERT INTO `room_seat` VALUES (53, 'C1', 2, 3, 2, 0);
INSERT INTO `room_seat` VALUES (54, 'C2', 2, 3, 3, 0);
INSERT INTO `room_seat` VALUES (55, 'C3', 2, 3, 4, 0);
INSERT INTO `room_seat` VALUES (56, 'D1', 2, 4, 1, 0);
INSERT INTO `room_seat` VALUES (57, 'D5', 2, 4, 5, 0);
INSERT INTO `room_seat` VALUES (58, 'D3', 2, 4, 3, 0);
INSERT INTO `room_seat` VALUES (59, 'D2', 2, 4, 2, 0);
INSERT INTO `room_seat` VALUES (60, 'D4', 2, 4, 4, 0);
INSERT INTO `room_seat` VALUES (61, 'E1', 2, 5, 1, 1);
INSERT INTO `room_seat` VALUES (62, 'E2', 2, 5, 2, 1);
INSERT INTO `room_seat` VALUES (63, 'E3', 2, 5, 3, 1);
INSERT INTO `room_seat` VALUES (64, 'E4', 2, 5, 4, 0);
INSERT INTO `room_seat` VALUES (65, 'E5', 2, 5, 5, 0);
INSERT INTO `room_seat` VALUES (66, '1-B', 3, 1, 2, 0);
INSERT INTO `room_seat` VALUES (68, '1-D', 3, 1, 6, 0);
INSERT INTO `room_seat` VALUES (69, '1-A', 3, 1, 1, 0);
INSERT INTO `room_seat` VALUES (70, '1-C', 3, 1, 3, 0);
INSERT INTO `room_seat` VALUES (71, '1-E', 3, 1, 7, 0);
INSERT INTO `room_seat` VALUES (72, '1-F', 3, 1, 8, 0);
INSERT INTO `room_seat` VALUES (73, '2-A', 3, 3, 1, 0);
INSERT INTO `room_seat` VALUES (74, '2-B', 3, 3, 2, 0);
INSERT INTO `room_seat` VALUES (75, '2-C', 3, 3, 3, 0);
INSERT INTO `room_seat` VALUES (76, '2-D', 3, 3, 6, 0);
INSERT INTO `room_seat` VALUES (77, '2-E', 3, 3, 7, 0);
INSERT INTO `room_seat` VALUES (78, '2-F', 3, 3, 8, 0);
INSERT INTO `room_seat` VALUES (79, '3-A', 3, 5, 1, 0);
INSERT INTO `room_seat` VALUES (80, '3-B', 3, 5, 2, 0);
INSERT INTO `room_seat` VALUES (81, '3-C', 3, 5, 3, 0);
INSERT INTO `room_seat` VALUES (82, '3-D', 3, 5, 6, 0);
INSERT INTO `room_seat` VALUES (83, '3-E', 3, 5, 7, 0);
INSERT INTO `room_seat` VALUES (84, '3-F', 3, 5, 8, 0);
INSERT INTO `room_seat` VALUES (85, '001', 4, 1, 1, 0);
INSERT INTO `room_seat` VALUES (86, '002', 4, 1, 2, 0);
INSERT INTO `room_seat` VALUES (87, '003', 4, 1, 3, 0);
INSERT INTO `room_seat` VALUES (88, '004', 4, 1, 4, 0);
INSERT INTO `room_seat` VALUES (89, '005', 4, 1, 5, 0);
INSERT INTO `room_seat` VALUES (90, '006', 4, 1, 6, 0);
INSERT INTO `room_seat` VALUES (91, '007', 4, 2, 1, 0);
INSERT INTO `room_seat` VALUES (92, '008', 4, 2, 2, 0);
INSERT INTO `room_seat` VALUES (93, '009', 4, 2, 3, 0);
INSERT INTO `room_seat` VALUES (94, '010', 4, 2, 4, 0);
INSERT INTO `room_seat` VALUES (95, '011', 4, 2, 5, 0);
INSERT INTO `room_seat` VALUES (96, '012', 4, 2, 6, 0);
INSERT INTO `room_seat` VALUES (97, '013', 4, 3, 1, 0);
INSERT INTO `room_seat` VALUES (98, '014', 4, 3, 2, 0);
INSERT INTO `room_seat` VALUES (99, '015', 4, 3, 3, 0);
INSERT INTO `room_seat` VALUES (100, '016', 4, 3, 4, 0);
INSERT INTO `room_seat` VALUES (101, '017', 4, 3, 5, 0);
INSERT INTO `room_seat` VALUES (102, '018', 4, 3, 6, 0);
INSERT INTO `room_seat` VALUES (103, '019', 4, 4, 1, 0);
INSERT INTO `room_seat` VALUES (104, '020', 4, 4, 2, 0);
INSERT INTO `room_seat` VALUES (105, '021', 4, 4, 3, 0);
INSERT INTO `room_seat` VALUES (106, '022', 4, 4, 4, 0);
INSERT INTO `room_seat` VALUES (107, '023', 4, 4, 5, 0);
INSERT INTO `room_seat` VALUES (108, '024', 4, 4, 6, 0);
INSERT INTO `room_seat` VALUES (109, '025', 4, 5, 1, 0);
INSERT INTO `room_seat` VALUES (110, '026', 4, 5, 2, 0);
INSERT INTO `room_seat` VALUES (111, '027', 4, 5, 3, 0);
INSERT INTO `room_seat` VALUES (112, '028', 4, 5, 4, 0);
INSERT INTO `room_seat` VALUES (113, '029', 4, 5, 5, 0);
INSERT INTO `room_seat` VALUES (114, '030', 4, 5, 6, 0);
INSERT INTO `room_seat` VALUES (115, 'B3', 5, 2, 3, 0);
INSERT INTO `room_seat` VALUES (116, 'B4', 5, 2, 4, 0);
INSERT INTO `room_seat` VALUES (117, 'B5', 5, 2, 5, 0);
INSERT INTO `room_seat` VALUES (118, 'B6', 5, 2, 6, 0);
INSERT INTO `room_seat` VALUES (119, 'B7', 5, 2, 7, 0);
INSERT INTO `room_seat` VALUES (120, 'B8', 5, 2, 8, 0);
INSERT INTO `room_seat` VALUES (121, 'C1', 5, 3, 1, 0);
INSERT INTO `room_seat` VALUES (122, 'C2', 5, 3, 2, 0);
INSERT INTO `room_seat` VALUES (123, 'C6', 5, 3, 6, 0);
INSERT INTO `room_seat` VALUES (124, 'C7', 5, 3, 7, 0);
INSERT INTO `room_seat` VALUES (125, 'F2', 5, 6, 4, 0);
INSERT INTO `room_seat` VALUES (126, 'F3', 5, 6, 5, 0);
INSERT INTO `room_seat` VALUES (127, 'F1', 5, 6, 3, 0);
INSERT INTO `room_seat` VALUES (128, 'F4', 5, 6, 6, 0);
INSERT INTO `room_seat` VALUES (129, 'D1', 5, 4, 1, 0);
INSERT INTO `room_seat` VALUES (130, 'D2', 5, 4, 2, 0);
INSERT INTO `room_seat` VALUES (131, 'D3', 5, 4, 3, 0);
INSERT INTO `room_seat` VALUES (132, 'D6', 5, 4, 6, 0);
INSERT INTO `room_seat` VALUES (133, 'D7', 5, 4, 7, 0);
INSERT INTO `room_seat` VALUES (134, 'D8', 5, 4, 8, 0);


-- ----------------------------
-- Table structure for room_feedback_record (反馈申诉)
-- ----------------------------
DROP TABLE IF EXISTS `room_feedback_record`;
CREATE TABLE `room_feedback_record` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `feedback_type` VARCHAR(32) NOT NULL COMMENT '反馈类型',
  `content` VARCHAR(1000) NOT NULL COMMENT '反馈内容',
  `quiet_score` TINYINT NULL DEFAULT NULL COMMENT '安静度评分',
  `lighting_score` TINYINT NULL DEFAULT NULL COMMENT '照明评分',
  `status` VARCHAR(32) NOT NULL DEFAULT '待处理' COMMENT '处理状态',
  `handle_remark` VARCHAR(1000) DEFAULT NULL COMMENT '处理备注',
  `create_by` VARCHAR(64) DEFAULT '' COMMENT '创建者',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` VARCHAR(64) DEFAULT '' COMMENT '更新者',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `remark` VARCHAR(500) DEFAULT NULL COMMENT '备注',
  `appeal_evidence` VARCHAR(2000) DEFAULT NULL COMMENT '申诉凭证URL等',
  PRIMARY KEY (`id`),
  KEY `idx_feedback_user_id` (`user_id`),
  KEY `idx_feedback_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='反馈申诉记录表';

-- ----------------------------
-- 论文扩展业务表
-- ----------------------------
DROP TABLE IF EXISTS `room_campus_code`;
CREATE TABLE `room_campus_code` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `campus_account` VARCHAR(64) NOT NULL COMMENT '校园账号/学号',
  `code` VARCHAR(10) NOT NULL,
  `expire_time` DATETIME NOT NULL,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_campus` (`campus_account`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='校园登录短信验证码';

DROP TABLE IF EXISTS `room_user_course`;
CREATE TABLE `room_user_course` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL,
  `week_day` TINYINT NOT NULL COMMENT '1-7 周一到周日',
  `start_time` TIME NOT NULL,
  `end_time` TIME NOT NULL,
  `course_name` VARCHAR(100) DEFAULT NULL,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_uc_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学生课程时段';

DROP TABLE IF EXISTS `room_blacklist`;
CREATE TABLE `room_blacklist` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL,
  `reason` VARCHAR(500) DEFAULT NULL,
  `until_date` DATE NOT NULL COMMENT '解禁日期（含当日仍不可约）',
  `status` CHAR(1) DEFAULT '0' COMMENT '0封禁 1已解除',
  `create_by` VARCHAR(64) DEFAULT '',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `remark` VARCHAR(500) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_bl_user` (`user_id`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='预约黑名单';

DROP TABLE IF EXISTS `room_violation`;
CREATE TABLE `room_violation` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL,
  `reservation_id` BIGINT DEFAULT NULL,
  `violation_type` VARCHAR(64) NOT NULL,
  `description` VARCHAR(2000) DEFAULT NULL,
  `evidence_urls` VARCHAR(2000) DEFAULT NULL,
  `sign_log` TEXT,
  `create_by` VARCHAR(64) DEFAULT '',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_v_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='违规追溯卡';

DROP TABLE IF EXISTS `room_medal_def`;
CREATE TABLE `room_medal_def` (
  `code` VARCHAR(32) NOT NULL,
  `name` VARCHAR(64) NOT NULL,
  `need_minutes` INT NOT NULL,
  `perk_desc` VARCHAR(200) DEFAULT NULL,
  `sort_order` INT DEFAULT 0,
  PRIMARY KEY (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='勋章定义';

DROP TABLE IF EXISTS `room_user_medal`;
CREATE TABLE `room_user_medal` (
  `user_id` BIGINT NOT NULL,
  `medal_code` VARCHAR(32) NOT NULL,
  `unlock_time` DATETIME NOT NULL,
  `redeemed` CHAR(1) DEFAULT '0',
  PRIMARY KEY (`user_id`, `medal_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户勋章';

DROP TABLE IF EXISTS `room_user_study_stats`;
CREATE TABLE `room_user_study_stats` (
  `user_id` BIGINT NOT NULL,
  `total_effective_minutes` BIGINT NOT NULL DEFAULT 0,
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='有效学习时长累计';

DROP TABLE IF EXISTS `room_carpool_group`;
CREATE TABLE `room_carpool_group` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `room_id` INT NOT NULL,
  `leader_user_id` BIGINT NOT NULL,
  `seat_count` INT NOT NULL DEFAULT 2,
  `share_code` VARCHAR(32) NOT NULL,
  `status` VARCHAR(32) DEFAULT '招募中',
  `expire_time` DATETIME DEFAULT NULL,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_share` (`share_code`),
  KEY `idx_room` (`room_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='拼座小组';

DROP TABLE IF EXISTS `room_cleaning_plan`;
CREATE TABLE `room_cleaning_plan` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `room_id` INT NOT NULL,
  `plan_date` DATE NOT NULL,
  `time_slot` VARCHAR(32) DEFAULT NULL,
  `cleaner` VARCHAR(64) DEFAULT NULL,
  `status` VARCHAR(32) DEFAULT '待执行',
  `reason` VARCHAR(500) DEFAULT NULL,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_cp_room_date` (`room_id`, `plan_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='保洁排班';

DROP TABLE IF EXISTS `room_repair_ticket`;
CREATE TABLE `room_repair_ticket` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `room_name` VARCHAR(128) NOT NULL COMMENT '自习室名称',
  `seat_number` VARCHAR(64) DEFAULT NULL COMMENT '座位编号',
  `reporter_user_id` BIGINT DEFAULT NULL,
  `fault_type` VARCHAR(64) DEFAULT NULL,
  `content` VARCHAR(2000) DEFAULT NULL,
  `status` VARCHAR(32) DEFAULT '待处理',
  `assignee` VARCHAR(64) DEFAULT NULL,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_rt_room` (`room_name`),
  KEY `idx_rt_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='设备报修工单';

DROP TABLE IF EXISTS `room_app_reminder`;
CREATE TABLE `room_app_reminder` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL,
  `reservation_id` BIGINT NOT NULL,
  `title` VARCHAR(128) NOT NULL,
  `body` VARCHAR(500) DEFAULT NULL,
  `fire_time` DATETIME NOT NULL,
  `is_read` CHAR(1) DEFAULT '0',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ar_user` (`user_id`, `is_read`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='预约提醒';

DROP TABLE IF EXISTS `room_usage_alert`;
CREATE TABLE `room_usage_alert` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `room_id` INT NOT NULL,
  `alert_date` DATE NOT NULL,
  `rate_percent` DECIMAL(5,2) NOT NULL,
  `message` VARCHAR(500) DEFAULT NULL,
  `is_read` CHAR(1) DEFAULT '0',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ua_room` (`room_id`, `alert_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='使用率预警';

DROP TABLE IF EXISTS `room_business_audit`;
CREATE TABLE `room_business_audit` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT DEFAULT NULL,
  `action_type` VARCHAR(64) NOT NULL,
  `ref_type` VARCHAR(32) DEFAULT NULL,
  `ref_id` BIGINT DEFAULT NULL,
  `detail` VARCHAR(2000) DEFAULT NULL,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ba_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='业务审计';

INSERT IGNORE INTO `room_medal_def` (`code`, `name`, `need_minutes`, `perk_desc`, `sort_order`) VALUES
('L1', '入门学霸', 120, '优先预约体验', 1),
('L2', '进阶学霸', 600, '优先预约加权', 2),
('L3', '学霸达人', 2000, '高峰保障', 3);


-- ----------------------------
-- Table structure for sys_config
-- ----------------------------
DROP TABLE IF EXISTS `sys_config`;
CREATE TABLE `sys_config`  (
  `config_id` int NOT NULL AUTO_INCREMENT COMMENT '参数主键',
  `config_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '参数名称',
  `config_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '参数键名',
  `config_value` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '参数键值',
  `config_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT 'N' COMMENT '系统内置（Y是 N否）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`config_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 200 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '参数配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_config
-- ----------------------------
INSERT INTO `sys_config` VALUES (1, '主框架页-默认皮肤样式名称', 'sys.index.skinName', 'skin-blue', 'Y', 'admin', '2025-10-29 15:39:49', '', NULL, '蓝色 skin-blue、绿色 skin-green、紫色 skin-purple、红色 skin-red、黄色 skin-yellow');
INSERT INTO `sys_config` VALUES (2, '用户管理-账号初始密码', 'sys.user.initPassword', '123456', 'Y', 'admin', '2025-10-29 15:39:49', '', NULL, '初始化密码 123456');
INSERT INTO `sys_config` VALUES (3, '主框架页-侧边栏主题', 'sys.index.sideTheme', 'theme-dark', 'Y', 'admin', '2025-10-29 15:39:49', '', NULL, '深色主题theme-dark，浅色主题theme-light');
INSERT INTO `sys_config` VALUES (4, '账号自助-验证码开关', 'sys.account.captchaEnabled', 'false', 'Y', 'admin', '2025-10-29 15:39:49', 'admin', '2025-10-29 21:11:03', '是否开启验证码功能（true开启，false关闭）');
INSERT INTO `sys_config` VALUES (5, '账号自助-是否开启用户注册功能', 'sys.account.registerUser', 'false', 'Y', 'admin', '2025-10-29 15:39:49', '', NULL, '是否开启注册用户功能（true开启，false关闭）');
INSERT INTO `sys_config` VALUES (6, '用户登录-黑名单列表', 'sys.login.blackIPList', '', 'Y', 'admin', '2025-10-29 15:39:49', '', NULL, '设置登录IP黑名单限制，多个匹配项以;分隔，支持匹配（*通配、网段）');
INSERT INTO `sys_config` VALUES (7, '用户管理-初始密码修改策略', 'sys.account.initPasswordModify', '1', 'Y', 'admin', '2025-10-29 15:39:49', '', NULL, '0：初始密码修改策略关闭，没有任何提示，1：提醒用户，如果未修改初始密码，则在登录时就会提醒修改密码对话框');
INSERT INTO `sys_config` VALUES (8, '用户管理-账号密码更新周期', 'sys.account.passwordValidateDays', '0', 'Y', 'admin', '2025-10-29 15:39:49', '', NULL, '密码更新周期（填写数字，数据初始化值为0不限制，若修改必须为大于0小于365的正整数），如果超过这个周期登录系统时，则在登录时就会提醒修改密码对话框');
INSERT INTO `sys_config` VALUES (9, '校园短信演示模式', 'campus.sms.mock', 'true', 'Y', 'admin', NOW(), '', NULL, 'true=固定验证码123456');
INSERT INTO `sys_config` VALUES (10, '预约最短时长(小时)', 'reservation.minHours', '1', 'Y', 'admin', NOW(), '', NULL, NULL);
INSERT INTO `sys_config` VALUES (11, '预约最长时长(小时)', 'reservation.maxHours', '4', 'Y', 'admin', NOW(), '', NULL, NULL);
INSERT INTO `sys_config` VALUES (12, '预约订单是否需审核', 'reservation.audit.enabled', 'false', 'Y', 'admin', NOW(), '', NULL, '考试周等可在后台改为 true');
INSERT INTO `sys_config` VALUES (13, '未签到自动释放分钟数', 'reservation.noSignIn.releaseMinutes', '15', 'Y', 'admin', NOW(), '', NULL, '与论文「15分钟内未签到」一致');
INSERT INTO `sys_config` VALUES (14, '黑名单默认天数', 'violation.blacklist.days', '7', 'Y', 'admin', NOW(), '', NULL, NULL);
INSERT INTO `sys_config` VALUES (15, '高峰预警预约率%', 'reservation.alert.usagePercent', '70', 'Y', 'admin', NOW(), '', NULL, NULL);
INSERT INTO `sys_config` VALUES (16, '舒适度权重-安静', 'comfort.weight.quiet', '0.5', 'Y', 'admin', NOW(), '', NULL, NULL);
INSERT INTO `sys_config` VALUES (17, '舒适度权重-照明', 'comfort.weight.lighting', '0.5', 'Y', 'admin', NOW(), '', NULL, NULL);
INSERT INTO `sys_config` VALUES (18, '预约提醒提前分钟', 'reservation.reminder.minutesBefore', '30', 'Y', 'admin', NOW(), '', NULL, NULL);

-- ----------------------------
-- Table structure for sys_dept
-- ----------------------------
DROP TABLE IF EXISTS `sys_dept`;
CREATE TABLE `sys_dept`  (
  `dept_id` bigint NOT NULL AUTO_INCREMENT COMMENT '部门id',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父部门id',
  `ancestors` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '祖级列表',
  `dept_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '部门名称',
  `order_num` int NULL DEFAULT 0 COMMENT '显示顺序',
  `leader` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '负责人',
  `phone` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '联系电话',
  `email` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '邮箱',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '0' COMMENT '部门状态（0正常 1停用）',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`dept_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 202 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '部门表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_dept
-- ----------------------------
INSERT INTO `sys_dept` VALUES (100, 0, '0', '肥猫科技', 0, '肥猫BOY', '13866666666', 'FMBOY520@qq.com', '0', '0', 'admin', '2025-10-29 15:39:48', 'admin', '2025-10-29 16:19:24');
INSERT INTO `sys_dept` VALUES (101, 100, '0,100', '深圳总公司', 1, '若依', '15888888888', 'ry@qq.com', '0', '2', 'admin', '2025-10-29 15:39:48', '', NULL);
INSERT INTO `sys_dept` VALUES (102, 100, '0,100', '长沙分公司', 2, '若依', '15888888888', 'ry@qq.com', '0', '2', 'admin', '2025-10-29 15:39:48', '', NULL);
INSERT INTO `sys_dept` VALUES (103, 101, '0,100,101', '研发部门', 1, '若依', '15888888888', 'ry@qq.com', '0', '2', 'admin', '2025-10-29 15:39:48', '', NULL);
INSERT INTO `sys_dept` VALUES (104, 101, '0,100,101', '市场部门', 2, '若依', '15888888888', 'ry@qq.com', '0', '2', 'admin', '2025-10-29 15:39:48', '', NULL);
INSERT INTO `sys_dept` VALUES (105, 101, '0,100,101', '测试部门', 3, '若依', '15888888888', 'ry@qq.com', '0', '2', 'admin', '2025-10-29 15:39:48', '', NULL);
INSERT INTO `sys_dept` VALUES (106, 101, '0,100,101', '财务部门', 4, '若依', '15888888888', 'ry@qq.com', '0', '2', 'admin', '2025-10-29 15:39:48', '', NULL);
INSERT INTO `sys_dept` VALUES (107, 101, '0,100,101', '运维部门', 5, '若依', '15888888888', 'ry@qq.com', '0', '2', 'admin', '2025-10-29 15:39:48', '', NULL);
INSERT INTO `sys_dept` VALUES (108, 102, '0,100,102', '市场部门', 1, '若依', '15888888888', 'ry@qq.com', '0', '2', 'admin', '2025-10-29 15:39:48', '', NULL);
INSERT INTO `sys_dept` VALUES (109, 102, '0,100,102', '财务部门', 2, '若依', '15888888888', 'ry@qq.com', '0', '2', 'admin', '2025-10-29 15:39:48', '', NULL);
INSERT INTO `sys_dept` VALUES (200, 100, '0,100', '自习室', 0, '肥猫BOY', '13866666666', 'FMBOY520@qq.com', '0', '0', 'admin', '2025-10-29 17:06:52', '', NULL);
INSERT INTO `sys_dept` VALUES (201, 200, '0,100,200', '学生', 0, NULL, NULL, NULL, '0', '0', 'admin', '2025-11-22 20:40:37', 'admin', '2025-11-22 20:40:58');

-- ----------------------------
-- Table structure for sys_dict_data
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_data`;
CREATE TABLE `sys_dict_data`  (
  `dict_code` bigint NOT NULL AUTO_INCREMENT COMMENT '字典编码',
  `dict_sort` int NULL DEFAULT 0 COMMENT '字典排序',
  `dict_label` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '字典标签',
  `dict_value` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '字典键值',
  `dict_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '字典类型',
  `css_class` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '样式属性（其他样式扩展）',
  `list_class` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '表格回显样式',
  `is_default` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT 'N' COMMENT '是否默认（Y是 N否）',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`dict_code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '字典数据表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_dict_data
-- ----------------------------
INSERT INTO `sys_dict_data` VALUES (1, 1, '男', '0', 'sys_user_sex', '', '', 'Y', '0', 'admin', '2025-10-29 15:39:49', '', NULL, '性别男');
INSERT INTO `sys_dict_data` VALUES (2, 2, '女', '1', 'sys_user_sex', '', '', 'N', '0', 'admin', '2025-10-29 15:39:49', '', NULL, '性别女');
INSERT INTO `sys_dict_data` VALUES (3, 3, '未知', '2', 'sys_user_sex', '', '', 'N', '0', 'admin', '2025-10-29 15:39:49', '', NULL, '性别未知');
INSERT INTO `sys_dict_data` VALUES (4, 1, '显示', '0', 'sys_show_hide', '', 'primary', 'Y', '0', 'admin', '2025-10-29 15:39:49', '', NULL, '显示菜单');
INSERT INTO `sys_dict_data` VALUES (5, 2, '隐藏', '1', 'sys_show_hide', '', 'danger', 'N', '0', 'admin', '2025-10-29 15:39:49', '', NULL, '隐藏菜单');
INSERT INTO `sys_dict_data` VALUES (6, 1, '正常', '0', 'sys_normal_disable', '', 'primary', 'Y', '0', 'admin', '2025-10-29 15:39:49', '', NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES (7, 2, '停用', '1', 'sys_normal_disable', '', 'danger', 'N', '0', 'admin', '2025-10-29 15:39:49', '', NULL, '停用状态');
INSERT INTO `sys_dict_data` VALUES (8, 1, '正常', '0', 'sys_job_status', '', 'primary', 'Y', '0', 'admin', '2025-10-29 15:39:49', '', NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES (9, 2, '暂停', '1', 'sys_job_status', '', 'danger', 'N', '0', 'admin', '2025-10-29 15:39:49', '', NULL, '停用状态');
INSERT INTO `sys_dict_data` VALUES (10, 1, '默认', 'DEFAULT', 'sys_job_group', '', '', 'Y', '0', 'admin', '2025-10-29 15:39:49', '', NULL, '默认分组');
INSERT INTO `sys_dict_data` VALUES (11, 2, '系统', 'SYSTEM', 'sys_job_group', '', '', 'N', '0', 'admin', '2025-10-29 15:39:49', '', NULL, '系统分组');
INSERT INTO `sys_dict_data` VALUES (12, 1, '是', 'Y', 'sys_yes_no', '', 'primary', 'Y', '0', 'admin', '2025-10-29 15:39:49', '', NULL, '系统默认是');
INSERT INTO `sys_dict_data` VALUES (13, 2, '否', 'N', 'sys_yes_no', '', 'danger', 'N', '0', 'admin', '2025-10-29 15:39:49', '', NULL, '系统默认否');
INSERT INTO `sys_dict_data` VALUES (14, 1, '通知', '1', 'sys_notice_type', '', 'warning', 'Y', '0', 'admin', '2025-10-29 15:39:49', '', NULL, '通知');
INSERT INTO `sys_dict_data` VALUES (15, 2, '公告', '2', 'sys_notice_type', '', 'success', 'N', '0', 'admin', '2025-10-29 15:39:49', '', NULL, '公告');
INSERT INTO `sys_dict_data` VALUES (16, 1, '正常', '0', 'sys_notice_status', '', 'primary', 'Y', '0', 'admin', '2025-10-29 15:39:49', '', NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES (17, 2, '关闭', '1', 'sys_notice_status', '', 'danger', 'N', '0', 'admin', '2025-10-29 15:39:49', '', NULL, '关闭状态');
INSERT INTO `sys_dict_data` VALUES (18, 99, '其他', '0', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2025-10-29 15:39:49', '', NULL, '其他操作');
INSERT INTO `sys_dict_data` VALUES (19, 1, '新增', '1', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2025-10-29 15:39:49', '', NULL, '新增操作');
INSERT INTO `sys_dict_data` VALUES (20, 2, '修改', '2', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2025-10-29 15:39:49', '', NULL, '修改操作');
INSERT INTO `sys_dict_data` VALUES (21, 3, '删除', '3', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2025-10-29 15:39:49', '', NULL, '删除操作');
INSERT INTO `sys_dict_data` VALUES (22, 4, '授权', '4', 'sys_oper_type', '', 'primary', 'N', '0', 'admin', '2025-10-29 15:39:49', '', NULL, '授权操作');
INSERT INTO `sys_dict_data` VALUES (23, 5, '导出', '5', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2025-10-29 15:39:49', '', NULL, '导出操作');
INSERT INTO `sys_dict_data` VALUES (24, 6, '导入', '6', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2025-10-29 15:39:49', '', NULL, '导入操作');
INSERT INTO `sys_dict_data` VALUES (25, 7, '强退', '7', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2025-10-29 15:39:49', '', NULL, '强退操作');
INSERT INTO `sys_dict_data` VALUES (26, 8, '生成代码', '8', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2025-10-29 15:39:49', '', NULL, '生成操作');
INSERT INTO `sys_dict_data` VALUES (27, 9, '清空数据', '9', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2025-10-29 15:39:49', '', NULL, '清空操作');
INSERT INTO `sys_dict_data` VALUES (28, 1, '成功', '0', 'sys_common_status', '', 'primary', 'N', '0', 'admin', '2025-10-29 15:39:49', '', NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES (29, 2, '失败', '1', 'sys_common_status', '', 'danger', 'N', '0', 'admin', '2025-10-29 15:39:49', '', NULL, '停用状态');

-- ----------------------------
-- Table structure for sys_dict_type
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_type`;
CREATE TABLE `sys_dict_type`  (
  `dict_id` bigint NOT NULL AUTO_INCREMENT COMMENT '字典主键',
  `dict_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '字典名称',
  `dict_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '字典类型',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`dict_id`) USING BTREE,
  UNIQUE INDEX `dict_type`(`dict_type`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '字典类型表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_dict_type
-- ----------------------------
INSERT INTO `sys_dict_type` VALUES (1, '用户性别', 'sys_user_sex', '0', 'admin', '2025-10-29 15:39:49', '', NULL, '用户性别列表');
INSERT INTO `sys_dict_type` VALUES (2, '菜单状态', 'sys_show_hide', '0', 'admin', '2025-10-29 15:39:49', '', NULL, '菜单状态列表');
INSERT INTO `sys_dict_type` VALUES (3, '系统开关', 'sys_normal_disable', '0', 'admin', '2025-10-29 15:39:49', '', NULL, '系统开关列表');
INSERT INTO `sys_dict_type` VALUES (4, '任务状态', 'sys_job_status', '0', 'admin', '2025-10-29 15:39:49', '', NULL, '任务状态列表');
INSERT INTO `sys_dict_type` VALUES (5, '任务分组', 'sys_job_group', '0', 'admin', '2025-10-29 15:39:49', '', NULL, '任务分组列表');
INSERT INTO `sys_dict_type` VALUES (6, '系统是否', 'sys_yes_no', '0', 'admin', '2025-10-29 15:39:49', '', NULL, '系统是否列表');
INSERT INTO `sys_dict_type` VALUES (7, '通知类型', 'sys_notice_type', '0', 'admin', '2025-10-29 15:39:49', '', NULL, '通知类型列表');
INSERT INTO `sys_dict_type` VALUES (8, '通知状态', 'sys_notice_status', '0', 'admin', '2025-10-29 15:39:49', '', NULL, '通知状态列表');
INSERT INTO `sys_dict_type` VALUES (9, '操作类型', 'sys_oper_type', '0', 'admin', '2025-10-29 15:39:49', '', NULL, '操作类型列表');
INSERT INTO `sys_dict_type` VALUES (10, '系统状态', 'sys_common_status', '0', 'admin', '2025-10-29 15:39:49', '', NULL, '登录状态列表');

-- ----------------------------
-- Table structure for sys_job
-- ----------------------------
DROP TABLE IF EXISTS `sys_job`;
CREATE TABLE `sys_job`  (
  `job_id` bigint NOT NULL AUTO_INCREMENT COMMENT '任务ID',
  `job_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '' COMMENT '任务名称',
  `job_group` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'DEFAULT' COMMENT '任务组名',
  `invoke_target` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '调用目标字符串',
  `cron_expression` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT 'cron执行表达式',
  `misfire_policy` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '3' COMMENT '计划执行错误策略（1立即执行 2执行一次 3放弃执行）',
  `concurrent` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '1' COMMENT '是否并发执行（0允许 1禁止）',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '0' COMMENT '状态（0正常 1暂停）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '备注信息',
  PRIMARY KEY (`job_id`, `job_name`, `job_group`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '定时任务调度表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_job
-- ----------------------------
INSERT INTO `sys_job` VALUES (1, '系统默认（无参）', 'DEFAULT', 'ryTask.ryNoParams', '0/10 * * * * ?', '3', '1', '1', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_job` VALUES (2, '系统默认（有参）', 'DEFAULT', 'ryTask.ryParams(\'ry\')', '0/15 * * * * ?', '3', '1', '1', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_job` VALUES (3, '系统默认（多参）', 'DEFAULT', 'ryTask.ryMultipleParams(\'ry\', true, 2000L, 316.50D, 100)', '0/20 * * * * ?', '3', '1', '1', 'admin', '2025-10-29 15:39:49', '', NULL, '');

-- ----------------------------
-- Table structure for sys_job_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_job_log`;
CREATE TABLE `sys_job_log`  (
  `job_log_id` bigint NOT NULL AUTO_INCREMENT COMMENT '任务日志ID',
  `job_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '任务名称',
  `job_group` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '任务组名',
  `invoke_target` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '调用目标字符串',
  `job_message` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '日志信息',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '0' COMMENT '执行状态（0正常 1失败）',
  `exception_info` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '异常信息',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`job_log_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '定时任务调度日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_job_log
-- ----------------------------

-- ----------------------------
-- Table structure for sys_logininfor
-- ----------------------------
DROP TABLE IF EXISTS `sys_logininfor`;
CREATE TABLE `sys_logininfor`  (
  `info_id` bigint NOT NULL AUTO_INCREMENT COMMENT '访问ID',
  `user_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '用户账号',
  `ipaddr` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '登录IP地址',
  `login_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '登录地点',
  `browser` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '浏览器类型',
  `os` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '操作系统',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '0' COMMENT '登录状态（0成功 1失败）',
  `msg` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '提示消息',
  `login_time` datetime NULL DEFAULT NULL COMMENT '访问时间',
  PRIMARY KEY (`info_id`) USING BTREE,
  INDEX `idx_sys_logininfor_s`(`status`) USING BTREE,
  INDEX `idx_sys_logininfor_lt`(`login_time`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 88 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '系统访问记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_logininfor
-- ----------------------------

-- ----------------------------
-- Table structure for sys_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_menu`;
CREATE TABLE `sys_menu`  (
  `menu_id` bigint NOT NULL AUTO_INCREMENT COMMENT '菜单ID',
  `menu_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '菜单名称',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父菜单ID',
  `order_num` int NULL DEFAULT 0 COMMENT '显示顺序',
  `path` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '路由地址',
  `component` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '组件路径',
  `query` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '路由参数',
  `route_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '路由名称',
  `is_frame` int NULL DEFAULT 1 COMMENT '是否为外链（0是 1否）',
  `is_cache` int NULL DEFAULT 0 COMMENT '是否缓存（0缓存 1不缓存）',
  `menu_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '菜单类型（M目录 C菜单 F按钮）',
  `visible` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '0' COMMENT '菜单状态（0显示 1隐藏）',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '0' COMMENT '菜单状态（0正常 1停用）',
  `perms` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '权限标识',
  `icon` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '#' COMMENT '菜单图标',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '备注',
  PRIMARY KEY (`menu_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2018 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '菜单权限表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_menu
-- ----------------------------
INSERT INTO `sys_menu` VALUES (1, '系统管理', 0, 1, 'system', NULL, '', '', 1, 0, 'M', '0', '0', '', 'system', 'admin', '2025-10-29 15:39:49', '', NULL, '系统管理目录');
INSERT INTO `sys_menu` VALUES (2, '系统监控', 0, 2, 'monitor', NULL, '', '', 1, 0, 'M', '0', '0', '', 'monitor', 'admin', '2025-10-29 15:39:49', '', NULL, '系统监控目录');
INSERT INTO `sys_menu` VALUES (3, '系统工具', 0, 3, 'tool', NULL, '', '', 1, 0, 'M', '0', '0', '', 'tool', 'admin', '2025-10-29 15:39:49', '', NULL, '系统工具目录');
INSERT INTO `sys_menu` VALUES (100, '用户管理', 1, 1, 'user', 'system/user/index', '', '', 1, 0, 'C', '0', '0', 'system:user:list', 'user', 'admin', '2025-10-29 15:39:49', '', NULL, '用户管理菜单');
INSERT INTO `sys_menu` VALUES (101, '角色管理', 1, 2, 'role', 'system/role/index', '', '', 1, 0, 'C', '0', '0', 'system:role:list', 'peoples', 'admin', '2025-10-29 15:39:49', '', NULL, '角色管理菜单');
INSERT INTO `sys_menu` VALUES (102, '菜单管理', 1, 3, 'menu', 'system/menu/index', '', '', 1, 0, 'C', '0', '0', 'system:menu:list', 'tree-table', 'admin', '2025-10-29 15:39:49', '', NULL, '菜单管理菜单');
INSERT INTO `sys_menu` VALUES (103, '部门管理', 1, 4, 'dept', 'system/dept/index', '', '', 1, 0, 'C', '0', '0', 'system:dept:list', 'tree', 'admin', '2025-10-29 15:39:49', '', NULL, '部门管理菜单');
INSERT INTO `sys_menu` VALUES (104, '岗位管理', 1, 5, 'post', 'system/post/index', '', '', 1, 0, 'C', '0', '0', 'system:post:list', 'post', 'admin', '2025-10-29 15:39:49', '', NULL, '岗位管理菜单');
INSERT INTO `sys_menu` VALUES (105, '字典管理', 1, 6, 'dict', 'system/dict/index', '', '', 1, 0, 'C', '0', '0', 'system:dict:list', 'dict', 'admin', '2025-10-29 15:39:49', '', NULL, '字典管理菜单');
INSERT INTO `sys_menu` VALUES (106, '参数设置', 1, 7, 'config', 'system/config/index', '', '', 1, 0, 'C', '0', '0', 'system:config:list', 'edit', 'admin', '2025-10-29 15:39:49', '', NULL, '参数设置菜单');
INSERT INTO `sys_menu` VALUES (107, '通知公告', 1, 8, 'notice', 'system/notice/index', '', '', 1, 0, 'C', '0', '0', 'system:notice:list', 'message', 'admin', '2025-10-29 15:39:49', '', NULL, '通知公告菜单');
INSERT INTO `sys_menu` VALUES (108, '日志管理', 1, 9, 'log', '', '', '', 1, 0, 'M', '0', '0', '', 'log', 'admin', '2025-10-29 15:39:49', '', NULL, '日志管理菜单');
INSERT INTO `sys_menu` VALUES (109, '在线用户', 2, 1, 'online', 'monitor/online/index', '', '', 1, 0, 'C', '0', '0', 'monitor:online:list', 'online', 'admin', '2025-10-29 15:39:49', '', NULL, '在线用户菜单');
INSERT INTO `sys_menu` VALUES (110, '定时任务', 2, 2, 'job', 'monitor/job/index', '', '', 1, 0, 'C', '0', '0', 'monitor:job:list', 'job', 'admin', '2025-10-29 15:39:49', '', NULL, '定时任务菜单');
INSERT INTO `sys_menu` VALUES (111, '数据监控', 2, 3, 'druid', 'monitor/druid/index', '', '', 1, 0, 'C', '0', '0', 'monitor:druid:list', 'druid', 'admin', '2025-10-29 15:39:49', '', NULL, '数据监控菜单');
INSERT INTO `sys_menu` VALUES (112, '服务监控', 2, 4, 'server', 'monitor/server/index', '', '', 1, 0, 'C', '0', '0', 'monitor:server:list', 'server', 'admin', '2025-10-29 15:39:49', '', NULL, '服务监控菜单');
INSERT INTO `sys_menu` VALUES (113, '缓存监控', 2, 5, 'cache', 'monitor/cache/index', '', '', 1, 0, 'C', '0', '0', 'monitor:cache:list', 'redis', 'admin', '2025-10-29 15:39:49', '', NULL, '缓存监控菜单');
INSERT INTO `sys_menu` VALUES (114, '缓存列表', 2, 6, 'cacheList', 'monitor/cache/list', '', '', 1, 0, 'C', '0', '0', 'monitor:cache:list', 'redis-list', 'admin', '2025-10-29 15:39:49', '', NULL, '缓存列表菜单');
INSERT INTO `sys_menu` VALUES (115, '表单构建', 3, 1, 'build', 'tool/build/index', '', '', 1, 0, 'C', '0', '0', 'tool:build:list', 'build', 'admin', '2025-10-29 15:39:49', '', NULL, '表单构建菜单');
INSERT INTO `sys_menu` VALUES (116, '代码生成', 3, 2, 'gen', 'tool/gen/index', '', '', 1, 0, 'C', '0', '0', 'tool:gen:list', 'code', 'admin', '2025-10-29 15:39:49', '', NULL, '代码生成菜单');
INSERT INTO `sys_menu` VALUES (117, '系统接口', 3, 3, 'swagger', 'tool/swagger/index', '', '', 1, 0, 'C', '0', '0', 'tool:swagger:list', 'swagger', 'admin', '2025-10-29 15:39:49', 'admin', '2025-11-22 20:49:45', '系统接口菜单');
INSERT INTO `sys_menu` VALUES (500, '操作日志', 108, 1, 'operlog', 'monitor/operlog/index', '', '', 1, 0, 'C', '0', '0', 'monitor:operlog:list', 'form', 'admin', '2025-10-29 15:39:49', '', NULL, '操作日志菜单');
INSERT INTO `sys_menu` VALUES (501, '登录日志', 108, 2, 'logininfor', 'monitor/logininfor/index', '', '', 1, 0, 'C', '0', '0', 'monitor:logininfor:list', 'logininfor', 'admin', '2025-10-29 15:39:49', '', NULL, '登录日志菜单');
INSERT INTO `sys_menu` VALUES (1000, '用户查询', 100, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:query', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1001, '用户新增', 100, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:add', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1002, '用户修改', 100, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:edit', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1003, '用户删除', 100, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:remove', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1004, '用户导出', 100, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:export', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1005, '用户导入', 100, 6, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:import', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1006, '重置密码', 100, 7, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:resetPwd', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1007, '角色查询', 101, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:query', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1008, '角色新增', 101, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:add', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1009, '角色修改', 101, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:edit', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1010, '角色删除', 101, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:remove', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1011, '角色导出', 101, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:export', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1012, '菜单查询', 102, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:query', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1013, '菜单新增', 102, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:add', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1014, '菜单修改', 102, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:edit', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1015, '菜单删除', 102, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:remove', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1016, '部门查询', 103, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:query', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1017, '部门新增', 103, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:add', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1018, '部门修改', 103, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:edit', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1019, '部门删除', 103, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:remove', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1020, '岗位查询', 104, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:query', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1021, '岗位新增', 104, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:add', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1022, '岗位修改', 104, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:edit', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1023, '岗位删除', 104, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:remove', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1024, '岗位导出', 104, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:export', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1025, '字典查询', 105, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:query', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1026, '字典新增', 105, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:add', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1027, '字典修改', 105, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:edit', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1028, '字典删除', 105, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:remove', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1029, '字典导出', 105, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:export', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1030, '参数查询', 106, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:query', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1031, '参数新增', 106, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:add', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1032, '参数修改', 106, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:edit', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1033, '参数删除', 106, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:remove', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1034, '参数导出', 106, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:export', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1035, '公告查询', 107, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:query', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1036, '公告新增', 107, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:add', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1037, '公告修改', 107, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:edit', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1038, '公告删除', 107, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:remove', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1039, '操作查询', 500, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:query', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1040, '操作删除', 500, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:remove', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1041, '日志导出', 500, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:export', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1042, '登录查询', 501, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:query', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1043, '登录删除', 501, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:remove', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1044, '日志导出', 501, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:export', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1045, '账户解锁', 501, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:unlock', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1046, '在线查询', 109, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:query', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1047, '批量强退', 109, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:batchLogout', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1048, '单条强退', 109, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:forceLogout', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1049, '任务查询', 110, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:query', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1050, '任务新增', 110, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:add', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1051, '任务修改', 110, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:edit', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1052, '任务删除', 110, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:remove', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1053, '状态修改', 110, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:changeStatus', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1054, '任务导出', 110, 6, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:export', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1055, '生成查询', 116, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:query', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1056, '生成修改', 116, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:edit', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1057, '生成删除', 116, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:remove', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1058, '导入代码', 116, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:import', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1059, '预览代码', 116, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:preview', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1060, '生成代码', 116, 6, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:code', '#', 'admin', '2025-10-29 15:39:49', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2000, '自习室管理', 0, 101, 'room', 'reservation/room/index', NULL, '', 1, 0, 'C', '0', '0', 'reservation:room:list', 'tab', 'admin', '2025-10-30 18:52:11', 'admin', '2025-11-03 18:01:47', '自习室管理菜单');
INSERT INTO `sys_menu` VALUES (2001, '自习室管理查询', 2000, 1, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'reservation:room:query', '#', 'admin', '2025-10-30 18:52:12', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2002, '自习室管理新增', 2000, 2, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'reservation:room:add', '#', 'admin', '2025-10-30 18:52:12', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2003, '自习室管理修改', 2000, 3, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'reservation:room:edit', '#', 'admin', '2025-10-30 18:52:12', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2004, '自习室管理删除', 2000, 4, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'reservation:room:remove', '#', 'admin', '2025-10-30 18:52:12', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2005, '自习室管理导出', 2000, 5, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'reservation:room:export', '#', 'admin', '2025-10-30 18:52:12', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2006, '自习室座位管理', 0, 102, 'seat', 'reservation/seat/index', NULL, '', 1, 0, 'C', '0', '0', 'reservation:seat:list', 'table', 'admin', '2025-10-30 22:20:21', 'admin', '2025-10-30 22:21:38', '自习室座位管理菜单');
INSERT INTO `sys_menu` VALUES (2007, '自习室座位管理查询', 2006, 1, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'reservation:seat:query', '#', 'admin', '2025-10-30 22:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2008, '自习室座位管理新增', 2006, 2, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'reservation:seat:add', '#', 'admin', '2025-10-30 22:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2009, '自习室座位管理修改', 2006, 3, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'reservation:seat:edit', '#', 'admin', '2025-10-30 22:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2010, '自习室座位管理删除', 2006, 4, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'reservation:seat:remove', '#', 'admin', '2025-10-30 22:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2011, '自习室座位管理导出', 2006, 5, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'reservation:seat:export', '#', 'admin', '2025-10-30 22:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2012, '自习室预约管理', 0, 103, 'reservation', 'reservation/reservation/index', NULL, '', 1, 0, 'C', '0', '0', 'reservation:reservation:list', 'email', 'admin', '2025-11-03 18:00:12', 'admin', '2025-11-03 18:02:07', '自习室预约管理菜单');
INSERT INTO `sys_menu` VALUES (2013, '自习室预约管理查询', 2012, 1, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'reservation:reservation:query', '#', 'admin', '2025-11-03 18:00:14', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2014, '自习室预约管理新增', 2012, 2, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'reservation:reservation:add', '#', 'admin', '2025-11-03 18:00:14', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2015, '自习室预约管理修改', 2012, 3, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'reservation:reservation:edit', '#', 'admin', '2025-11-03 18:00:14', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2016, '自习室预约管理删除', 2012, 4, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'reservation:reservation:remove', '#', 'admin', '2025-11-03 18:00:14', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2017, '自习室预约管理导出', 2012, 5, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'reservation:reservation:export', '#', 'admin', '2025-11-03 18:00:14', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2018, '预约辅助看板', 0, 104, 'reservationAssistant', 'reservation/seatAssistant', NULL, '', 1, 0, 'C', '0', '0', 'reservation:assistant:list', 'chart', 'admin', '2026-03-25 00:00:00', 'admin', '2026-03-25 00:00:00', '预约辅助看板菜单');
INSERT INTO `sys_menu` VALUES (2019, '签到退管理', 0, 105, 'signInOut', 'reservation/reservation/index', NULL, '', 1, 0, 'C', '0', '0', 'reservation:reservation:list', 'clipboard', 'admin', '2026-03-25 00:00:00', 'admin', '2026-03-25 00:00:00', '签到退管理菜单');
INSERT INTO `sys_menu` VALUES (2020, '预约审核', 2012, 6, '', '', NULL, '', 1, 0, 'F', '0', '0', 'reservation:reservation:audit', '#', 'admin', NOW(), '', NULL, '审核通过、审核拒绝');
INSERT INTO `sys_menu` VALUES (2100, '自习室运营中心', 0, 106, 'thesisOps', NULL, '', '', 1, 0, 'M', '0', '0', '', 'guide', 'admin', NOW(), '', NULL, '论文扩展运营');
INSERT INTO `sys_menu` VALUES (2101, '违规追溯卡', 2100, 1, 'violation', 'thesis/violation/index', NULL, '', 1, 0, 'C', '0', '0', 'thesis:violation:list', 'message', 'admin', NOW(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (2102, '黑名单管理', 2100, 2, 'blacklist', 'thesis/blacklist/index', NULL, '', 1, 0, 'C', '0', '0', 'thesis:blacklist:list', 'lock', 'admin', NOW(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (2103, '报修工单', 2100, 3, 'repair', 'thesis/repair/index', NULL, '', 1, 0, 'C', '0', '0', 'thesis:repair:list', 'tool', 'admin', NOW(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (2104, '保洁排班', 2100, 4, 'cleaning', 'thesis/cleaning/index', NULL, '', 1, 0, 'C', '0', '0', 'thesis:cleaning:list', 'date', 'admin', NOW(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (2105, '全局数据看板', 2100, 5, 'superDash', 'thesis/superDash/index', NULL, '', 1, 0, 'C', '0', '0', 'thesis:dashboard:list', 'chart', 'admin', NOW(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (2106, '资源优化建议', 2100, 6, 'suggest', 'thesis/suggest/index', NULL, '', 1, 0, 'C', '0', '0', 'thesis:suggest:list', 'education', 'admin', NOW(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (2110, '违规查询', 2101, 1, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'thesis:violation:query', '#', 'admin', NOW(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (2111, '违规新增', 2101, 2, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'thesis:violation:add', '#', 'admin', NOW(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (2112, '违规删除', 2101, 3, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'thesis:violation:remove', '#', 'admin', NOW(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (2120, '黑名单查询', 2102, 1, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'thesis:blacklist:query', '#', 'admin', NOW(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (2121, '黑名单新增', 2102, 2, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'thesis:blacklist:add', '#', 'admin', NOW(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (2122, '黑名单解除', 2102, 3, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'thesis:blacklist:edit', '#', 'admin', NOW(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (2130, '工单查询', 2103, 1, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'thesis:repair:query', '#', 'admin', NOW(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (2131, '工单处理', 2103, 2, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'thesis:repair:edit', '#', 'admin', NOW(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (2140, '排班查询', 2104, 1, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'thesis:cleaning:query', '#', 'admin', NOW(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (2141, '排班生成', 2104, 2, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'thesis:cleaning:add', '#', 'admin', NOW(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (2142, '排班更新', 2104, 3, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'thesis:cleaning:edit', '#', 'admin', NOW(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (2150, '看板导出', 2105, 1, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'thesis:dashboard:export', '#', 'admin', NOW(), '', NULL, '');

-- ----------------------------
-- Table structure for sys_notice
-- ----------------------------
DROP TABLE IF EXISTS `sys_notice`;
CREATE TABLE `sys_notice`  (
  `notice_id` int NOT NULL AUTO_INCREMENT COMMENT '公告ID',
  `notice_title` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '公告标题',
  `notice_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '公告类型（1通知 2公告）',
  `notice_content` longblob NULL COMMENT '公告内容',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '0' COMMENT '公告状态（0正常 1关闭）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`notice_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '通知公告表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_notice
-- ----------------------------

-- ----------------------------
-- Table structure for sys_oper_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_oper_log`;
CREATE TABLE `sys_oper_log`  (
  `oper_id` bigint NOT NULL AUTO_INCREMENT COMMENT '日志主键',
  `title` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '模块标题',
  `business_type` int NULL DEFAULT 0 COMMENT '业务类型（0其它 1新增 2修改 3删除）',
  `method` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '方法名称',
  `request_method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '请求方式',
  `operator_type` int NULL DEFAULT 0 COMMENT '操作类别（0其它 1后台用户 2手机端用户）',
  `oper_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '操作人员',
  `dept_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '部门名称',
  `oper_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '请求URL',
  `oper_ip` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '主机地址',
  `oper_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '操作地点',
  `oper_param` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '请求参数',
  `json_result` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '返回参数',
  `status` int NULL DEFAULT 0 COMMENT '操作状态（0正常 1异常）',
  `error_msg` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '错误消息',
  `oper_time` datetime NULL DEFAULT NULL COMMENT '操作时间',
  `cost_time` bigint NULL DEFAULT 0 COMMENT '消耗时间',
  PRIMARY KEY (`oper_id`) USING BTREE,
  INDEX `idx_sys_oper_log_bt`(`business_type`) USING BTREE,
  INDEX `idx_sys_oper_log_s`(`status`) USING BTREE,
  INDEX `idx_sys_oper_log_ot`(`oper_time`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 218 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '操作日志记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_oper_log
-- ----------------------------
INSERT INTO `sys_oper_log` VALUES (1, '操作日志', 9, 'com.room.web.controller.monitor.SysOperlogController.clean()', 'DELETE', 1, 'admin', '肥猫科技', '/monitor/operlog/clean', '127.0.0.1', '内网IP', '', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-25 22:10:55', 772);
INSERT INTO `sys_oper_log` VALUES (2, '登录日志', 9, 'com.room.web.controller.monitor.SysLogininforController.clean()', 'DELETE', 1, 'admin', '肥猫科技', '/monitor/logininfor/clean', '127.0.0.1', '内网IP', '', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2025-11-25 22:10:59', 175);

-- ----------------------------
-- Table structure for sys_post
-- ----------------------------
DROP TABLE IF EXISTS `sys_post`;
CREATE TABLE `sys_post`  (
  `post_id` bigint NOT NULL AUTO_INCREMENT COMMENT '岗位ID',
  `post_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '岗位编码',
  `post_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '岗位名称',
  `post_sort` int NOT NULL COMMENT '显示顺序',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`post_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '岗位信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_post
-- ----------------------------
INSERT INTO `sys_post` VALUES (1, 'ceo', '董事长', 1, '0', 'admin', '2025-10-29 15:39:48', '', NULL, '');

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role`  (
  `role_id` bigint NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  `role_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '角色名称',
  `role_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '角色权限字符串',
  `role_sort` int NOT NULL COMMENT '显示顺序',
  `data_scope` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '1' COMMENT '数据范围（1：全部数据权限 2：自定数据权限 3：本部门数据权限 4：本部门及以下数据权限）',
  `menu_check_strictly` tinyint(1) NULL DEFAULT 1 COMMENT '菜单树选择项是否关联显示',
  `dept_check_strictly` tinyint(1) NULL DEFAULT 1 COMMENT '部门树选择项是否关联显示',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '角色状态（0正常 1停用）',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`role_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 102 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '角色信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role
-- ----------------------------
INSERT INTO `sys_role` VALUES (1, '超级管理员', 'admin', 1, '1', 1, 1, '0', '0', 'admin', '2025-10-10 00:00:00', '', NULL, '超级管理员');
INSERT INTO `sys_role` VALUES (2, '自习室管理员', 'room', 2, '1', 1, 1, '0', '0', 'admin', '2025-10-10 00:00:00', 'admin', '2025-11-22 21:04:19', NULL);
INSERT INTO `sys_role` VALUES (3, '学生', 'student', 3, '1', 1, 1, '0', '0', 'admin', '2025-10-10 00:00:00', 'admin', '2025-11-22 21:04:40', NULL);

-- ----------------------------
-- Table structure for sys_role_dept
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_dept`;
CREATE TABLE `sys_role_dept`  (
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `dept_id` bigint NOT NULL COMMENT '部门ID',
  PRIMARY KEY (`role_id`, `dept_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '角色和部门关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role_dept
-- ----------------------------

-- ----------------------------
-- Table structure for sys_role_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_menu`;
CREATE TABLE `sys_role_menu`  (
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `menu_id` bigint NOT NULL COMMENT '菜单ID',
  PRIMARY KEY (`role_id`, `menu_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '角色和菜单关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role_menu
-- ----------------------------
-- role_id=1 超级管理员：全量菜单（由脚本末尾 INSERT SELECT 生成）
-- role_id=2 自习室管理员
INSERT INTO `sys_role_menu` VALUES (2, 1);
INSERT INTO `sys_role_menu` VALUES (2, 107);
INSERT INTO `sys_role_menu` VALUES (2, 1035);
INSERT INTO `sys_role_menu` VALUES (2, 2000);
INSERT INTO `sys_role_menu` VALUES (2, 2001);
INSERT INTO `sys_role_menu` VALUES (2, 2002);
INSERT INTO `sys_role_menu` VALUES (2, 2003);
INSERT INTO `sys_role_menu` VALUES (2, 2004);
INSERT INTO `sys_role_menu` VALUES (2, 2005);
INSERT INTO `sys_role_menu` VALUES (2, 2006);
INSERT INTO `sys_role_menu` VALUES (2, 2007);
INSERT INTO `sys_role_menu` VALUES (2, 2008);
INSERT INTO `sys_role_menu` VALUES (2, 2009);
INSERT INTO `sys_role_menu` VALUES (2, 2010);
INSERT INTO `sys_role_menu` VALUES (2, 2011);
INSERT INTO `sys_role_menu` VALUES (2, 2012);
INSERT INTO `sys_role_menu` VALUES (2, 2013);
INSERT INTO `sys_role_menu` VALUES (2, 2014);
INSERT INTO `sys_role_menu` VALUES (2, 2015);
INSERT INTO `sys_role_menu` VALUES (2, 2016);
INSERT INTO `sys_role_menu` VALUES (2, 2017);
INSERT INTO `sys_role_menu` VALUES (2, 2018);
INSERT INTO `sys_role_menu` VALUES (2, 2019);
INSERT INTO `sys_role_menu` VALUES (2, 2020);
INSERT INTO `sys_role_menu` VALUES (2, 2100);
INSERT INTO `sys_role_menu` VALUES (2, 2101);
INSERT INTO `sys_role_menu` VALUES (2, 2102);
INSERT INTO `sys_role_menu` VALUES (2, 2103);
INSERT INTO `sys_role_menu` VALUES (2, 2104);
INSERT INTO `sys_role_menu` VALUES (2, 2110);
INSERT INTO `sys_role_menu` VALUES (2, 2111);
INSERT INTO `sys_role_menu` VALUES (2, 2112);
INSERT INTO `sys_role_menu` VALUES (2, 2120);
INSERT INTO `sys_role_menu` VALUES (2, 2121);
INSERT INTO `sys_role_menu` VALUES (2, 2122);
INSERT INTO `sys_role_menu` VALUES (2, 2130);
INSERT INTO `sys_role_menu` VALUES (2, 2131);
INSERT INTO `sys_role_menu` VALUES (2, 2140);
INSERT INTO `sys_role_menu` VALUES (2, 2141);
INSERT INTO `sys_role_menu` VALUES (2, 2142);
-- role_id=2 不含 2105/2106/2150（全局看板与导出，仅超级管理员 role_id=1 全量绑定）
-- role_id=3 学生：仅通知公告（业务走小程序）
INSERT INTO `sys_role_menu` VALUES (3, 1);
INSERT INTO `sys_role_menu` VALUES (3, 107);
INSERT INTO `sys_role_menu` VALUES (3, 1035);

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
  `user_id` bigint NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `dept_id` bigint NULL DEFAULT NULL COMMENT '部门ID',
  `user_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '用户账号',
  `nick_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '用户昵称',
  `user_type` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '00' COMMENT '用户类型（00系统用户）',
  `email` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '用户邮箱',
  `phonenumber` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '手机号码',
  `sex` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '0' COMMENT '用户性别（0男 1女 2未知）',
  `avatar` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '头像地址',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '密码',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '0' COMMENT '账号状态（0正常 1停用）',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `login_ip` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '最后登录IP',
  `login_date` datetime NULL DEFAULT NULL COMMENT '最后登录时间',
  `pwd_update_date` datetime NULL DEFAULT NULL COMMENT '密码最后更新时间',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 106 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '用户信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, 100, 'admin', '肥猫BOY', '00', 'FMBOY520@qq.com', '13866666666', '0', '/profile/avatar/2025/11/23/da51124ff24d468ebec7b77f67d5a4a0.jpg', '$2a$10$2xMHgxyR7/VIUytzAHTypeEjFmY9aSl.b92FU1kpfshncmWh4/ynK', '0', '0', '127.0.0.1', '2025-11-25 21:35:32', '2025-11-25 20:33:20', 'admin', '2025-10-29 15:39:48', '', '2025-11-25 20:33:20', '管理员');
INSERT INTO `sys_user` VALUES (2, 200, 'room', '自习室管理员', '00', 'room@qq.com', '15988888888', '0', '/profile/avatar/2025/11/25/73a3da58ac5040688f849d05822cc01f.jpg', '$2a$10$kO2EdLYmDnb7LTAWIuRjfO0iHYPqUeL2kF2R9ZZPshgVQvvX8AAiG', '0', '0', '127.0.0.1', '2025-11-25 21:04:40', '2025-11-25 20:16:32', 'admin', '2025-10-29 17:14:11', 'admin', '2025-11-25 20:16:32', NULL);
INSERT INTO `sys_user` VALUES (101, 201, '234722015', '景晓钢', '00', 'fmboy520@qq.com', '13966666666', '0', '/profile/avatar/2025/11/23/91cb56d20d074a6b956d7e11b31ff1bb.jpg', '$2a$10$w13cVnX/8vu10VyuKYlU6.bARqWVPW3Pva1M9elzoOZgIms/TWcFm', '0', '0', '127.0.0.1', '2025-11-25 22:05:24', '2025-11-03 16:52:02', 'admin', '2025-10-29 20:59:50', 'admin', '2025-11-25 19:49:49', NULL);
INSERT INTO `sys_user` VALUES (102, 201, '234722014', '金事成', '00', '666@qq.com', '15599999999', '0', '/profile/avatar/2025/11/25/3339e55dbd4147e3b3716ee0f6473cf3.jpg', '$2a$10$kFpbyW2axGY7Yuv8D0yvAusTCw3d9JLH71EMap774kYPY7g34HMTC', '0', '0', '127.0.0.1', '2025-11-25 22:04:58', NULL, 'admin', '2025-10-29 21:00:05', 'admin', '2025-11-25 21:41:22', NULL);
INSERT INTO `sys_user` VALUES (103, 201, '234722010', '黄泽钰', '00', '', '', '0', '', '$2a$10$ax8RSlYAylth7JAvFAA1xeUlx9/RSrK5cfkg4yrvszNUUoZATLi4i', '0', '0', '127.0.0.1', '2025-11-22 17:35:57', NULL, 'admin', '2025-10-29 21:00:16', 'admin', '2025-11-25 19:51:05', NULL);
INSERT INTO `sys_user` VALUES (104, 201, '234722024', '袁树强', '00', '', '', '0', '', '$2a$10$atkxrJTh1uq8GtpsE1D9MO935Ee0OBd68iiJJ7YRZpkiLTHzWNfiW', '0', '0', '127.0.0.1', '2025-11-07 17:52:09', NULL, 'admin', '2025-10-29 21:00:28', 'admin', '2025-11-25 19:51:31', NULL);
INSERT INTO `sys_user` VALUES (105, 201, '234724001', '陈帅', '00', '', '', '0', '', '$2a$10$710LcUrPZ6/gylCOhRt5CuUx13Wj0N/7G1CfAMFGsPuKG4lrVSFci', '0', '0', '', NULL, NULL, 'admin', '2025-10-29 21:00:45', 'admin', '2025-11-25 19:51:40', NULL);

-- ----------------------------
-- Table structure for sys_user_post
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_post`;
CREATE TABLE `sys_user_post`  (
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `post_id` bigint NOT NULL COMMENT '岗位ID',
  PRIMARY KEY (`user_id`, `post_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '用户与岗位关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user_post
-- ----------------------------
INSERT INTO `sys_user_post` VALUES (1, 1);

-- ----------------------------
-- Table structure for sys_user_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role`  (
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`user_id`, `role_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '用户和角色关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user_role
-- ----------------------------
INSERT INTO `sys_user_role` VALUES (1, 1);
INSERT INTO `sys_user_role` VALUES (2, 2);
INSERT INTO `sys_user_role` VALUES (100, 100);
INSERT INTO `sys_user_role` VALUES (101, 3);
INSERT INTO `sys_user_role` VALUES (102, 3);
INSERT INTO `sys_user_role` VALUES (103, 3);
INSERT INTO `sys_user_role` VALUES (104, 3);
INSERT INTO `sys_user_role` VALUES (105, 3);


-- ----------------------------
-- 超级管理员角色绑定全部菜单（menu_id 与上文 sys_menu 一致）
-- ----------------------------
DELETE FROM `sys_role_menu` WHERE `role_id` = 1;
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) SELECT 1, `menu_id` FROM `sys_menu`;

SET FOREIGN_KEY_CHECKS = 1;
