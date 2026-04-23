package com.room.reservation.domain;

import com.room.common.annotation.Excel;
import com.room.common.core.domain.BaseEntity;

public class FeedbackRecord extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long id;

    @Excel(name = "用户ID")
    private Long userId;

    @Excel(name = "反馈类型")
    private String feedbackType;

    @Excel(name = "反馈内容")
    private String content;

    /** 安静度 1-5 */
    private Integer quietScore;

    /** 照明 1-5 */
    private Integer lightingScore;

    /** 申诉凭证 URL 等 */
    private String appealEvidence;

    @Excel(name = "处理状态")
    private String status;

    @Excel(name = "处理备注")
    private String handleRemark;

    public Long getId()
    {
        return id;
    }

    public void setId(Long id)
    {
        this.id = id;
    }

    public Long getUserId()
    {
        return userId;
    }

    public void setUserId(Long userId)
    {
        this.userId = userId;
    }

    public String getFeedbackType()
    {
        return feedbackType;
    }

    public void setFeedbackType(String feedbackType)
    {
        this.feedbackType = feedbackType;
    }

    public String getContent()
    {
        return content;
    }

    public void setContent(String content)
    {
        this.content = content;
    }

    public Integer getQuietScore()
    {
        return quietScore;
    }

    public void setQuietScore(Integer quietScore)
    {
        this.quietScore = quietScore;
    }

    public Integer getLightingScore()
    {
        return lightingScore;
    }

    public void setLightingScore(Integer lightingScore)
    {
        this.lightingScore = lightingScore;
    }

    public String getAppealEvidence()
    {
        return appealEvidence;
    }

    public void setAppealEvidence(String appealEvidence)
    {
        this.appealEvidence = appealEvidence;
    }

    public String getStatus()
    {
        return status;
    }

    public void setStatus(String status)
    {
        this.status = status;
    }

    public String getHandleRemark()
    {
        return handleRemark;
    }

    public void setHandleRemark(String handleRemark)
    {
        this.handleRemark = handleRemark;
    }
}

