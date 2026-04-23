package com.room.reservation.service;

import java.util.List;

import com.room.reservation.domain.Room;

/**
 * 自习室Service接口
 *
 * @author FMBOY
 * @date 2025-10-31
 */
public interface IRoomService {
    /**
     * 查询自习室
     *
     * @param id 自习室主键
     * @return 自习室
     */
    public Room selectRoomById(Integer id);

    /**
     * 查询自习室列表
     *
     * @param room 自习室
     * @return 自习室集合
     */
    public List<Room> selectRoomList(Room room);

    /**
     * 新增自习室
     *
     * @param room 自习室
     * @return 结果
     */
    public int insertRoom(Room room);

    /**
     * 修改自习室
     *
     * @param room 自习室
     * @return 结果
     */
    public int updateRoom(Room room);

    /**
     * 批量删除自习室
     *
     * @param ids 需要删除的自习室主键集合
     * @return 结果
     */
    public int deleteRoomByIds(Integer[] ids);

    /**
     * 删除自习室信息
     *
     * @param id 自习室主键
     * @return 结果
     */
    public int deleteRoomById(Integer id);
}
