package com.room.reservation.service.impl;

import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.room.common.core.text.Convert;
import com.room.common.exception.ServiceException;
import com.room.common.utils.DateUtils;
import com.room.common.utils.StringUtils;
import com.room.reservation.domain.RoomReservation;
import com.room.reservation.mapper.BusinessAuditMapper;
import com.room.reservation.mapper.RoomReservationMapper;
import com.room.reservation.mapper.ThesisStudyMapper;
import com.room.reservation.service.IRoomReservationService;
import com.room.reservation.service.ThesisReservationSupport;
import com.room.system.service.ISysConfigService;

/**
 * 自习室预约管理Service业务层处理
 * 
 * @author FMBOY
 * @date 2025-11-16
 */
@Service
public class RoomReservationServiceImpl implements IRoomReservationService 
{
    @Autowired
    private RoomReservationMapper roomReservationMapper;

    @Autowired
    private ISysConfigService configService;

    @Autowired
    private ThesisReservationSupport thesisReservationSupport;

    @Autowired
    private ThesisStudyMapper thesisStudyMapper;

    @Autowired
    private BusinessAuditMapper businessAuditMapper;

    @Override
    public RoomReservation selectRoomReservationById(Long id)
    {
        return roomReservationMapper.selectRoomReservationById(id);
    }

    @Override
    public List<RoomReservation> selectRoomReservationList(RoomReservation roomReservation)
    {
        return roomReservationMapper.selectRoomReservationList(roomReservation);
    }

    @Override
    public int insertRoomReservation(RoomReservation roomReservation)
    {
        thesisReservationSupport.assertBookingAllowed(roomReservation, null);
        String need = configService.selectConfigByKey("reservation.audit.enabled");
        if (StringUtils.isNotEmpty(need) && "true".equalsIgnoreCase(need.trim()))
        {
            roomReservation.setAuditStatus("待审核");
        }
        else if (StringUtils.isEmpty(roomReservation.getAuditStatus()))
        {
            roomReservation.setAuditStatus("无需审核");
        }
        return roomReservationMapper.insertRoomReservation(roomReservation);
    }

    @Override
    public int updateRoomReservation(RoomReservation roomReservation)
    {
        return roomReservationMapper.updateRoomReservation(roomReservation);
    }

    @Override
    public int deleteRoomReservationByIds(Long[] ids)
    {
        return roomReservationMapper.deleteRoomReservationByIds(ids);
    }

    @Override
    public int deleteRoomReservationById(Long id)
    {
        return roomReservationMapper.deleteRoomReservationById(id);
    }

    @Override
    public void studentSignIn(Long reservationId, Long userId)
    {
        RoomReservation r = roomReservationMapper.selectRoomReservationById(reservationId);
        if (r == null || !userId.equals(r.getUserId()))
        {
            throw new ServiceException("无权操作该预约");
        }
        if ("待审核".equals(r.getAuditStatus()))
        {
            throw new ServiceException("订单待管理员审核通过后才能签到");
        }
        if ("已拒绝".equals(r.getAuditStatus()))
        {
            throw new ServiceException("订单已拒绝，无法签到");
        }
        if (!"已预约".equals(r.getReservationStatus()))
        {
            throw new ServiceException("当前状态不可签到");
        }
        r.setSignInTime(DateUtils.getNowDate());
        r.setReservationStatus("使用中");
        roomReservationMapper.updateRoomReservation(r);
    }

    @Override
    public void studentSignOut(Long reservationId, Long userId)
    {
        RoomReservation r = roomReservationMapper.selectRoomReservationById(reservationId);
        if (r == null || !userId.equals(r.getUserId()))
        {
            throw new ServiceException("无权操作该预约");
        }
        if (!"使用中".equals(r.getReservationStatus()))
        {
            throw new ServiceException("当前状态不可签退");
        }
        r.setSignOutTime(DateUtils.getNowDate());
        r.setReservationStatus("完成预约");
        roomReservationMapper.updateRoomReservation(r);
        if (r.getSignInTime() != null && r.getSignOutTime() != null)
        {
            long minutes = (r.getSignOutTime().getTime() - r.getSignInTime().getTime()) / 60000L;
            if (minutes > 0)
            {
                thesisStudyMapper.addEffectiveMinutes(userId, minutes);
                Long total = thesisStudyMapper.selectTotalMinutes(userId);
                if (total == null)
                {
                    total = 0L;
                }
                List<Map<String, Object>> defs = thesisStudyMapper.selectAllMedalDef();
                for (Map<String, Object> d : defs)
                {
                    int need = ((Number) d.get("needMinutes")).intValue();
                    if (total >= need)
                    {
                        thesisStudyMapper.insertUserMedalIgnore(userId, (String) d.get("code"));
                    }
                }
                businessAuditMapper.insertAudit(userId, "签退累计学习", "预约单", reservationId,
                        "有效时长" + minutes + "分钟");
            }
        }
    }

    @Override
    public int auditReservation(Long reservationId, String auditStatus)
    {
        RoomReservation r = roomReservationMapper.selectRoomReservationById(reservationId);
        if (r == null)
        {
            throw new ServiceException("预约不存在");
        }
        if (!"待审核".equals(r.getAuditStatus()))
        {
            throw new ServiceException("当前订单不在待审核状态");
        }
        if ("已通过".equals(auditStatus))
        {
            r.setAuditStatus("已通过");
            int n = roomReservationMapper.updateRoomReservation(r);
            if (n > 0)
            {
                businessAuditMapper.insertAudit(r.getUserId(), "订单审核", "RESERVATION", reservationId,
                        "审核结果:已通过");
            }
            return n;
        }
        if ("已拒绝".equals(auditStatus))
        {
            r.setAuditStatus("已拒绝");
            r.setReservationStatus("取消预约");
            int n = roomReservationMapper.updateRoomReservation(r);
            if (n > 0)
            {
                businessAuditMapper.insertAudit(r.getUserId(), "订单审核", "RESERVATION", reservationId,
                        "审核结果:已拒绝，预约已取消");
            }
            return n;
        }
        throw new ServiceException("审核结果无效，仅支持：已通过 / 已拒绝");
    }

    @Override
    public void releaseNoSignInReservations()
    {
        String m = configService.selectConfigByKey("reservation.noSignIn.releaseMinutes");
        int minutes = Convert.toInt(m, 15);
        List<RoomReservation> list = roomReservationMapper.selectNoSignInOverdue(minutes);
        for (RoomReservation r : list)
        {
            String note = "系统自动：预约开始后" + minutes + "分钟内未签到，已释放座位";
            String old = r.getRemark();
            r.setRemark(StringUtils.isEmpty(old) ? note : old + "；" + note);
            r.setReservationStatus("取消预约");
            roomReservationMapper.updateRoomReservation(r);
        }
    }
}
