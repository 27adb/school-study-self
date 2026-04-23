package com.room.reservation.task;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import com.room.reservation.domain.RoomReservation;
import com.room.reservation.mapper.RoomReservationMapper;
import com.room.reservation.mapper.ThesisAppReminderMapper;
import com.room.reservation.service.ThesisReservationSupport;

@Component
public class ThesisReminderScheduleTask
{
    @Autowired
    private RoomReservationMapper roomReservationMapper;

    @Autowired
    private ThesisAppReminderMapper thesisAppReminderMapper;

    @Autowired
    private ThesisReservationSupport thesisReservationSupport;

    @Scheduled(cron = "0 */5 * * * ?")
    public void pushReminders()
    {
        int m = thesisReservationSupport.reminderMinutesBefore();
        List<RoomReservation> list = roomReservationMapper.selectNeedingReminders(m);
        for (RoomReservation r : list)
        {
            thesisAppReminderMapper.insertReminder(r.getUserId(), r.getId(), "预约即将开始",
                    "您的预约将于 " + r.getReservationInTime() + " 开始，请按时到馆扫码签到。",
                    new java.util.Date());
        }
    }
}
