package com.room.reservation.service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;
import java.util.Date;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import com.room.common.core.text.Convert;
import com.room.common.exception.ServiceException;
import com.room.common.utils.StringUtils;
import com.room.reservation.domain.RoomReservation;
import com.room.reservation.domain.UserCourseSchedule;
import com.room.reservation.mapper.RoomReservationMapper;
import com.room.reservation.mapper.ThesisBlacklistMapper;
import com.room.reservation.mapper.ThesisStudyMapper;
import com.room.reservation.mapper.UserCourseScheduleMapper;
import com.room.system.service.ISysConfigService;

/**
 * 论文扩展：黑名单、座位/用户时段重叠、课程冲突、预约时长
 */
@Component
public class ThesisReservationSupport
{
    @Autowired
    private ThesisBlacklistMapper thesisBlacklistMapper;

    @Autowired
    private RoomReservationMapper roomReservationMapper;

    @Autowired
    private UserCourseScheduleMapper userCourseScheduleMapper;

    @Autowired
    private ISysConfigService configService;

    @Autowired
    private ThesisStudyMapper thesisStudyMapper;

    public void assertBookingAllowed(RoomReservation r, Long excludeReservationId)
    {
        if (r.getUserId() == null || r.getSeatId() == null
                || r.getReservationInTime() == null || r.getReservationOutTime() == null)
        {
            throw new ServiceException("预约参数不完整");
        }
        if (thesisBlacklistMapper.countActiveByUserId(r.getUserId()) > 0
                && !medalPriorityBypassBlacklist(r.getUserId()))
        {
            throw new ServiceException("您处于预约黑名单中，暂不可预约（已兑换勋章优先权可豁免，见系统配置）");
        }
        int minH = Convert.toInt(configService.selectConfigByKey("reservation.minHours"), 1);
        int maxH = Convert.toInt(configService.selectConfigByKey("reservation.maxHours"), 4);
        long ms = r.getReservationOutTime().getTime() - r.getReservationInTime().getTime();
        double hours = ms / 3600000.0;
        if (hours < minH - 0.0001 || hours > maxH + 0.0001)
        {
            throw new ServiceException("预约时长须在 " + minH + "~" + maxH + " 小时之间");
        }
        if (roomReservationMapper.countSeatOverlap(r.getSeatId(), r.getReservationInTime(),
                r.getReservationOutTime(), excludeReservationId) > 0)
        {
            throw new ServiceException("该时段座位已被预约");
        }
        if (roomReservationMapper.countUserOverlap(r.getUserId(), r.getReservationInTime(),
                r.getReservationOutTime(), excludeReservationId) > 0)
        {
            throw new ServiceException("您在该时段已有预约，系统已拦截课程/时间冲突");
        }
        assertNoCourseConflict(r.getUserId(), r.getReservationInTime(), r.getReservationOutTime());
    }

    private void assertNoCourseConflict(Long userId, Date inTime, Date outTime)
    {
        LocalDateTime lIn = inTime.toInstant().atZone(ZoneId.systemDefault()).toLocalDateTime();
        LocalDateTime lOut = outTime.toInstant().atZone(ZoneId.systemDefault()).toLocalDateTime();
        int weekDay = lIn.getDayOfWeek().getValue();
        LocalTime tStart = lIn.toLocalTime();
        LocalTime tEnd = lOut.toLocalTime();
        List<UserCourseSchedule> courses = userCourseScheduleMapper.selectByUserId(userId);
        for (UserCourseSchedule c : courses)
        {
            if (c.getWeekDay() == null || !c.getWeekDay().equals(Integer.valueOf(weekDay)))
            {
                continue;
            }
            LocalTime c0 = LocalTime.parse(c.getStartTime());
            LocalTime c1 = LocalTime.parse(c.getEndTime());
            if (tStart.isBefore(c1) && tEnd.isAfter(c0))
            {
                throw new ServiceException("与课程《" + StringUtils.nvl(c.getCourseName(), "课表") + "》时间冲突");
            }
        }
    }

    /** 签到截止前生成提醒 */
    public int reminderMinutesBefore()
    {
        return Convert.toInt(configService.selectConfigByKey("reservation.reminder.minutesBefore"), 30);
    }

    /**
     * 已兑换勋章的「优先预约权」：配置 medal.redeem.bypassBlacklist=true 时，可豁免黑名单限制。
     */
    private boolean medalPriorityBypassBlacklist(Long userId)
    {
        String v = configService.selectConfigByKey("medal.redeem.bypassBlacklist");
        if (!"true".equalsIgnoreCase(StringUtils.trim(v)))
        {
            return false;
        }
        return thesisStudyMapper.countRedeemedMedals(userId) > 0;
    }
}
