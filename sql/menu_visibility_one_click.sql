-- =============================================================================
-- 角色菜单可见性：仅需执行本文件（可重复执行，幂等）
-- 约定：role_id=1 超级管理员；2 自习室管理员；3 学生（与 sys_role 一致）
-- 前置：已存在业务库（含 sys_menu、sys_role_menu、sys_role 等表）
-- 执行后：相关账号请重新登录以刷新侧栏路由
-- =============================================================================
SET NAMES utf8mb4;

-- 1) 自习室管理员：移除超管专属「全局数据看板 / 资源优化建议 / 看板导出」
DELETE FROM sys_role_menu WHERE role_id = 2 AND menu_id IN (2105, 2106, 2150);

-- 2) 补全「排班更新」按钮菜单（若不存在则插入；已存在则忽略）
INSERT IGNORE INTO sys_menu (
  menu_id, menu_name, parent_id, order_num, path, component, `query`, route_name,
  is_frame, is_cache, menu_type, visible, status, perms, icon,
  create_by, create_time, update_by, update_time, remark
) VALUES (
  2142, '排班更新', 2104, 3, '#', '', NULL, '',
  1, 0, 'F', '0', '0', 'thesis:cleaning:edit', '#',
  'admin', NOW(), '', NULL, ''
);

-- 3) 自习室管理员：绑定排班更新权限（重复则忽略）
INSERT IGNORE INTO sys_role_menu (role_id, menu_id) VALUES (2, 2142);

-- 4) 超级管理员：补全「当前库中全部菜单」（新增菜单后执行本脚本即可自动带上）
INSERT IGNORE INTO sys_role_menu (role_id, menu_id) SELECT 1, menu_id FROM sys_menu;

-- 5) 学生：仅保留「系统管理目录 + 通知公告 + 公告查询」三节点（与 PC 端策略一致）
DELETE FROM sys_role_menu WHERE role_id = 3 AND menu_id NOT IN (1, 107, 1035);
INSERT IGNORE INTO sys_role_menu (role_id, menu_id) VALUES (3, 1), (3, 107), (3, 1035);

-- =============================================================================
-- 结束
-- =============================================================================
