package com.room.reservation.mapper;

import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Param;

public interface ThesisStudyMapper
{
    Long selectTotalMinutes(@Param("userId") Long userId);

    int addEffectiveMinutes(@Param("userId") Long userId, @Param("minutes") long minutes);

    List<Map<String, Object>> selectAllMedalDef();

    List<Map<String, Object>> selectUserMedals(@Param("userId") Long userId);

    int insertUserMedalIgnore(@Param("userId") Long userId, @Param("code") String code);

    int redeemMedal(@Param("userId") Long userId, @Param("code") String code);

    /** 已兑换勋章数量（用于优先预约等权益） */
    int countRedeemedMedals(@Param("userId") Long userId);

    int insertMedalDef(@Param("code") String code, @Param("name") String name,
            @Param("needMinutes") int needMinutes, @Param("perkDesc") String perkDesc,
            @Param("sortOrder") int sortOrder);

    int updateMedalDef(@Param("code") String code, @Param("name") String name,
            @Param("needMinutes") int needMinutes, @Param("perkDesc") String perkDesc,
            @Param("sortOrder") int sortOrder);

    int deleteMedalDef(@Param("code") String code);
}
