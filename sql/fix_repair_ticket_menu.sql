-- =============================================================================
-- 报修工单管理：新增菜单权限
-- 说明：
--   1) 添加报修工单的新增、删除按钮权限
--   2) 绑定到角色 ID=2（自习室管理员）
-- =============================================================================
SET NAMES utf8mb4;

-- ----- 1) 按钮：工单新增（thesis:repair:add），menu_id=2132 -----
INSERT INTO sys_menu (
  menu_id, menu_name, parent_id, order_num, path, component, query, route_name,
  is_frame, is_cache, menu_type, visible, status, perms, icon,
  create_by, create_time, update_by, update_time, remark
)
SELECT
  2132, '工单新增', 2103, 3, '#', '', NULL, '',
  1, 0, 'F', '0', '0', 'thesis:repair:add', '#',
  'admin', NOW(), '', NULL, ''
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_id = 2132);

-- ----- 2) 按钮：工单删除（thesis:repair:remove），menu_id=2133 -----
INSERT INTO sys_menu (
  menu_id, menu_name, parent_id, order_num, path, component, query, route_name,
  is_frame, is_cache, menu_type, visible, status, perms, icon,
  create_by, create_time, update_by, update_time, remark
)
SELECT
  2133, '工单删除', 2103, 4, '#', '', NULL, '',
  1, 0, 'F', '0', '0', 'thesis:repair:remove', '#',
  'admin', NOW(), '', NULL, ''
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_id = 2133);

-- ----- 3) 绑定角色菜单权限（role_id=2 为自习室管理员）-----
INSERT IGNORE INTO sys_role_menu (role_id, menu_id) VALUES (2, 2132);
INSERT IGNORE INTO sys_role_menu (role_id, menu_id) VALUES (2, 2133);

-- ----- 4) 超级管理员自动拥有所有权限（可选，若环境支持）-----
-- INSERT IGNORE INTO sys_role_menu (role_id, menu_id) SELECT 1, menu_id FROM sys_menu WHERE menu_id IN (2132, 2133);
