package com.room.reservation.domain;

import java.util.Date;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.room.common.core.domain.BaseEntity;

public class CleaningPlan extends BaseEntity
{
    private static final long serialVersionUID = 1L;
    private Long id;
    private Long roomId;
    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date planDate;
    private String timeSlot;
    private String cleaner;
    private String status;
    private String reason;

    public Long getId()
    {
        return id;
    }

    public void setId(Long id)
    {
        this.id = id;
    }

    public Long getRoomId()
    {
        return roomId;
    }

    public void setRoomId(Long roomId)
    {
        this.roomId = roomId;
    }

    public Date getPlanDate()
    {
        return planDate;
    }

    public void setPlanDate(Date planDate)
    {
        this.planDate = planDate;
    }

    public String getTimeSlot()
    {
        return timeSlot;
    }

    public void setTimeSlot(String timeSlot)
    {
        this.timeSlot = timeSlot;
    }

    public String getCleaner()
    {
        return cleaner;
    }

    public void setCleaner(String cleaner)
    {
        this.cleaner = cleaner;
    }

    public String getStatus()
    {
        return status;
    }

    public void setStatus(String status)
    {
        this.status = status;
    }

    public String getReason()
    {
        return reason;
    }

    public void setReason(String reason)
    {
        this.reason = reason;
    }
}
