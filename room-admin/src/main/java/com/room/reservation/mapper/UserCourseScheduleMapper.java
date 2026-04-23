package com.room.reservation.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.room.reservation.domain.UserCourseSchedule;

public interface UserCourseScheduleMapper
{
    List<UserCourseSchedule> selectByUserId(@Param("userId") Long userId);

    int insertUserCourse(UserCourseSchedule row);

    int deleteUserCourse(@Param("id") Long id, @Param("userId") Long userId);
}
