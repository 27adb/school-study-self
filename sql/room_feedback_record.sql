CREATE TABLE IF NOT EXISTS room_feedback_record (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  user_id BIGINT NOT NULL COMMENT '用户ID',
  feedback_type VARCHAR(32) NOT NULL COMMENT '反馈类型',
  content VARCHAR(1000) NOT NULL COMMENT '反馈内容',
  status VARCHAR(32) NOT NULL DEFAULT '待处理' COMMENT '处理状态',
  handle_remark VARCHAR(1000) DEFAULT NULL COMMENT '处理备注',
  create_by VARCHAR(64) DEFAULT '' COMMENT '创建者',
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  update_by VARCHAR(64) DEFAULT '' COMMENT '更新者',
  update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  remark VARCHAR(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (id),
  KEY idx_feedback_user_id (user_id),
  KEY idx_feedback_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='反馈申诉记录表';

