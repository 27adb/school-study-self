package com.room.reservation.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.room.reservation.domain.FeedbackRecord;
import com.room.reservation.mapper.FeedbackRecordMapper;
import com.room.reservation.service.IFeedbackRecordService;

@Service
public class FeedbackRecordServiceImpl implements IFeedbackRecordService
{
    @Autowired
    private FeedbackRecordMapper feedbackRecordMapper;

    @Override
    public FeedbackRecord selectFeedbackRecordById(Long id)
    {
        return feedbackRecordMapper.selectFeedbackRecordById(id);
    }

    @Override
    public List<FeedbackRecord> selectFeedbackRecordList(FeedbackRecord query)
    {
        return feedbackRecordMapper.selectFeedbackRecordList(query);
    }

    @Override
    public int insertFeedbackRecord(FeedbackRecord feedbackRecord)
    {
        return feedbackRecordMapper.insertFeedbackRecord(feedbackRecord);
    }

    @Override
    public int updateFeedbackRecord(FeedbackRecord feedbackRecord)
    {
        return feedbackRecordMapper.updateFeedbackRecord(feedbackRecord);
    }
}

