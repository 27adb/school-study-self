package com.room.reservation.domain;

import java.util.Date;

/** 校园短信验证码 */
public class CampusVerifyCode
{
    private Long id;
    private String campusAccount;
    private String code;
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

    public String getCampusAccount()
    {
        return campusAccount;
    }

    public void setCampusAccount(String campusAccount)
    {
        this.campusAccount = campusAccount;
    }

    public String getCode()
    {
        return code;
    }

    public void setCode(String code)
    {
        this.code = code;
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
