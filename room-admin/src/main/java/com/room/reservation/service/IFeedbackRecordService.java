package com.room.reservation.service;

import java.util.List;

import com.room.reservation.domain.FeedbackRecord;

public interface IFeedbackRecordService
{
    FeedbackRecord selectFeedbackRecordById(Long id);

    List<FeedbackRecord> selectFeedbackRecordList(FeedbackRecord query);

    int insertFeedbackRecord(FeedbackRecord feedbackRecord);

    int updateFeedbackRecord(FeedbackRecord feedbackRecord);
}

