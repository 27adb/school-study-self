package com.room.reservation.controller;

import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.room.common.core.controller.BaseController;
import com.room.common.core.domain.AjaxResult;
import com.room.common.exception.ServiceException;
import com.room.common.utils.DateUtils;
import com.room.common.utils.SecurityUtils;
import com.room.common.utils.uuid.IdUtils;
import com.room.reservation.domain.CarpoolGroup;
import com.room.reservation.domain.RepairTicket;
import com.room.reservation.domain.RoomReservation;
import com.room.reservation.domain.RoomSeat;
import com.room.reservation.domain.UserCourseSchedule;
import com.room.reservation.mapper.CarpoolGroupMapper;
import com.room.reservation.mapper.RepairTicketMapper;
import com.room.reservation.mapper.RoomReservationMapper;
import com.room.reservation.service.IRoomSeatService;
import com.room.reservation.mapper.ThesisAppReminderMapper;
import com.room.reservation.mapper.ThesisStudyMapper;
import com.room.reservation.mapper.UserCourseScheduleMapper;
import com.room.reservation.service.IRoomReservationService;

@RestController
@RequestMapping("/student/thesis")
public class ThesisStudentController extends BaseController
{
    @Autowired
    private UserCourseScheduleMapper userCourseScheduleMapper;

    @Autowired
    private ThesisAppReminderMapper thesisAppReminderMapper;

    @Autowired
    private ThesisStudyMapper thesisStudyMapper;

    @Autowired
    private CarpoolGroupMapper carpoolGroupMapper;

    @Autowired
    private RepairTicketMapper repairTicketMapper;

    @Autowired
    private IRoomReservationService roomReservationService;

    @Autowired
    private RoomReservationMapper roomReservationMapper;

    @Autowired
    private IRoomSeatService roomSeatService;

    @PreAuthorize("isAuthenticated()")
    @GetMapping("/courses")
    public AjaxResult listCourses()
    {
        List<UserCourseSchedule> list = userCourseScheduleMapper.selectByUserId(SecurityUtils.getUserId());
        return success(list);
    }

    @PreAuthorize("isAuthenticated()")
    @PostMapping("/courses")
    public AjaxResult addCourse(@RequestBody UserCourseSchedule row)
    {
        row.setUserId(SecurityUtils.getUserId());
        userCourseScheduleMapper.insertUserCourse(row);
        return success();
    }

    @PreAuthorize("isAuthenticated()")
    @DeleteMapping("/courses/{id}")
    public AjaxResult delCourse(@PathVariable Long id)
    {
        userCourseScheduleMapper.deleteUserCourse(id, SecurityUtils.getUserId());
        return success();
    }

    @PreAuthorize("isAuthenticated()")
    @GetMapping("/reminders")
    public AjaxResult reminders()
    {
        return success(thesisAppReminderMapper.selectUnreadByUser(SecurityUtils.getUserId()));
    }

    @PreAuthorize("isAuthenticated()")
    @PostMapping("/reminders/read/{id}")
    public AjaxResult readReminder(@PathVariable Long id)
    {
        thesisAppReminderMapper.markRead(id, SecurityUtils.getUserId());
        return success();
    }

    @PreAuthorize("isAuthenticated()")
    @GetMapping("/medals")
    public AjaxResult medals()
    {
        Long uid = SecurityUtils.getUserId();
        AjaxResult ajax = AjaxResult.success();
        ajax.put("totalMinutes", thesisStudyMapper.selectTotalMinutes(uid));
        ajax.put("definitions", thesisStudyMapper.selectAllMedalDef());
        ajax.put("mine", thesisStudyMapper.selectUserMedals(uid));
        return ajax;
    }

    @PreAuthorize("isAuthenticated()")
    @PostMapping("/medals/redeem/{code}")
    public AjaxResult redeem(@PathVariable String code)
    {
        thesisStudyMapper.redeemMedal(SecurityUtils.getUserId(), code);
        return success();
    }

