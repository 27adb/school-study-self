-- =============================================================================
-- 修复：报修工单表的字段名称变更
-- 说明：将 room_id 改为 room_name，seat_id 改为 seat_number
--      支持使用自习室名称和座位编号（如 E1）进行报修
-- =============================================================================
SET NAMES utf8mb4;

-- 修改字段名称：room_id -> room_name
ALTER TABLE room_repair_ticket 
CHANGE COLUMN room_id room_name VARCHAR(128) NOT NULL COMMENT '自习室名称';

-- 修改字段名称：seat_id -> seat_number
ALTER TABLE room_repair_ticket 
CHANGE COLUMN seat_id seat_number VARCHAR(64) DEFAULT NULL COMMENT '座位编号';

-- 添加索引优化查询性能
ALTER TABLE room_repair_ticket ADD INDEX idx_room_name (room_name);
ALTER TABLE room_repair_ticket ADD INDEX idx_status (status);
ALTER TABLE room_repair_ticket ADD INDEX idx_create_time (create_time DESC);
