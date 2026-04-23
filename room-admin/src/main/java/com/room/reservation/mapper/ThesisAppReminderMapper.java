package com.room.reservation.mapper;

import java.util.Date;
import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Param;

public interface ThesisAppReminderMapper
{
    int insertReminder(@Param("userId") Long userId, @Param("reservationId") Long reservationId,
            @Param("title") String title, @Param("body") String body, @Param("fireTime") Date fireTime);

    List<Map<String, Object>> selectUnreadByUser(@Param("userId") Long userId);

    int markRead(@Param("id") Long id, @Param("userId") Long userId);
}
