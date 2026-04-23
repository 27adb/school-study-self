package com.room.reservation.mapper;

import java.util.List;
import java.util.Map;

import com.room.reservation.domain.Room;

/**
 * 自习室Mapper接口
 *
 * @author FMBOY
 * @date 2025-10-31
 */
public interface RoomMapper {
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
     * 删除自习室
     *
     * @param id 自习室主键
     * @return 结果
     */
    public int deleteRoomById(Integer id);

    /**
     * 批量删除自习室
     *
     * @param ids 需要删除的数据主键集合
     * @return 结果
     */
    public int deleteRoomByIds(Integer[] ids);

    /**
     * 统计各自习室当前有效占用（已预约+使用中，含待审核占座）
     *
     * @return 每行含 roomId、cnt
     */
    public List<Map<String, Object>> selectUsingCountByRoom();

    /** 单来自习室当前在馆/有效占用人数 */
    public int selectUsingCountForRoom(Integer roomId);
}
