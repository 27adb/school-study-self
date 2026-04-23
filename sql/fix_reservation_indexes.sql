-- =============================================================================
-- 优化：预约表 room_reservation 添加索引，提升定时任务查询性能
-- 说明：未签到释放座位的定时任务每分钟执行一次，需要索引优化
-- =============================================================================
SET NAMES utf8mb4;

-- 添加复合索引：优化未签到查询（reservation_status, sign_in_time, reservation_in_time）
ALTER TABLE room_reservation 
ADD INDEX idx_reservation_status_sign (reservation_status, sign_in_time, reservation_in_time);

-- 添加索引：优化审核状态查询
ALTER TABLE room_reservation 
ADD INDEX idx_audit_status (audit_status);

-- 添加索引：优化用户预约查询
ALTER TABLE room_reservation 
ADD INDEX idx_user_reservation (user_id, reservation_status);

-- 添加索引：优化座位预约查询
ALTER TABLE room_reservation 
ADD INDEX idx_seat_reservation (seat_id, reservation_status);

-- 添加索引：优化拼座组查询
ALTER TABLE room_reservation 
ADD INDEX idx_carpool_group (carpool_group_id);
