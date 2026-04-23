package com.room.reservation.task;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import com.room.reservation.service.IRoomReservationService;

/**
 * 预约开始后 N 分钟内未签到自动释放座位（N 取自参数 reservation.noSignIn.releaseMinutes）
 */
@Component
public class ReservationNoSignInScheduleTask
{
    @Autowired
    private IRoomReservationService roomReservationService;

    @Scheduled(cron = "0 */1 * * * ?")
    public void releaseNoSignIn()
    {
        roomReservationService.releaseNoSignInReservations();
    }
}
