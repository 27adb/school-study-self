package com.room.reservation.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.room.reservation.domain.FeedbackRecord;

public interface FeedbackRecordMapper
{
    FeedbackRecord selectFeedbackRecordById(Long id);

    List<FeedbackRecord> selectFeedbackRecordList(FeedbackRecord query);

    /** 违规追溯卡：关联近期反馈摘要 */
    List<FeedbackRecord> selectRecentByUserId(@Param("userId") Long userId, @Param("limit") int limit);

    int insertFeedbackRecord(FeedbackRecord feedbackRecord);

    int updateFeedbackRecord(FeedbackRecord feedbackRecord);
}

