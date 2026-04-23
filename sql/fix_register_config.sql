-- 开启系统注册功能
-- 执行此 SQL 后需要重启后端服务或清除缓存

-- 方法 1：如果配置已存在，更新配置
UPDATE sys_config 
SET config_value = 'true', 
    update_time = NOW() 
WHERE config_key = 'sys.account.registerUser';

-- 方法 2：如果配置不存在，插入配置
INSERT INTO sys_config (config_name, config_key, config_value, config_type, create_by, create_time) 
VALUES (
    '账号注册开关', 
    'sys.account.registerUser', 
    'true', 
    'Y', 
    'admin', 
    NOW()
)
ON DUPLICATE KEY UPDATE 
    config_value = 'true', 
    update_time = NOW();

-- 验证修改结果
SELECT config_name, config_key, config_value 
FROM sys_config 
WHERE config_key = 'sys.account.registerUser';
