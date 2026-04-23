package com.room.reservation.domain;

import java.util.Date;

public class CarpoolGroup
{
    private Long id;
    private Long roomId;
    private Long leaderUserId;
    private Integer seatCount;
    private String shareCode;
    private String status;
    private Date expireTime;
    private Date createTime;

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

    public Long getLeaderUserId()
    {
        return leaderUserId;
    }

    public void setLeaderUserId(Long leaderUserId)
    {
        this.leaderUserId = leaderUserId;
    }

    public Integer getSeatCount()
    {
        return seatCount;
    }

    public void setSeatCount(Integer seatCount)
    {
        this.seatCount = seatCount;
    }

    public String getShareCode()
    {
        return shareCode;
    }

    public void setShareCode(String shareCode)
    {
        this.shareCode = shareCode;
    }

    public String getStatus()
    {
        return status;
    }

    public void setStatus(String status)
    {
        this.status = status;
    }

    public Date getExpireTime()
    {
        return expireTime;
    }

    public void setExpireTime(Date expireTime)
    {
        this.expireTime = expireTime;
    }

    public Date getCreateTime()
    {
        return createTime;
    }

    public void setCreateTime(Date createTime)
    {
        this.createTime = createTime;
    }
}