    @PreAuthorize("isAuthenticated()")
    @PostMapping("/carpool/create")
    public AjaxResult createCarpool(@RequestBody Map<String, Object> body)
    {
        CarpoolGroup g = new CarpoolGroup();
        g.setRoomId(Long.valueOf(body.get("roomId").toString()));
        g.setLeaderUserId(SecurityUtils.getUserId());
        g.setSeatCount(body.get("seatCount") == null ? 2 : Integer.parseInt(body.get("seatCount").toString()));
        g.setShareCode(IdUtils.fastUUID().replace("-", "").substring(0, 8).toUpperCase());
        g.setStatus("招募中");
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.HOUR,24);
        g.setExpireTime(cal.getTime());
        carpoolGroupMapper.insertCarpoolGroup(g);
        AjaxResult ajax = success(g);
        ajax.put("shareCode", g.getShareCode());
        return ajax;
    }

    @PreAuthorize("isAuthenticated()")
    @GetMapping("/carpool/joinInfo/{shareCode}")
    public AjaxResult carpoolInfo(@PathVariable String shareCode)
    {
        return success(carpoolGroupMapper.selectByShareCode(shareCode));
    }

    /**
     * 凭拼座码加入：座位须属该自习室；若组内已有预约则新座位须与任一成员相邻。
     */
    @PreAuthorize("isAuthenticated()")
    @PostMapping("/carpool/join")
    public AjaxResult joinCarpool(@RequestBody Map<String, Object> body)
    {
        String shareCode = body.get("shareCode") == null ? null : body.get("shareCode").toString();
        if (shareCode == null || shareCode.isEmpty())
        {
            throw new ServiceException("请填写拼座码");
        }
        CarpoolGroup g = carpoolGroupMapper.selectByShareCode(shareCode);
        if (g == null)
        {
            throw new ServiceException("拼座码无效");
        }
        if (!"招募中".equals(g.getStatus()))
        {
            throw new ServiceException("该拼座已结束");
        }
        if (g.getExpireTime() != null && g.getExpireTime().before(new Date()))
        {
            throw new ServiceException("拼座已过期");
        }
        Long seatId = Long.valueOf(body.get("seatId").toString());
        RoomSeat newSeat = roomSeatService.selectRoomSeatById(seatId.intValue());
        if (newSeat == null || newSeat.getRoomId() == null || g.getRoomId() == null
                || !newSeat.getRoomId().equals(g.getRoomId().intValue()))
        {
            throw new ServiceException("座位不属于该拼座自习室");
        }
        List<Long> peerSeats = roomReservationMapper.selectSeatIdsByCarpoolGroup(g.getId());
        if (!peerSeats.isEmpty())
        {
            boolean ok = false;
            for (Long sid : peerSeats)
            {
                RoomSeat ps = roomSeatService.selectRoomSeatById(sid.intValue());
                if (adjacentSeat(newSeat, ps))
                {
                    ok = true;
                    break;
                }
            }
            if (!ok)
            {
                throw new ServiceException("请选择与拼座成员相邻的座位");
            }
        }
        Date inTime = DateUtils.parseDate(body.get("reservationInTime"));
        Date outTime = DateUtils.parseDate(body.get("reservationOutTime"));
        if (inTime == null || outTime == null)
        {
            throw new ServiceException("请填写预约开始与结束时间");
        }
        List<RoomReservation> activeInGroup = roomReservationMapper.selectActiveByCarpoolGroup(g.getId());
        for (RoomReservation ex : activeInGroup)
        {
            if (!timeRangesOverlap(inTime, outTime, ex.getReservationInTime(), ex.getReservationOutTime()))
            {
                throw new ServiceException("预约时段需与拼座成员已有预约时段重叠");
            }
        }
        RoomReservation r = new RoomReservation();
        r.setUserId(SecurityUtils.getUserId());
        r.setSeatId(seatId);
        r.setStatus("正常");
        r.setReservationStatus("已预约");
        r.setReservationInTime(inTime);
        r.setReservationOutTime(outTime);
        r.setCarpoolGroupId(g.getId());
        return toAjax(roomReservationService.insertRoomReservation(r));
    }

    private static boolean adjacentSeat(RoomSeat a, RoomSeat b)
    {
        if (a == null || b == null || a.getRowNum() == null || b.getRowNum() == null
                || a.getColNum() == null || b.getColNum() == null)
        {
            return false;
        }
        return a.getRoomId().equals(b.getRoomId())
                && Math.abs(a.getRowNum() - b.getRowNum()) + Math.abs(a.getColNum() - b.getColNum()) == 1;
    }

    private static boolean timeRangesOverlap(Date aStart, Date aEnd, Date bStart, Date bEnd)
    {
        if (aStart == null || aEnd == null || bStart == null || bEnd == null)
        {
            return true;
        }
        return aStart.before(bEnd) && aEnd.after(bStart);
    }

    @PreAuthorize("isAuthenticated()")
    @PostMapping("/repair")
    public AjaxResult submitRepair(@RequestBody RepairTicket t)
    {
        t.setReporterUserId(SecurityUtils.getUserId());
        if (t.getStatus() == null)
        {
            t.setStatus("待处理");
        }
        // 根据故障类型自动分配处理人员
        if (StringUtils.isNotEmpty(t.getFaultType()))
        {
            if (t.getFaultType().contains("网络"))
            {
                t.setAssignee("网络维保组");
            }
            else if (t.getFaultType().contains("桌椅"))
            {
                t.setAssignee("后勤维修组");
            }
            else
            {
                t.setAssignee("综合维修组");
            }
        }
        repairTicketMapper.insertRepair(t);
        return success(t.getId());
    }

    @PreAuthorize("isAuthenticated()")
    @GetMapping("/reservation/share/{id}")
    public AjaxResult shareText(@PathVariable Long id)
    {
        RoomReservation r = roomReservationMapper.selectRoomReservationById(id);
        if (r == null || !SecurityUtils.getUserId().equals(r.getUserId()))
        {
            return error("无权访问");
        }
        String code = r.getShareCode();
        if (code == null)
        {
            code = IdUtils.fastUUID().replace("-", "").substring(0, 8).toUpperCase();
            r.setShareCode(code);
            roomReservationService.updateRoomReservation(r);
        }
        String line = "【自习室预约分享】我的预约码 " + code + "，单号 " + r.getId()
                + "，欢迎同学扫码或在前台核对后加入拼座。";
        return AjaxResult.success("操作成功", line);
    }

    /** 学生自助下单（与普通 POST /reservation/reservation 等价校验，避免单独授权 menu 权限） */
    @PreAuthorize("isAuthenticated()")
    @PostMapping("/reservation")
    public AjaxResult studentBook(@RequestBody RoomReservation body)
    {
        body.setUserId(SecurityUtils.getUserId());
        if (body.getStatus() == null)
        {
            body.setStatus("正常");
        }
        if (body.getReservationStatus() == null)
        {
            body.setReservationStatus("已预约");
        }
        return toAjax(roomReservationService.insertRoomReservation(body));
    }
}
