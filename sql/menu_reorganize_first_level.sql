-- =============================================================================
-- 可选：将「自习室相关」菜单收拢到一个一级目录下（parent_id=0 仅多一个 M 目录）
-- 执行前请备份 sys_menu、sys_role_menu；若 menu_id 与贵库不一致请改 WHERE 列表
-- =============================================================================
-- 说明：若不存在下列 menu_id，请跳过对应 UPDATE。

SET NAMES utf8mb4;

-- 一级目录：自习室预约（新 ID 请避开已占用主键，例如 2999）
INSERT INTO sys_menu (
  menu_id, menu_name, parent_id, order_num, path, component, query, route_name,
  is_frame, is_cache, menu_type, visible, status, perms, icon,
  create_by, create_time, remark
) VALUES (
  2999, '自习室预约', 0, 4, 'studyRoomHub', NULL, '', '', 1, 0, 'M', '0', '0', '', 'education',
  'admin', NOW(), '论文：业务菜单一级归口'
);

-- 原 parent_id=0 的自习室业务菜单挂到 2999 下（按你库中实际 ID 调整）
UPDATE sys_menu SET parent_id = 2999 WHERE menu_id IN (2000, 2006, 2012, 2018, 2019, 2100);

-- 说明：子按钮（如 2001、2013、2020）仍挂在原父菜单下，无需改 parent_id
