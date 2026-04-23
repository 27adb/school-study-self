-- 毕业论文模块增强：订单审核、舒适度、未签到释放规则（执行前请备份数据库）
-- 若列已存在可跳过对应语句

ALTER TABLE room_reservation
    ADD COLUMN audit_status varchar(32) NULL DEFAULT '无需审核' COMMENT '订单审核：无需审核/待审核/已通过/已拒绝' AFTER remark;

ALTER TABLE room
    ADD COLUMN comfort_score decimal(3,1) NULL DEFAULT 4.5 COMMENT '区域舒适度评分(约1-5分)' AFTER status;

-- 规则：是否新订单需要管理员审核（true/false）；已存在同 config_key 时请跳过或先删除
INSERT INTO `sys_config` (`config_name`, `config_key`, `config_value`, `config_type`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`)
VALUES ('预约订单是否需审核', 'reservation.audit.enabled', 'false', 'Y', 'admin', NOW(), NULL, NULL, '考试周等可在后台参数设置改为 true');

INSERT INTO `sys_config` (`config_name`, `config_key`, `config_value`, `config_type`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`)
VALUES ('未签到自动释放分钟数', 'reservation.noSignIn.releaseMinutes', '15', 'Y', 'admin', NOW(), NULL, NULL, '与论文「15分钟内未签到」一致，可改');

UPDATE room SET comfort_score = 4.5 WHERE comfort_score IS NULL;
UPDATE room_reservation SET audit_status = '无需审核' WHERE audit_status IS NULL;
