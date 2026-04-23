package com.room.reservation.mapper;

import org.apache.ibatis.annotations.Param;
import com.room.reservation.domain.CampusVerifyCode;

public interface CampusVerifyCodeMapper
{
    int insertCampusVerifyCode(CampusVerifyCode row);

    CampusVerifyCode selectLatest(@Param("campusAccount") String campusAccount);

    int deleteExpired();
}
