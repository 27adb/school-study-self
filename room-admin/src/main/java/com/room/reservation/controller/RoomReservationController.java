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
import java.util.Objects;
import com.room.common.utils.SecurityUtils;
import com.room.common.annotation.Log;
import com.room.common.core.controller.BaseController;
import com.room.common.core.domain.AjaxResult;
import com.room.common.enums.BusinessType;
import com.room.reservation.domain.RoomReservation;
import com.room.reservation.mapper.BusinessAuditMapper;
import com.room.reservation.service.IRoomReservationService;
import com.room.common.utils.poi.ExcelUtil;
import com.room.common.core.page.TableDataInfo;

/**
 * 自习室预约管理Controller
 * 
 * @author FMBOY
 * @date 2025-11-16
 */
@RestController
@RequestMapping("/reservation/reservation")
public class RoomReservationController extends BaseController
{
    @Autowired
    private IRoomReservationService roomReservationService;

    @Autowired
    private BusinessAuditMapper businessAuditMapper;

    /**
     * 查询自习室预约管理列表（学生端小程序同用，仅需登录）
     */
    @PreAuthorize("isAuthenticated()")
    @GetMapping("/list")
    public TableDataInfo list(RoomReservation roomReservation)
    {
        if (!SecurityUtils.hasPermi("reservation:reservation:list"))
        {
            roomReservation.setUserId(getUserId());
        }
        startPage();
        List<RoomReservation> list = roomReservationService.selectRoomReservationList(roomReservation);
        return getDataTable(list);
    }

    /**
     * 导出自习室预约管理列表
     */
    @PreAuthorize("@ss.hasPermi('reservation:reservation:export')")
    @Log(title = "自习室预约管理", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, RoomReservation roomReservation)
    {
        List<RoomReservation> list = roomReservationService.selectRoomReservationList(roomReservation);
        ExcelUtil<RoomReservation> util = new ExcelUtil<RoomReservation>(RoomReservation.class);
        util.exportExcel(response, list, "自习室预约管理数据");
    }

    /**
     * 获取自习室预约管理详细信息（学生端小程序同用，仅需登录）
     */
    @PreAuthorize("isAuthenticated()")
    @GetMapping(value = "/{id}")
    public AjaxResult getInfo(@PathVariable("id") Long id)
    {
        RoomReservation row = roomReservationService.selectRoomReservationById(id);
        if (row == null)
        {
            return error("预约不存在");
        }
        if (!SecurityUtils.hasPermi("reservation:reservation:query") && !row.getUserId().equals(getUserId()))
        {
            return error("无权查看该预约");
        }
        return success(row);
    }

    /**
     * 新增自习室预约管理
     */
    @PreAuthorize("@ss.hasPermi('reservation:reservation:add')")
    @Log(title = "自习室预约管理", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody RoomReservation roomReservation)
    {
        return toAjax(roomReservationService.insertRoomReservation(roomReservation));
    }

    /**
     * 修改自习室预约管理（管理员需 reservation:edit；无该权限的登录用户仅允许将本人预约改为「取消预约」）
     */
    @PreAuthorize("isAuthenticated()")
    @Log(title = "自习室预约管理", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody RoomReservation roomReservation)
    {
        if (!SecurityUtils.hasPermi("reservation:reservation:edit"))
        {
            if (roomReservation.getId() == null)
            {
                return error("参数错误");
            }
            RoomReservation exist = roomReservationService.selectRoomReservationById(roomReservation.getId());
            if (exist == null || !exist.getUserId().equals(getUserId()))
            {
                return error("无权操作该预约");
            }
            if (!"取消预约".equals(roomReservation.getReservationStatus()))
            {
                return error("仅支持取消预约");
            }
            RoomReservation cancelOnly = new RoomReservation();
            cancelOnly.setId(roomReservation.getId());
            cancelOnly.setReservationStatus("取消预约");
            roomReservation = cancelOnly;
        }
        RoomReservation old = null;
        if (roomReservation.getId() != null)
        {
            old = roomReservationService.selectRoomReservationById(roomReservation.getId());
        }
        int n = roomReservationService.updateRoomReservation(roomReservation);
        if (n > 0 && old != null) {
            StringBuilder d = new StringBuilder();
            d.append("预约单").append(roomReservation.getId());
            if (!Objects.equals(old.getReservationStatus(), roomReservation.getReservationStatus())
                    && roomReservation.getReservationStatus() != null)
            {
                d.append(" 预约状态:").append(String.valueOf(old.getReservationStatus())).append("→")
                        .append(roomReservation.getReservationStatus());
            }
            if (!Objects.equals(old.getAuditStatus(), roomReservation.getAuditStatus())
                    && roomReservation.getAuditStatus() != null)
            {
                d.append(" 审核:").append(String.valueOf(old.getAuditStatus())).append("→")
                        .append(roomReservation.getAuditStatus());
            }
            businessAuditMapper.insertAudit(null, "预约管理", "RESERVATION", roomReservation.getId(), d.toString());
        }
        return toAjax(n);
    }

    /**
     * 删除自习室预约管理
     */
    @PreAuthorize("@ss.hasPermi('reservation:reservation:remove')")
    @Log(title = "自习室预约管理", businessType = BusinessType.DELETE)
	@DeleteMapping("/{ids}")
    public AjaxResult remove(@PathVariable Long[] ids)
    {
        return toAjax(roomReservationService.deleteRoomReservationByIds(ids));
    }

    /**
     * 管理员审核预约订单（考试周等特殊时段）
     */
    @PreAuthorize("@ss.hasPermi('reservation:reservation:audit')")
    @Log(title = "自习室预约审核", businessType = BusinessType.UPDATE)
    @PutMapping("/audit")
    public AjaxResult audit(@RequestBody RoomReservation body)
    {
        if (body.getId() == null || body.getAuditStatus() == null)
        {
            return error("参数错误：需要 id 与 auditStatus");
        }
        return toAjax(roomReservationService.auditReservation(body.getId(), body.getAuditStatus()));
    }
}
