-- =============================================================================
-- 自习室管理员「论文扩展 / 新增功能」一键 SQL（可重复执行，不破坏已有数据）
-- 前置：已存在基础库（含 sys_menu 中 2100～2150 自习室运营中心、预约等）。
--       若全新库，请先导入 full_database.sql 或 study_room + upgrade 脚本。
-- 说明：role_id=2 默认为「自习室管理员」，若不一致请全文替换 (2, 为实际角色ID。
-- 执行后：该角色用户需重新登录，或在「角色管理」保存一次以刷新权限缓存。
-- =============================================================================
SET NAMES utf8mb4;

-- ---------------------------------------------------------------------------
-- 一、系统参数（论文扩展：违规拉黑、勋章优先、校园注册、高峰预警）
-- ---------------------------------------------------------------------------
INSERT INTO sys_config (config_name, config_key, config_value, config_type, create_by, create_time, remark)
SELECT '违规达阈值自动拉黑', 'violation.auto.blacklist.enabled', 'false', 'Y', 'admin', NOW(), 'true=开启；达到 violation.count.threshold 次则写入黑名单'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_config WHERE config_key = 'violation.auto.blacklist.enabled');

INSERT INTO sys_config (config_name, config_key, config_value, config_type, create_by, create_time, remark)
SELECT '违规累计次数阈值', 'violation.count.threshold', '3', 'Y', 'admin', NOW(), '统计 violation.lookback.days 天内'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_config WHERE config_key = 'violation.count.threshold');

INSERT INTO sys_config (config_name, config_key, config_value, config_type, create_by, create_time, remark)
SELECT '违规统计回溯天数', 'violation.lookback.days', '90', 'Y', 'admin', NOW(), NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_config WHERE config_key = 'violation.lookback.days');

INSERT INTO sys_config (config_name, config_key, config_value, config_type, create_by, create_time, remark)
SELECT '勋章兑换豁免黑名单', 'medal.redeem.bypassBlacklist', 'true', 'Y', 'admin', NOW(), 'true=已兑换勋章可豁免预约黑名单（优先预约权）'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_config WHERE config_key = 'medal.redeem.bypassBlacklist');

INSERT INTO sys_config (config_name, config_key, config_value, config_type, create_by, create_time, remark)
SELECT '校园短信注册默认角色', 'campus.register.roleId', '2', 'Y', 'admin', NOW(), '与 sys_role 中学生/自习室管理员等角色 ID 一致'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_config WHERE config_key = 'campus.register.roleId');

INSERT INTO sys_config (config_name, config_key, config_value, config_type, create_by, create_time, remark)
SELECT '高峰预警预约率%', 'reservation.alert.usagePercent', '70', 'Y', 'admin', NOW(), '预约率达到该百分比时生成高峰预警'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_config WHERE config_key = 'reservation.alert.usagePercent');

-- ---------------------------------------------------------------------------
-- 二、菜单（显式列名，兼容若依 sys_menu 含 route_name）
-- ---------------------------------------------------------------------------
-- 2.1 保洁排班：排班更新按钮 thesis:cleaning:edit
INSERT INTO sys_menu (
  menu_id, menu_name, parent_id, order_num, path, component, query, route_name,
  is_frame, is_cache, menu_type, visible, status, perms, icon,
  create_by, create_time, update_by, update_time, remark
)
SELECT
  2142, '排班更新', 2104, 3, '#', '', NULL, '',
  1, 0, 'F', '0', '0', 'thesis:cleaning:edit', '#',
  'admin', NOW(), '', NULL, ''
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_id = 2142);

-- 2.2 反馈与申诉（PC 运营）
INSERT INTO sys_menu (
  menu_id, menu_name, parent_id, order_num, path, component, query, route_name,
  is_frame, is_cache, menu_type, visible, status, perms, icon,
  create_by, create_time, update_by, update_time, remark
)
SELECT 2160, '反馈与申诉', 2100, 7, 'thesisFeedback', 'thesis/feedback/index', NULL, '', 1, 0, 'C', '0', '0', 'thesis:feedback:list', 'message', 'admin', NOW(), '', NULL, ''
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_id = 2160);

INSERT INTO sys_menu (
  menu_id, menu_name, parent_id, order_num, path, component, query, route_name,
  is_frame, is_cache, menu_type, visible, status, perms, icon,
  create_by, create_time, update_by, update_time, remark
)
SELECT 2161, '反馈查询', 2160, 1, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'thesis:feedback:query', '#', 'admin', NOW(), '', NULL, ''
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_id = 2161);

-- 2.3 勋章体系配置
INSERT INTO sys_menu (
  menu_id, menu_name, parent_id, order_num, path, component, query, route_name,
  is_frame, is_cache, menu_type, visible, status, perms, icon,
  create_by, create_time, update_by, update_time, remark
)
SELECT 2170, '勋章体系配置', 2100, 8, 'thesisMedal', 'thesis/medal/index', NULL, '', 1, 0, 'C', '0', '0', 'thesis:medal:list', 'star', 'admin', NOW(), '', NULL, ''
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_id = 2170);

INSERT INTO sys_menu (
  menu_id, menu_name, parent_id, order_num, path, component, query, route_name,
  is_frame, is_cache, menu_type, visible, status, perms, icon,
  create_by, create_time, update_by, update_time, remark
)
SELECT 2171, '勋章查询', 2170, 1, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'thesis:medal:query', '#', 'admin', NOW(), '', NULL, ''
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_id = 2171);

INSERT INTO sys_menu (
  menu_id, menu_name, parent_id, order_num, path, component, query, route_name,
  is_frame, is_cache, menu_type, visible, status, perms, icon,
  create_by, create_time, update_by, update_time, remark
)
SELECT 2172, '勋章新增', 2170, 2, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'thesis:medal:add', '#', 'admin', NOW(), '', NULL, ''
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_id = 2172);

INSERT INTO sys_menu (
  menu_id, menu_name, parent_id, order_num, path, component, query, route_name,
  is_frame, is_cache, menu_type, visible, status, perms, icon,
  create_by, create_time, update_by, update_time, remark
)
SELECT 2173, '勋章修改', 2170, 3, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'thesis:medal:edit', '#', 'admin', NOW(), '', NULL, ''
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_id = 2173);

INSERT INTO sys_menu (
  menu_id, menu_name, parent_id, order_num, path, component, query, route_name,
  is_frame, is_cache, menu_type, visible, status, perms, icon,
  create_by, create_time, update_by, update_time, remark
)
SELECT 2174, '勋章删除', 2170, 4, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'thesis:medal:remove', '#', 'admin', NOW(), '', NULL, ''
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_id = 2174);

-- ---------------------------------------------------------------------------
-- 三、角色菜单：自习室管理员 role_id=2 绑定「运营中心」全部论文相关菜单（重复自动忽略）
-- ---------------------------------------------------------------------------
INSERT IGNORE INTO sys_role_menu (role_id, menu_id) VALUES
(2, 2100),
(2, 2101), (2, 2102), (2, 2103), (2, 2104),
(2, 2110), (2, 2111), (2, 2112),
(2, 2120), (2, 2121), (2, 2122),
(2, 2130), (2, 2131),
(2, 2140), (2, 2141), (2, 2142),
(2, 2160), (2, 2161),
(2, 2170), (2, 2171), (2, 2172), (2, 2173), (2, 2174);

-- =============================================================================
-- 结束。若需超级管理员同时拥有上述菜单，可另行执行：
-- INSERT IGNORE INTO sys_role_menu (role_id, menu_id) SELECT 1, menu_id FROM sys_menu WHERE menu_id IN (...);
-- =============================================================================
