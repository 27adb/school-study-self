-- 自习室签到定位配置字段升级
-- 执行环境：MySQL 8.x
-- 作用：为 room 表补充签到定位中心和签到半径配置

ALTER TABLE room
    ADD COLUMN latitude DECIMAL(10, 7) NULL COMMENT '签到中心纬度' AFTER seat_rule_note,
    ADD COLUMN longitude DECIMAL(10, 7) NULL COMMENT '签到中心经度' AFTER latitude,
    ADD COLUMN sign_radius_meter INT NULL DEFAULT 200 COMMENT '签到半径(米)' AFTER longitude;

