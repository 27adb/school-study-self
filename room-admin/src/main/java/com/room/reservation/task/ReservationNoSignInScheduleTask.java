package com.room.reservation.task;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import com.room.reservation.service.IRoomReservationService;

/**
 * 预约开始后未签到、预约结束后未签退的订单自动判定违规并释放座位
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
        roomReservationService.markOvertimeReservations();
    }
}
