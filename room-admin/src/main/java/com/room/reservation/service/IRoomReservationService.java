package com.room.reservation.service;

import java.util.List;
import com.room.reservation.domain.RoomReservation;

/**
 * 自习室预约管理Service接口
 * 
 * @author FMBOY
 * @date 2025-11-16
 */
public interface IRoomReservationService 
{
    /**
     * 查询自习室预约管理
     * 
     * @param id 自习室预约管理主键
     * @return 自习室预约管理
     */
    public RoomReservation selectRoomReservationById(Long id);

    /**
     * 查询自习室预约管理列表
     * 
     * @param roomReservation 自习室预约管理
     * @return 自习室预约管理集合
     */
    public List<RoomReservation> selectRoomReservationList(RoomReservation roomReservation);

    /**
     * 新增自习室预约管理
     * 
     * @param roomReservation 自习室预约管理
     * @return 结果
     */
    public int insertRoomReservation(RoomReservation roomReservation);

    /**
     * 修改自习室预约管理
     * 
     * @param roomReservation 自习室预约管理
     * @return 结果
     */
    public int updateRoomReservation(RoomReservation roomReservation);

    /**
     * 批量删除自习室预约管理
     * 
     * @param ids 需要删除的自习室预约管理主键集合
     * @return 结果
     */
    public int deleteRoomReservationByIds(Long[] ids);

    /**
     * 删除自习室预约管理信息
     * 
     * @param id 自习室预约管理主键
     * @return 结果
     */
    public int deleteRoomReservationById(Long id);

    /**
     * 学生端签到（需已预约且审核通过/无需审核）
     */
    public void studentSignIn(Long reservationId, Long userId);

    /**
     * 学生端签退（需使用中）
     */
    public void studentSignOut(Long reservationId, Long userId);

    /**
     * 管理员审核订单（待审核 → 已通过/已拒绝）
     */
    public int auditReservation(Long reservationId, String auditStatus);

    /**
     * 定时：释放超时未签到预约（分钟数来自参数 reservation.noSignIn.releaseMinutes）
     */
    public void releaseNoSignInReservations();

    /**
     * 定时：将超时未签退的订单标记为违约并释放座位
     */
    public void markOvertimeReservations();
}
