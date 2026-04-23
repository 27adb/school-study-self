package com.room.reservation.domain;

import java.util.Date;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.room.common.core.domain.BaseEntity;

public class BlacklistEntry extends BaseEntity
{
    private static final long serialVersionUID = 1L;
    private Long id;
    private Long userId;
    private String reason;
    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date untilDate;
    private String status;

    public Long getId()
    {
        return id;
    }

    public void setId(Long id)
    {
        this.id = id;
    }

    public Long getUserId()
    {
        return userId;
    }

    public void setUserId(Long userId)
    {
        this.userId = userId;
    }

    public String getReason()
    {
        return reason;
    }

    public void setReason(String reason)
    {
        this.reason = reason;
    }

    public Date getUntilDate()
    {
        return untilDate;
    }

    public void setUntilDate(Date untilDate)
    {
        this.untilDate = untilDate;
    }

    public String getStatus()
    {
        return status;
    }

    public void setStatus(String status)
    {
        this.status = status;
    }
}
