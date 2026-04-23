-- 自习室论文扩展：后台菜单增量（Ruoyi sys_menu）
-- 执行前请先：SELECT menu_id FROM sys_menu WHERE menu_id IN (2018,2019,2020);
-- 若主键冲突，请改 menu_id 或跳过已存在的 INSERT。
-- 父菜单 2012 =「自习室预约管理」；若你库中 ID 不同，请将下面 2012 改为实际的预约菜单 menu_id。

-- 预约辅助看板（PC：reservation/seatAssistant）
INSERT INTO `sys_menu` VALUES (2018, '预约辅助看板', 0, 104, 'reservationAssistant', 'reservation/seatAssistant', NULL, '', 1, 0, 'C', '0', '0', 'reservation:assistant:list', 'chart', 'admin', NOW(), 'admin', NOW(), '预约辅助看板菜单');

-- 签到退入口（与预约列表同页，便于管理员核查；学生签到接口在小程序，不依赖此菜单）
INSERT INTO `sys_menu` VALUES (2019, '签到退管理', 0, 105, 'signInOut', 'reservation/reservation/index', NULL, '', 1, 0, 'C', '0', '0', 'reservation:reservation:list', 'clipboard', 'admin', NOW(), 'admin', NOW(), '签到退管理菜单');

-- 预约审核（按钮；perms 须与 RoomReservationController /PUT /audit 的 @PreAuthorize 一致）
INSERT INTO `sys_menu` VALUES (2020, '预约审核', 2012, 6, '', '', NULL, '', 1, 0, 'F', '0', '0', 'reservation:reservation:audit', '#', 'admin', NOW(), '', NULL, '审核通过、审核拒绝');
