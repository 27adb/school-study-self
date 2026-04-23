package com.room.reservation.service.impl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.room.reservation.mapper.RoomMapper;
import com.room.reservation.domain.Room;
import com.room.reservation.service.IRoomService;

/**
 * 自习室Service业务层处理
 *
 * @author FMBOY
 * @date 2025-10-31
 */
@Service
public class RoomServiceImpl implements IRoomService {
    @Autowired
    private RoomMapper roomMapper;

    /**
     * 查询自习室
     *
     * @param id 自习室主键
     * @return 自习室
     */
    @Override
    public Room selectRoomById(Integer id) {
        Room r = roomMapper.selectRoomById(id);
        if (r != null)
        {
            r.setUsingCount(roomMapper.selectUsingCountForRoom(id));
        }
        return r;
    }

    /**
     * 查询自习室列表
     *
     * @param room 自习室
     * @return 自习室
     */
    @Override
    public List<Room> selectRoomList(Room room) {
        List<Room> list = roomMapper.selectRoomList(room);
        List<Map<String, Object>> cntRows = roomMapper.selectUsingCountByRoom();
        Map<Integer, Integer> cntMap = new HashMap<>();
        for (Map<String, Object> row : cntRows)
        {
            if (row.get("roomId") == null || row.get("cnt") == null)
            {
                continue;
            }
            cntMap.put(((Number) row.get("roomId")).intValue(), ((Number) row.get("cnt")).intValue());
        }
        for (Room r : list)
        {
            r.setUsingCount(cntMap.getOrDefault(r.getId(), 0));
        }
        return list;
    }

    /**
     * 新增自习室
     *
     * @param room 自习室
     * @return 结果
     */
    @Override
    public int insertRoom(Room room) {
        return roomMapper.insertRoom(room);
    }

    /**
     * 修改自习室
     *
     * @param room 自习室
     * @return 结果
     */
    @Override
    public int updateRoom(Room room) {
        return roomMapper.updateRoom(room);
    }

    /**
     * 批量删除自习室
     *
     * @param ids 需要删除的自习室主键
     * @return 结果
     */
    @Override
    public int deleteRoomByIds(Integer[] ids) {
        return roomMapper.deleteRoomByIds(ids);
    }

    /**
     * 删除自习室信息
     *
     * @param id 自习室主键
     * @return 结果
     */
    @Override
    public int deleteRoomById(Integer id) {
        return roomMapper.deleteRoomById(id);
    }
}
