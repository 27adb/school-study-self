-- =============================================================================
-- 毕业论文：自习室预约系统「全功能」数据库增量脚本
-- 建议：在 study_room.sql、upgrade_thesis_modules.sql 之后执行；执行前备份
-- =============================================================================

SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS room_campus_code (
  id BIGINT NOT NULL AUTO_INCREMENT,
  campus_account VARCHAR(64) NOT NULL COMMENT '校园账号/学号',
  code VARCHAR(10) NOT NULL,
  expire_time DATETIME NOT NULL,
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_campus (campus_account)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='校园登录短信验证码';

CREATE TABLE IF NOT EXISTS room_user_course (
  id BIGINT NOT NULL AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  week_day TINYINT NOT NULL COMMENT '1-7 周一到周日',
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  course_name VARCHAR(100) DEFAULT NULL,
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_uc_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学生课程时段';

CREATE TABLE IF NOT EXISTS room_blacklist (
  id BIGINT NOT NULL AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  reason VARCHAR(500) DEFAULT NULL,
  until_date DATE NOT NULL COMMENT '解禁日期（含当日仍不可约）',
  status CHAR(1) DEFAULT '0' COMMENT '0封禁 1已解除',
  create_by VARCHAR(64) DEFAULT '',
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  remark VARCHAR(500) DEFAULT NULL,
  PRIMARY KEY (id),
  KEY idx_bl_user (user_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='预约黑名单';

CREATE TABLE IF NOT EXISTS room_violation (
  id BIGINT NOT NULL AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  reservation_id BIGINT DEFAULT NULL,
  violation_type VARCHAR(64) NOT NULL,
  description VARCHAR(2000) DEFAULT NULL,
  evidence_urls VARCHAR(2000) DEFAULT NULL,
  sign_log TEXT,
  create_by VARCHAR(64) DEFAULT '',
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_v_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='违规追溯卡';

CREATE TABLE IF NOT EXISTS room_medal_def (
  code VARCHAR(32) NOT NULL,
  name VARCHAR(64) NOT NULL,
  need_minutes INT NOT NULL,
  perk_desc VARCHAR(200) DEFAULT NULL,
  sort_order INT DEFAULT 0,
  PRIMARY KEY (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='勋章定义';

CREATE TABLE IF NOT EXISTS room_user_medal (
  user_id BIGINT NOT NULL,
  medal_code VARCHAR(32) NOT NULL,
  unlock_time DATETIME NOT NULL,
  redeemed CHAR(1) DEFAULT '0',
  PRIMARY KEY (user_id, medal_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户勋章';

CREATE TABLE IF NOT EXISTS room_user_study_stats (
  user_id BIGINT NOT NULL,
  total_effective_minutes BIGINT NOT NULL DEFAULT 0,
  update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='有效学习时长累计';

CREATE TABLE IF NOT EXISTS room_carpool_group (
  id BIGINT NOT NULL AUTO_INCREMENT,
  room_id INT NOT NULL,
  leader_user_id BIGINT NOT NULL,
  seat_count INT NOT NULL DEFAULT 2,
  share_code VARCHAR(32) NOT NULL,
  status VARCHAR(32) DEFAULT '招募中',
  expire_time DATETIME DEFAULT NULL,
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_share (share_code),
  KEY idx_room (room_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='拼座小组';

CREATE TABLE IF NOT EXISTS room_cleaning_plan (
  id BIGINT NOT NULL AUTO_INCREMENT,
  room_id INT NOT NULL,
  plan_date DATE NOT NULL,
  time_slot VARCHAR(32) DEFAULT NULL,
  cleaner VARCHAR(64) DEFAULT NULL,
  status VARCHAR(32) DEFAULT '待执行',
  reason VARCHAR(500) DEFAULT NULL,
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_cp_room_date (room_id, plan_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='保洁排班';

CREATE TABLE IF NOT EXISTS room_repair_ticket (
  id BIGINT NOT NULL AUTO_INCREMENT,
  room_name VARCHAR(128) NOT NULL COMMENT '自习室名称',
  seat_number VARCHAR(64) DEFAULT NULL COMMENT '座位编号',
  reporter_user_id BIGINT DEFAULT NULL,
  fault_type VARCHAR(64) DEFAULT NULL,
  content VARCHAR(2000) DEFAULT NULL,
  status VARCHAR(32) DEFAULT '待处理',
  assignee VARCHAR(64) DEFAULT NULL,
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_rt_room (room_name),
  KEY idx_rt_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='设备报修工单';

CREATE TABLE IF NOT EXISTS room_app_reminder (
  id BIGINT NOT NULL AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  reservation_id BIGINT NOT NULL,
  title VARCHAR(128) NOT NULL,
  body VARCHAR(500) DEFAULT NULL,
  fire_time DATETIME NOT NULL,
  is_read CHAR(1) DEFAULT '0',
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_ar_user (user_id, is_read)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='预约提醒';

CREATE TABLE IF NOT EXISTS room_usage_alert (
  id BIGINT NOT NULL AUTO_INCREMENT,
  room_id INT NOT NULL,
  alert_date DATE NOT NULL,
  rate_percent DECIMAL(5,2) NOT NULL,
  message VARCHAR(500) DEFAULT NULL,
  is_read CHAR(1) DEFAULT '0',
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_ua_room (room_id, alert_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='使用率预警';

CREATE TABLE IF NOT EXISTS room_business_audit (
  id BIGINT NOT NULL AUTO_INCREMENT,
  user_id BIGINT DEFAULT NULL,
  action_type VARCHAR(64) NOT NULL,
  ref_type VARCHAR(32) DEFAULT NULL,
  ref_id BIGINT DEFAULT NULL,
  detail VARCHAR(2000) DEFAULT NULL,
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_ba_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='业务审计';

-- ----- 扩展列（已存在请忽略 Duplicate column 错误；建议先执行 upgrade_thesis_modules.sql）
ALTER TABLE room ADD COLUMN comfort_score DECIMAL(3,1) NULL DEFAULT 4.5 COMMENT '舒适度';
ALTER TABLE room ADD COLUMN area_zone VARCHAR(32) NULL COMMENT '静音区/研讨区';
ALTER TABLE room ADD COLUMN seat_rule_note VARCHAR(500) NULL COMMENT '拼座与座位类型说明';

ALTER TABLE room_reservation ADD COLUMN audit_status VARCHAR(32) NULL DEFAULT '无需审核';
ALTER TABLE room_reservation ADD COLUMN carpool_group_id BIGINT NULL;
ALTER TABLE room_reservation ADD COLUMN share_code VARCHAR(32) NULL;

ALTER TABLE room_feedback_record ADD COLUMN quiet_score TINYINT NULL AFTER content;
ALTER TABLE room_feedback_record ADD COLUMN lighting_score TINYINT NULL AFTER quiet_score;
ALTER TABLE room_feedback_record ADD COLUMN appeal_evidence VARCHAR(2000) NULL AFTER remark;

-- ----- sys_config（无唯一键时用 NOT EXISTS）
INSERT INTO sys_config (config_name, config_key, config_value, config_type, create_by, create_time, remark)
SELECT '校园短信演示模式', 'campus.sms.mock', 'true', 'Y', 'admin', NOW(), 'true=固定验证码123456' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_config WHERE config_key = 'campus.sms.mock');

INSERT INTO sys_config (config_name, config_key, config_value, config_type, create_by, create_time, remark)
SELECT '预约最短时长(小时)', 'reservation.minHours', '1', 'Y', 'admin', NOW(), NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_config WHERE config_key = 'reservation.minHours');

INSERT INTO sys_config (config_name, config_key, config_value, config_type, create_by, create_time, remark)
SELECT '预约最长时长(小时)', 'reservation.maxHours', '4', 'Y', 'admin', NOW(), NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_config WHERE config_key = 'reservation.maxHours');

INSERT INTO sys_config (config_name, config_key, config_value, config_type, create_by, create_time, remark)
SELECT '黑名单默认天数', 'violation.blacklist.days', '7', 'Y', 'admin', NOW(), NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_config WHERE config_key = 'violation.blacklist.days');

INSERT INTO sys_config (config_name, config_key, config_value, config_type, create_by, create_time, remark)
SELECT '高峰预警预约率%', 'reservation.alert.usagePercent', '70', 'Y', 'admin', NOW(), NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_config WHERE config_key = 'reservation.alert.usagePercent');

INSERT INTO sys_config (config_name, config_key, config_value, config_type, create_by, create_time, remark)
SELECT '舒适度权重-安静', 'comfort.weight.quiet', '0.5', 'Y', 'admin', NOW(), NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_config WHERE config_key = 'comfort.weight.quiet');

INSERT INTO sys_config (config_name, config_key, config_value, config_type, create_by, create_time, remark)
SELECT '舒适度权重-照明', 'comfort.weight.lighting', '0.5', 'Y', 'admin', NOW(), NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_config WHERE config_key = 'comfort.weight.lighting');

INSERT INTO sys_config (config_name, config_key, config_value, config_type, create_by, create_time, remark)
SELECT '预约提醒提前分钟', 'reservation.reminder.minutesBefore', '30', 'Y', 'admin', NOW(), NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_config WHERE config_key = 'reservation.reminder.minutesBefore');

INSERT IGNORE INTO room_medal_def (code, name, need_minutes, perk_desc, sort_order) VALUES
('L1', '入门学霸', 120, '优先预约体验', 1),
('L2', '进阶学霸', 600, '优先预约加权', 2),
('L3', '学霸达人', 2000, '高峰保障', 3);

-- ----- 菜单（menu_id 2100 起；若主键冲突请调整）
INSERT INTO sys_menu VALUES (2100, '自习室运营中心', 0, 106, 'thesisOps', NULL, '', '', 1, 0, 'M', '0', '0', '', 'guide', 'admin', NOW(), '', NULL, '论文扩展运营');
INSERT INTO sys_menu VALUES (2101, '违规追溯卡', 2100, 1, 'violation', 'thesis/violation/index', NULL, '', 1, 0, 'C', '0', '0', 'thesis:violation:list', 'message', 'admin', NOW(), '', NULL, '');
INSERT INTO sys_menu VALUES (2102, '黑名单管理', 2100, 2, 'blacklist', 'thesis/blacklist/index', NULL, '', 1, 0, 'C', '0', '0', 'thesis:blacklist:list', 'lock', 'admin', NOW(), '', NULL, '');
INSERT INTO sys_menu VALUES (2103, '报修工单', 2100, 3, 'repair', 'thesis/repair/index', NULL, '', 1, 0, 'C', '0', '0', 'thesis:repair:list', 'tool', 'admin', NOW(), '', NULL, '');
INSERT INTO sys_menu VALUES (2104, '保洁排班', 2100, 4, 'cleaning', 'thesis/cleaning/index', NULL, '', 1, 0, 'C', '0', '0', 'thesis:cleaning:list', 'date', 'admin', NOW(), '', NULL, '');
INSERT INTO sys_menu VALUES (2105, '全局数据看板', 2100, 5, 'superDash', 'thesis/superDash/index', NULL, '', 1, 0, 'C', '0', '0', 'thesis:dashboard:list', 'chart', 'admin', NOW(), '', NULL, '');
INSERT INTO sys_menu VALUES (2106, '资源优化建议', 2100, 6, 'suggest', 'thesis/suggest/index', NULL, '', 1, 0, 'C', '0', '0', 'thesis:suggest:list', 'education', 'admin', NOW(), '', NULL, '');
INSERT INTO sys_menu VALUES (2110, '违规查询', 2101, 1, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'thesis:violation:query', '#', 'admin', NOW(), '', NULL, '');
INSERT INTO sys_menu VALUES (2111, '违规新增', 2101, 2, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'thesis:violation:add', '#', 'admin', NOW(), '', NULL, '');
INSERT INTO sys_menu VALUES (2112, '违规删除', 2101, 3, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'thesis:violation:remove', '#', 'admin', NOW(), '', NULL, '');
INSERT INTO sys_menu VALUES (2120, '黑名单查询', 2102, 1, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'thesis:blacklist:query', '#', 'admin', NOW(), '', NULL, '');
INSERT INTO sys_menu VALUES (2121, '黑名单新增', 2102, 2, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'thesis:blacklist:add', '#', 'admin', NOW(), '', NULL, '');
INSERT INTO sys_menu VALUES (2122, '黑名单解除', 2102, 3, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'thesis:blacklist:edit', '#', 'admin', NOW(), '', NULL, '');
INSERT INTO sys_menu VALUES (2130, '工单查询', 2103, 1, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'thesis:repair:query', '#', 'admin', NOW(), '', NULL, '');
INSERT INTO sys_menu VALUES (2131, '工单处理', 2103, 2, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'thesis:repair:edit', '#', 'admin', NOW(), '', NULL, '');
INSERT INTO sys_menu VALUES (2140, '排班查询', 2104, 1, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'thesis:cleaning:query', '#', 'admin', NOW(), '', NULL, '');
INSERT INTO sys_menu VALUES (2141, '排班生成', 2104, 2, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'thesis:cleaning:add', '#', 'admin', NOW(), '', NULL, '');
INSERT INTO sys_menu VALUES (2150, '看板导出', 2105, 1, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'thesis:dashboard:export', '#', 'admin', NOW(), '', NULL, '');
