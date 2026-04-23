package com.room.reservation.mapper;

import java.util.Date;
import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.room.reservation.domain.ViolationRecord;

public interface ViolationRecordMapper
{
    List<ViolationRecord> selectViolationList(ViolationRecord q);

    ViolationRecord selectViolationById(Long id);

    int insertViolation(ViolationRecord row);

    int deleteViolationById(Long id);

    /** 统计用户自某时间起的违规记录数（用于自动拉黑） */
    int countSince(@Param("userId") Long userId, @Param("since") Date since);
}
