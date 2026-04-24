package com.room.reservation.mapper;

import java.util.Date;
import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.room.reservation.domain.RoomReservation;

/**
 * 自习室预约管理Mapper接口
 * 
 * @author FMBOY
 * @date 2025-11-16
 */
public interface RoomReservationMapper 
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
     * 删除自习室预约管理
     * 
     * @param id 自习室预约管理主键
     * @return 结果
     */
    public int deleteRoomReservationById(Long id);

    /**
     * 批量删除自习室预约管理
     * 
     * @param ids 需要删除的数据主键集合
     * @return 结果
     */
    public int deleteRoomReservationByIds(Long[] ids);

    /**
     * 预约已开始超过 minutes 分钟仍已预约且未签到的订单（用于自动释放）
     *
     * @param minutes 分钟数
     * @return 订单列表
     */
    public List<RoomReservation> selectNoSignInOverdue(int minutes);

    /**
     * 预约结束超过 minutes 分钟仍未签退的订单
     *
     * @param minutes 分钟数
     * @return 订单列表
     */
    public List<RoomReservation> selectSignOutOverdue(int minutes);

    /**
     * 座位在时段内是否与有效预约重叠（排除指定订单）
     */
    public int countSeatOverlap(@Param("seatId") Long seatId, @Param("start") Date start,
            @Param("end") Date end, @Param("excludeId") Long excludeId);

    /**
     * 用户在同窗时段是否已有有效预约
     */
    public int countUserOverlap(@Param("userId") Long userId, @Param("start") Date start,
            @Param("end") Date end, @Param("excludeId") Long excludeId);

    /** 即将开始、尚未提醒的预约 */
    public List<RoomReservation> selectNeedingReminders(@Param("minutes") int minutes);

    /** 拼座组内有效预约占用的座位（用于相邻校验） */
    List<Long> selectSeatIdsByCarpoolGroup(@Param("groupId") Long groupId);

    /** 拼座组内有效预约（含时段，用于加入时段对齐） */
    List<RoomReservation> selectActiveByCarpoolGroup(@Param("groupId") Long groupId);
}
