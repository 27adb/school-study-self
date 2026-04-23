package com.room.reservation.domain;

import com.room.common.core.domain.BaseEntity;

public class RepairTicket extends BaseEntity
{
    private static final long serialVersionUID = 1L;
    private Long id;
    private String roomName;  // 支持自习室名称或 ID
    private String seatNumber;  // 支持座位编号如 E1
    private Long reporterUserId;
    private String faultType;
    private String content;
    private String status;
    private String assignee;

    public Long getId()
    {
        return id;
    }

    public void setId(Long id)
    {
        this.id = id;
    }

    public String getRoomName()
    {
        return roomName;
    }

    public void setRoomName(String roomName)
    {
        this.roomName = roomName;
    }

    public String getSeatNumber()
    {
        return seatNumber;
    }

    public void setSeatNumber(String seatNumber)
    {
        this.seatNumber = seatNumber;
    }

    public Long getReporterUserId()
    {
        return reporterUserId;
    }

    public void setReporterUserId(Long reporterUserId)
    {
        this.reporterUserId = reporterUserId;
    }

    public String getFaultType()
    {
        return faultType;
    }

    public void setFaultType(String faultType)
    {
        this.faultType = faultType;
    }

    public String getContent()
    {
        return content;
    }

    public void setContent(String content)
    {
        this.content = content;
    }

    public String getStatus()
    {
        return status;
    }

    public void setStatus(String status)
    {
        this.status = status;
    }

    public String getAssignee()
    {
        return assignee;
    }

    public void setAssignee(String assignee)
    {
        this.assignee = assignee;
    }
}
