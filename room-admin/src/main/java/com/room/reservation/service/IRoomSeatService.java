package com.room.reservation.service;

import java.util.List;

import com.room.reservation.domain.RoomSeat;

/**
 * 自习室座位Service接口
 *
 * @author FMBOY
 * @date 2025-10-31
 */
public interface IRoomSeatService {
    /**
     * 查询自习室座位
     *
     * @param id 自习室座位主键
     * @return 自习室座位
     */
    public RoomSeat selectRoomSeatById(Integer id);

    /**
     * 查询自习室座位列表
     *
     * @param roomSeat 自习室座位
     * @return 自习室座位集合
     */
    public List<RoomSeat> selectRoomSeatList(RoomSeat roomSeat);

    /**
     * 新增自习室座位
     *
     * @param roomSeat 自习室座位
     * @return 结果
     */
    public int insertRoomSeat(RoomSeat roomSeat);

    /**
     * 修改自习室座位
     *
     * @param roomSeat 自习室座位
     * @return 结果
     */
    public int updateRoomSeat(RoomSeat roomSeat);

    /**
     * 批量删除自习室座位
     *
     * @param ids 需要删除的自习室座位主键集合
     * @return 结果
     */
    public int deleteRoomSeatByIds(Integer[] ids);

    /**
     * 删除自习室座位信息
     *
     * @param id 自习室座位主键
     * @return 结果
     */
    public int deleteRoomSeatById(Integer id);
}
