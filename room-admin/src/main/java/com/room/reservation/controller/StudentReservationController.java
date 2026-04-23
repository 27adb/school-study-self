package com.room.reservation.controller;

import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.room.common.core.controller.BaseController;
import com.room.common.core.domain.AjaxResult;
import com.room.reservation.service.IRoomReservationService;

/**
 * 学生端预约相关接口（JWT 登录后即可调用，在业务层校验仅为本人订单）
 */
@RestController
@RequestMapping("/student/reservation")
public class StudentReservationController extends BaseController
{
    @Autowired
    private IRoomReservationService roomReservationService;

    @PostMapping("/signIn")
    public AjaxResult signIn(@RequestBody Map<String, Object> body)
    {
        Long id = Long.valueOf(body.get("id").toString());
        roomReservationService.studentSignIn(id, getUserId());
        return success();
    }

    @PostMapping("/signOut")
    public AjaxResult signOut(@RequestBody Map<String, Object> body)
    {
        Long id = Long.valueOf(body.get("id").toString());
        roomReservationService.studentSignOut(id, getUserId());
        return success();
    }
}
