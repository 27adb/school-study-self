package com.room.reservation.domain;

import com.room.common.core.domain.BaseEntity;

public class UserCourseSchedule extends BaseEntity
{
    private static final long serialVersionUID = 1L;
    private Long id;
    private Long userId;
    /** 1-7 周一到周日（ISO：1=周一） */
    private Integer weekDay;
    private String startTime;
    private String endTime;
    private String courseName;

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

    public Integer getWeekDay()
    {
        return weekDay;
    }

    public void setWeekDay(Integer weekDay)
    {
        this.weekDay = weekDay;
    }

    public String getStartTime()
    {
        return startTime;
    }

    public void setStartTime(String startTime)
    {
        this.startTime = startTime;
    }

    public String getEndTime()
    {
        return endTime;
    }

    public void setEndTime(String endTime)
    {
        this.endTime = endTime;
    }

    public String getCourseName()
    {
        return courseName;
    }

    public void setCourseName(String courseName)
    {
        this.courseName = courseName;
    }
}
