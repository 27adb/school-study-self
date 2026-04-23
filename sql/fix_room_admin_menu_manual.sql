-- =============================================================================
-- 自习室管理员：菜单 + 角色绑定（手动执行，避免「加不进去」）
-- 说明：
--   1) 使用显式列名，兼容若依 sys_menu 20 列结构（含 route_name）
--   2) 菜单用「不存在才插入」；角色菜单用 INSERT IGNORE 防重复
--   3) role_id=2 一般为「自习室管理员」，若你环境不同请改数字
-- =============================================================================
SET NAMES utf8mb4;

-- ----- 1) 按钮：保洁排班更新（thesis:cleaning:edit），menu_id=2142 -----
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

-- ----- 2) 反馈 / 勋章（若未导入 thesis_features_complete.sql 时执行）-----
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

-- ----- 3) 自习室管理员 role_id=2：绑定需要的菜单（重复则忽略）-----
INSERT IGNORE INTO sys_role_menu (role_id, menu_id) VALUES
(2, 2142),
(2, 2160), (2, 2161),
(2, 2170), (2, 2171), (2, 2172), (2, 2173), (2, 2174);

-- 执行后：让该角色用户重新登录，或在「角色管理」里随便保存一次以刷新缓存。
