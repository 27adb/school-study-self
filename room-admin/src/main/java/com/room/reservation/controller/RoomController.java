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
import com.room.reservation.domain.Room;
import com.room.reservation.service.IRoomService;
import com.room.common.utils.poi.ExcelUtil;
import com.room.common.core.page.TableDataInfo;

/**
 * 自习室Controller
 *
 * @author FMBOY
 * @date 2025-10-31
 */
@RestController
@RequestMapping("/reservation/room")
public class RoomController extends BaseController {
    @Autowired
    private IRoomService roomService;

    /**
     * 查询自习室列表（学生端小程序同用，仅需登录）
     */
    @PreAuthorize("isAuthenticated()")
    @GetMapping("/list")
    public TableDataInfo list(Room room) {
        startPage();
        List<Room> list = roomService.selectRoomList(room);
        return getDataTable(list);
    }

    /**
     * 导出自习室列表
     */
    @PreAuthorize("@ss.hasPermi('reservation:room:export')")
    @Log(title = "自习室", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, Room room) {
        List<Room> list = roomService.selectRoomList(room);
        ExcelUtil<Room> util = new ExcelUtil<Room>(Room.class);
        util.exportExcel(response, list, "自习室数据");
    }

    /**
     * 获取自习室详细信息（学生端小程序同用，仅需登录）
     */
    @PreAuthorize("isAuthenticated()")
    @GetMapping(value = "/{id}")
    public AjaxResult getInfo(@PathVariable("id") Integer id) {
        return success(roomService.selectRoomById(id));
    }

    /**
     * 新增自习室
     */
    @PreAuthorize("@ss.hasPermi('reservation:room:add')")
    @Log(title = "自习室", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody Room room) {
        return toAjax(roomService.insertRoom(room));
    }

    /**
     * 修改自习室
     */
    @PreAuthorize("@ss.hasPermi('reservation:room:edit')")
    @Log(title = "自习室", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody Room room) {
        return toAjax(roomService.updateRoom(room));
    }

    /**
     * 删除自习室
     */
    @PreAuthorize("@ss.hasPermi('reservation:room:remove')")
    @Log(title = "自习室", businessType = BusinessType.DELETE)
    @DeleteMapping("/{ids}")
    public AjaxResult remove(@PathVariable Integer[] ids) {
        return toAjax(roomService.deleteRoomByIds(ids));
    }
}
