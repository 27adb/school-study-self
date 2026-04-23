package com.room.reservation.mapper;

import org.apache.ibatis.annotations.Param;
import com.room.reservation.domain.CarpoolGroup;

public interface CarpoolGroupMapper
{
    int insertCarpoolGroup(CarpoolGroup g);

    CarpoolGroup selectByShareCode(@Param("shareCode") String shareCode);

    int updateStatus(@Param("id") Long id, @Param("status") String status);
}
