package com.room.reservation.controller;

import java.util.List;
import javax.servlet.http.HttpServletResponse;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.room.common.annotation.Log;
import com.room.common.core.controller.BaseController;
import com.room.common.core.domain.AjaxResult;
import com.room.common.enums.BusinessType;
import com.room.reservation.domain.RoomSeat;
import com.room.reservation.mapper.BusinessAuditMapper;
import com.room.reservation.service.IRoomSeatService;
import com.room.common.utils.poi.ExcelUtil;
import com.room.common.core.page.TableDataInfo;

/**
 * 自习室座位Controller
 *
 * @author FMBOY
 * @date 2025-10-31
 */
@RestController
@RequestMapping("/reservation/seat")
public class RoomSeatController extends BaseController {
    @Autowired
    private IRoomSeatService roomSeatService;

    @Autowired
    private BusinessAuditMapper businessAuditMapper;

    /**
     * 查询自习室座位列表（学生端小程序同用，仅需登录）
     */
    @PreAuthorize("isAuthenticated()")
    @GetMapping("/list")
    public TableDataInfo list(RoomSeat roomSeat) {
        startPage();
        List<RoomSeat> list = roomSeatService.selectRoomSeatList(roomSeat);
        return getDataTable(list);
    }

    /**
     * 导出自习室座位列表
     */
    @PreAuthorize("@ss.hasPermi('reservation:seat:export')")
    @Log(title = "自习室座位", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, RoomSeat roomSeat) {
        List<RoomSeat> list = roomSeatService.selectRoomSeatList(roomSeat);
        ExcelUtil<RoomSeat> util = new ExcelUtil<RoomSeat>(RoomSeat.class);
        util.exportExcel(response, list, "自习室座位数据");
    }

    /**
     * 获取自习室座位详细信息（学生端小程序同用，仅需登录）
     */
    @PreAuthorize("isAuthenticated()")
    @GetMapping(value = "/{id}")
    public AjaxResult getInfo(@PathVariable("id") Integer id) {
        return success(roomSeatService.selectRoomSeatById(id));
    }

    /**
     * 新增自习室座位
     */
    @PreAuthorize("@ss.hasPermi('reservation:seat:add')")
    @Log(title = "自习室座位", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody RoomSeat roomSeat) {
        return toAjax(roomSeatService.insertRoomSeat(roomSeat));
    }

    /**
     * 修改自习室座位
     */
    @PreAuthorize("@ss.hasPermi('reservation:seat:edit')")
    @Log(title = "自习室座位", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody RoomSeat roomSeat) {
        RoomSeat old = roomSeat.getId() != null ? roomSeatService.selectRoomSeatById(roomSeat.getId()) : null;
        int n = roomSeatService.updateRoomSeat(roomSeat);
        if (n > 0 && roomSeat.getId() != null) {
            String detail = "座位id=" + roomSeat.getId() + " 状态 "
                    + (old != null && old.getStatus() != null ? old.getStatus() : "-") + "→"
                    + (roomSeat.getStatus() != null ? roomSeat.getStatus() : "-");
            businessAuditMapper.insertAudit(null, "座位状态调整", "SEAT", Long.valueOf(roomSeat.getId()), detail);
        }
        return toAjax(n);
    }

    /**
     * 删除自习室座位
     */
    @PreAuthorize("@ss.hasPermi('reservation:seat:remove')")
    @Log(title = "自习室座位", businessType = BusinessType.DELETE)
    @DeleteMapping("/{ids}")
    public AjaxResult remove(@PathVariable Integer[] ids) {
        return toAjax(roomSeatService.deleteRoomSeatByIds(ids));
    }
}
