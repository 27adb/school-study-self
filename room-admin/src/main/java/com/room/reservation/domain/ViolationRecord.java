package com.room.reservation.domain;

import com.room.common.annotation.Excel;
import com.room.common.core.domain.BaseEntity;

public class ViolationRecord extends BaseEntity
{
    private static final long serialVersionUID = 1L;
    private Long id;
    private Long userId;
    private Long reservationId;
    @Excel(name = "违规类型")
    private String violationType;
    private String description;
    private String evidenceUrls;
    private String signLog;

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

    public Long getReservationId()
    {
        return reservationId;
    }

    public void setReservationId(Long reservationId)
    {
        this.reservationId = reservationId;
    }

    public String getViolationType()
    {
        return violationType;
    }

    public void setViolationType(String violationType)
    {
        this.violationType = violationType;
    }

    public String getDescription()
    {
        return description;
    }

    public void setDescription(String description)
    {
        this.description = description;
    }

    public String getEvidenceUrls()
    {
        return evidenceUrls;
    }

    public void setEvidenceUrls(String evidenceUrls)
    {
        this.evidenceUrls = evidenceUrls;
    }

    public String getSignLog()
    {
        return signLog;
    }

    public void setSignLog(String signLog)
    {
        this.signLog = signLog;
    }
}
