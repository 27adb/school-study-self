package com.room.reservation.domain;

import java.util.Date;
import com.fasterxml.jackson.annotation.JsonFormat;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.room.common.annotation.Excel;
import com.room.common.core.domain.BaseEntity;

/**
 * 自习室预约管理对象 room_reservation
 *
 * @author FMBOY
 * @date 2025-11-16
 */
public class RoomReservation extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 编号 */
    @Excel(name = "编号")
    private Long id;

    /** 用户ID */
    @Excel(name = "用户ID")
    private Long userId;

    /** 座位ID */
    @Excel(name = "座位ID")
    private Long seatId;

    /** 状态 */
    @Excel(name = "状态")
    private String status;

    /** 预约状态 */
    @Excel(name = "预约状态")
    private String reservationStatus;

    /** 预约开始时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @Excel(name = "预约开始时间", width = 30, dateFormat = "yyyy-MM-dd HH:mm:ss")
    private Date reservationInTime;

    /** 预约结束时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @Excel(name = "预约结束时间", width = 30, dateFormat = "yyyy-MM-dd HH:mm:ss")
    private Date reservationOutTime;

    /** 签到时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @Excel(name = "签到时间", width = 30, dateFormat = "yyyy-MM-dd HH:mm:ss")
    private Date signInTime;

    /** 签退时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @Excel(name = "签退时间", width = 30, dateFormat = "yyyy-MM-dd HH:mm:ss")
    private Date signOutTime;

    /** 订单审核状态：无需审核/待审核/已通过/已拒绝 */
    @Excel(name = "订单审核")
    private String auditStatus;

    /** 拼座组 */
    private Long carpoolGroupId;

    /** 分享码 */
    private String shareCode;

    public void setId(Long id)
    {
        this.id = id;
    }

    public Long getId()
    {
        return id;
    }

    public void setUserId(Long userId)
    {
        this.userId = userId;
    }

    public Long getUserId()
    {
        return userId;
    }

    public void setSeatId(Long seatId)
    {
        this.seatId = seatId;
    }

    public Long getSeatId()
    {
        return seatId;
    }

    public void setStatus(String status)
    {
        this.status = status;
    }

    public String getStatus()
    {
        return status;
    }

    public void setReservationStatus(String reservationStatus)
    {
        this.reservationStatus = reservationStatus;
    }

    public String getReservationStatus()
    {
        return reservationStatus;
    }

    public void setReservationInTime(Date reservationInTime)
    {
        this.reservationInTime = reservationInTime;
    }

    public Date getReservationInTime()
    {
        return reservationInTime;
    }

    public void setReservationOutTime(Date reservationOutTime)
    {
        this.reservationOutTime = reservationOutTime;
    }

    public Date getReservationOutTime()
    {
        return reservationOutTime;
    }

    public void setSignInTime(Date signInTime)
    {
        this.signInTime = signInTime;
    }

    public Date getSignInTime()
    {
        return signInTime;
    }

    public void setSignOutTime(Date signOutTime)
    {
        this.signOutTime = signOutTime;
    }

    public Date getSignOutTime()
    {
        return signOutTime;
    }

    public void setAuditStatus(String auditStatus)
    {
        this.auditStatus = auditStatus;
    }

    public String getAuditStatus()
    {
        return auditStatus;
    }

    public Long getCarpoolGroupId()
    {
        return carpoolGroupId;
    }

    public void setCarpoolGroupId(Long carpoolGroupId)
    {
        this.carpoolGroupId = carpoolGroupId;
    }

    public String getShareCode()
    {
        return shareCode;
    }

    public void setShareCode(String shareCode)
    {
        this.shareCode = shareCode;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this,ToStringStyle.MULTI_LINE_STYLE)
            .append("id", getId())
            .append("userId", getUserId())
            .append("seatId", getSeatId())
            .append("status", getStatus())
            .append("reservationStatus", getReservationStatus())
            .append("reservationInTime", getReservationInTime())
            .append("reservationOutTime", getReservationOutTime())
            .append("signInTime", getSignInTime())
            .append("signOutTime", getSignOutTime())
            .append("auditStatus", getAuditStatus())
            .append("carpoolGroupId", getCarpoolGroupId())
            .append("shareCode", getShareCode())
            .append("remark", getRemark())
            .toString();
    }
}
