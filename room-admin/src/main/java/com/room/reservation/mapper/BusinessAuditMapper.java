package com.room.reservation.mapper;

import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Param;

public interface BusinessAuditMapper
{
    int insertAudit(@Param("userId") Long userId, @Param("actionType") String actionType,
            @Param("refType") String refType, @Param("refId") Long refId, @Param("detail") String detail);

    List<Map<String, Object>> selectAuditList(@Param("actionType") String actionType,
            @Param("userId") Long userId, @Param("beginTime") String beginTime,
            @Param("endTime") String endTime);
}
