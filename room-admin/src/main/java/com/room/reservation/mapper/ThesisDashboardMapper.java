package com.room.reservation.mapper;

import java.util.List;
import java.util.Map;

public interface ThesisDashboardMapper
{
    /**
     * 今日各自习室：已占用座位约占比（简化为：有效预约数/总座位）
     */
    List<Map<String, Object>> selectTodayRoomUsage();

    List<Map<String, Object>> selectMonthlyReservationCount();

    List<Map<String, Object>> selectComfortDistribution();

    List<Map<String, Object>> selectStudyTimeRank();

    /** 今日各小时预约单量（热门时段） */
    List<Map<String, Object>> selectHourlyReservationToday();
}
