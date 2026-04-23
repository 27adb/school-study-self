package com.room.reservation.mapper;

import java.util.Date;
import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Param;

public interface ThesisUsageAlertMapper
{
    int insertAlert(@Param("roomId") Long roomId, @Param("alertDate") Date alertDate,
            @Param("rate") double rate, @Param("message") String message);

    List<Map<String, Object>> selectUnreadAlerts();

    int markAlertRead(@Param("id") Long id);

    int countAlertOnDate(@Param("roomId") Long roomId, @Param("alertDate") Date alertDate);
}
