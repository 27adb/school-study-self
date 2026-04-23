package com.room.reservation.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.room.reservation.mapper.RoomSeatMapper;
import com.room.reservation.domain.RoomSeat;
import com.room.reservation.service.IRoomSeatService;

/**
 * 自习室座位Service业务层处理
 *
 * @author FMBOY
 * @date 2025-10-31
 */
@Service
public class RoomSeatServiceImpl implements IRoomSeatService {
    @Autowired
    private RoomSeatMapper roomSeatMapper;

    /**
     * 查询自习室座位
     *
     * @param id 自习室座位主键
     * @return 自习室座位
     */
    @Override
    public RoomSeat selectRoomSeatById(Integer id) {
        return roomSeatMapper.selectRoomSeatById(id);
    }

    /**
     * 查询自习室座位列表
     *
     * @param roomSeat 自习室座位
     * @return 自习室座位
     */
    @Override
    public List<RoomSeat> selectRoomSeatList(RoomSeat roomSeat) {
        return roomSeatMapper.selectRoomSeatList(roomSeat);
    }

    /**
     * 新增自习室座位
     *
     * @param roomSeat 自习室座位
     * @return 结果
     */
    @Override
    public int insertRoomSeat(RoomSeat roomSeat) {
        return roomSeatMapper.insertRoomSeat(roomSeat);
    }

    /**
     * 修改自习室座位
     *
     * @param roomSeat 自习室座位
     * @return 结果
     */
    @Override
    public int updateRoomSeat(RoomSeat roomSeat) {
        return roomSeatMapper.updateRoomSeat(roomSeat);
    }

    /**
     * 批量删除自习室座位
     *
     * @param ids 需要删除的自习室座位主键
     * @return 结果
     */
    @Override
    public int deleteRoomSeatByIds(Integer[] ids) {
        return roomSeatMapper.deleteRoomSeatByIds(ids);
    }

    /**
     * 删除自习室座位信息
     *
     * @param id 自习室座位主键
     * @return 结果
     */
    @Override
    public int deleteRoomSeatById(Integer id) {
        return roomSeatMapper.deleteRoomSeatById(id);
    }
}
