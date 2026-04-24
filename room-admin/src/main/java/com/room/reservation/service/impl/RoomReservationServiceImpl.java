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
import com.room.reservation.domain.ViolationRecord;
import com.room.reservation.mapper.BusinessAuditMapper;
import com.room.reservation.mapper.RoomReservationMapper;
import com.room.reservation.mapper.ThesisStudyMapper;
import com.room.reservation.mapper.ViolationRecordMapper;
import com.room.reservation.service.IRoomReservationService;
import com.room.reservation.service.ThesisReservationSupport;
import com.room.reservation.service.ThesisViolationPolicy;
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

    @Autowired
    private ViolationRecordMapper violationRecordMapper;

    @Autowired
    private ThesisViolationPolicy thesisViolationPolicy;

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
        if (StringUtils.isEmpty(roomReservation.getStatus()))
        {
            roomReservation.setStatus("正常");
        }
        if (StringUtils.isEmpty(roomReservation.getReservationStatus()))
        {
            roomReservation.setReservationStatus("已预约");
        }
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
        int rows = roomReservationMapper.insertRoomReservation(roomReservation);
        if (rows > 0)
        {
            String detail = "座位=" + roomReservation.getSeatId() + "，时间="
                    + roomReservation.getReservationInTime() + " ~ " + roomReservation.getReservationOutTime();
            businessAuditMapper.insertAudit(roomReservation.getUserId(), "提交预约", "RESERVATION",
                    roomReservation.getId(), detail);
        }
        return rows;
    }

    @Override
    public int updateRoomReservation(RoomReservation roomReservation)
    {
        if (roomReservation.getId() == null)
        {
            throw new ServiceException("预约编号不能为空");
        }
        RoomReservation current = roomReservationMapper.selectRoomReservationById(roomReservation.getId());
        if (current == null)
        {
            throw new ServiceException("预约不存在");
        }
        RoomReservation merged = mergeReservation(current, roomReservation);
        if (hasBookingDimensionChange(roomReservation))
        {
            thesisReservationSupport.assertBookingAllowed(merged, merged.getId());
        }
        int rows = roomReservationMapper.updateRoomReservation(roomReservation);
        if (rows > 0 && shouldGrantStudyMinutes(current, merged))
        {
            grantStudyMinutes(merged.getUserId(), merged.getSignInTime(), merged.getSignOutTime(), merged.getId());
        }
        return rows;
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
        businessAuditMapper.insertAudit(userId, "学生签到", "RESERVATION", reservationId, "学生扫码签到成功");
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
        grantStudyMinutes(userId, r.getSignInTime(), r.getSignOutTime(), reservationId);
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
            String note = "系统自动：预约开始后" + minutes + "分钟内未签到，已释放座位并记为违约";
            markReservationViolation(r, "未签到", note);
        }
    }

    @Override
    public void markOvertimeReservations()
    {
        String m = configService.selectConfigByKey("reservation.signOut.overdueMinutes");
        int minutes = Convert.toInt(m, 0);
        List<RoomReservation> list = roomReservationMapper.selectSignOutOverdue(minutes);
        for (RoomReservation r : list)
        {
            String note = minutes > 0
                    ? "系统自动：预约结束后" + minutes + "分钟内未签退，已释放座位并记为违约"
                    : "系统自动：预约结束后未签退，已释放座位并记为违约";
            markReservationViolation(r, "未签退", note);
        }
    }

    private RoomReservation mergeReservation(RoomReservation current, RoomReservation change)
    {
        RoomReservation merged = new RoomReservation();
        merged.setId(current.getId());
        merged.setUserId(change.getUserId() != null ? change.getUserId() : current.getUserId());
        merged.setSeatId(change.getSeatId() != null ? change.getSeatId() : current.getSeatId());
        merged.setStatus(StringUtils.isNotEmpty(change.getStatus()) ? change.getStatus() : current.getStatus());
        merged.setReservationStatus(StringUtils.isNotEmpty(change.getReservationStatus())
                ? change.getReservationStatus() : current.getReservationStatus());
        merged.setReservationInTime(change.getReservationInTime() != null
                ? change.getReservationInTime() : current.getReservationInTime());
        merged.setReservationOutTime(change.getReservationOutTime() != null
                ? change.getReservationOutTime() : current.getReservationOutTime());
        merged.setSignInTime(change.getSignInTime() != null ? change.getSignInTime() : current.getSignInTime());
        merged.setSignOutTime(change.getSignOutTime() != null ? change.getSignOutTime() : current.getSignOutTime());
        merged.setAuditStatus(StringUtils.isNotEmpty(change.getAuditStatus())
                ? change.getAuditStatus() : current.getAuditStatus());
        merged.setCarpoolGroupId(change.getCarpoolGroupId() != null
                ? change.getCarpoolGroupId() : current.getCarpoolGroupId());
        merged.setShareCode(change.getShareCode() != null ? change.getShareCode() : current.getShareCode());
        merged.setRemark(change.getRemark() != null ? change.getRemark() : current.getRemark());
        return merged;
    }

    private boolean hasBookingDimensionChange(RoomReservation change)
    {
        return change.getUserId() != null || change.getSeatId() != null
                || change.getReservationInTime() != null || change.getReservationOutTime() != null;
    }

    private boolean shouldGrantStudyMinutes(RoomReservation current, RoomReservation merged)
    {
        return current.getSignOutTime() == null
                && merged.getSignOutTime() != null
                && "完成预约".equals(merged.getReservationStatus());
    }

    private void grantStudyMinutes(Long userId, java.util.Date signInTime, java.util.Date signOutTime, Long reservationId)
    {
        if (userId == null || signInTime == null || signOutTime == null)
        {
            return;
        }
        long minutes = (signOutTime.getTime() - signInTime.getTime()) / 60000L;
        if (minutes <= 0)
        {
            return;
        }
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
        businessAuditMapper.insertAudit(userId, "签退累计学习", "RESERVATION", reservationId,
                "有效时长" + minutes + "分钟");
    }

    private void markReservationViolation(RoomReservation reservation, String violationType, String note)
    {
        String old = reservation.getRemark();
        reservation.setStatus("违约");
        reservation.setReservationStatus("违约中");
        reservation.setRemark(StringUtils.isEmpty(old) ? note : old + "；" + note);
        roomReservationMapper.updateRoomReservation(reservation);

        ViolationRecord row = new ViolationRecord();
        row.setUserId(reservation.getUserId());
        row.setReservationId(reservation.getId());
        row.setViolationType(violationType);
        row.setDescription(note);
        row.setCreateBy("system");
        violationRecordMapper.insertViolation(row);
        businessAuditMapper.insertAudit(reservation.getUserId(), "系统判定违规", "RESERVATION",
                reservation.getId(), violationType + "：" + note);
        thesisViolationPolicy.afterViolationRecorded(reservation.getUserId());
    }
}
