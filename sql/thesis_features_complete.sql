-- 论文扩展：菜单与参数（在 full_database 或已有库上执行；主键冲突请改 ID）
SET NAMES utf8mb4;

INSERT INTO sys_config (config_name, config_key, config_value, config_type, create_by, create_time, remark)
SELECT '违规达阈值自动拉黑', 'violation.auto.blacklist.enabled', 'false', 'Y', 'admin', NOW(), 'true=开启；达到 violation.count.threshold 次则写入黑名单'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_config WHERE config_key = 'violation.auto.blacklist.enabled');

INSERT INTO sys_config (config_name, config_key, config_value, config_type, create_by, create_time, remark)
SELECT '违规累计次数阈值', 'violation.count.threshold', '3', 'Y', 'admin', NOW(), '统计 violation.lookback.days 天内'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_config WHERE config_key = 'violation.count.threshold');

INSERT INTO sys_config (config_name, config_key, config_value, config_type, create_by, create_time, remark)
SELECT '违规统计回溯天数', 'violation.lookback.days', '90', 'Y', 'admin', NOW(), NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_config WHERE config_key = 'violation.lookback.days');

-- 菜单：反馈申诉、勋章配置（挂在 2100 运营中心下）
INSERT INTO sys_menu VALUES (2160, '反馈与申诉', 2100, 7, 'thesisFeedback', 'thesis/feedback/index', NULL, '', 1, 0, 'C', '0', '0', 'thesis:feedback:list', 'message', 'admin', NOW(), '', NULL, '');
INSERT INTO sys_menu VALUES (2161, '反馈查询', 2160, 1, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'thesis:feedback:query', '#', 'admin', NOW(), '', NULL, '');
INSERT INTO sys_menu VALUES (2170, '勋章体系配置', 2100, 8, 'thesisMedal', 'thesis/medal/index', NULL, '', 1, 0, 'C', '0', '0', 'thesis:medal:list', 'star', 'admin', NOW(), '', NULL, '');
INSERT INTO sys_menu VALUES (2171, '勋章查询', 2170, 1, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'thesis:medal:query', '#', 'admin', NOW(), '', NULL, '');
INSERT INTO sys_menu VALUES (2172, '勋章新增', 2170, 2, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'thesis:medal:add', '#', 'admin', NOW(), '', NULL, '');
INSERT INTO sys_menu VALUES (2173, '勋章修改', 2170, 3, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'thesis:medal:edit', '#', 'admin', NOW(), '', NULL, '');
INSERT INTO sys_menu VALUES (2174, '勋章删除', 2170, 4, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'thesis:medal:remove', '#', 'admin', NOW(), '', NULL, '');

-- 自习室管理员角色：追加新菜单（若已存在会重复，可忽略或先删后插）
INSERT IGNORE INTO sys_role_menu (role_id, menu_id) VALUES
(2, 2160), (2, 2161), (2, 2170), (2, 2171), (2, 2172), (2, 2173), (2, 2174);

-- 超级管理员：全量菜单（若你环境用脚本维护 role_id=1）
-- INSERT INTO sys_role_menu (role_id, menu_id) SELECT 1, menu_id FROM sys_menu ON DUPLICATE KEY UPDATE role_id=role_id;

INSERT INTO sys_config (config_name, config_key, config_value, config_type, create_by, create_time, remark)
SELECT '勋章兑换豁免黑名单', 'medal.redeem.bypassBlacklist', 'true', 'Y', 'admin', NOW(), 'true=已兑换勋章用户可豁免预约黑名单（优先预约权）'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_config WHERE config_key = 'medal.redeem.bypassBlacklist');

INSERT INTO sys_config (config_name, config_key, config_value, config_type, create_by, create_time, remark)
SELECT '校园短信注册默认角色', 'campus.register.roleId', '2', 'Y', 'admin', NOW(), '与 sys_role 中学生/普通用户角色 ID 一致'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_config WHERE config_key = 'campus.register.roleId');

-- 自习室管理员：保洁排班指派/执行状态（挂在 2104 下）
INSERT IGNORE INTO sys_menu VALUES (2142, '排班更新', 2104, 3, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'thesis:cleaning:edit', '#', 'admin', NOW(), '', NULL, '');
INSERT IGNORE INTO sys_role_menu (role_id, menu_id) VALUES (2, 2142);
