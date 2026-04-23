package com.room.reservation.domain;

import java.util.Date;

import com.fasterxml.jackson.annotation.JsonFormat;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.room.common.annotation.Excel;
import com.room.common.core.domain.BaseEntity;

/**
 * 自习室对象 room
 *
 * @author FMBOY
 * @date 2025-10-31
 */
public class Room extends BaseEntity {
    private static final long serialVersionUID = 1L;

    /**
     * $column.columnComment
     */
    private Integer id;

    /**
     * 名称
     */
    @Excel(name = "名称")
    private String name;

    /**
     * 图片
     */
    @Excel(name = "图片")
    private String image;

    /**
     * 位置
     */
    @Excel(name = "位置")
    private String location;

    /**
     * 行数
     */
    @Excel(name = "行数")
    private Integer rowsCount;

    /**
     * 列数
     */
    @Excel(name = "列数")
    private Integer colsCount;

    /**
     * 开放时间
     */
    @JsonFormat(pattern = "HH:mm:ss")
    @Excel(name = "开放时间", width = 30, dateFormat = "HH:mm:ss")
    private Date openTime;

    /**
     * 关闭时间
     */
    @JsonFormat(pattern = "HH:mm:ss")
    @Excel(name = "关闭时间", width = 30, dateFormat = "HH:mm:ss")
    private Date closeTime;

    /**
     * 状态
     */
    @Excel(name = "状态")
    private String status;

    /** 区域舒适度评分（约 1–5） */
    @Excel(name = "舒适度")
    private Double comfortScore;

    /** 当前在馆人数（有效预约+使用中，列表接口回填，非表字段持久化也可） */
    private Integer usingCount;

    /** 区域划分：静音区/研讨区等 */
    private String areaZone;

    /** 拼座与座位类型说明 */
    private String seatRuleNote;

    /** 签到中心纬度 */
    @Excel(name = "签到纬度")
    private Double latitude;

    /** 签到中心经度 */
    @Excel(name = "签到经度")
    private Double longitude;

    /** 签到半径（米） */
    @Excel(name = "签到半径(米)")
    private Integer signRadiusMeter;

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getId() {
        return id;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getName() {
        return name;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public String getImage() {
        return image;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getLocation() {
        return location;
    }

    public void setRowsCount(Integer rowsCount) {
        this.rowsCount = rowsCount;
    }

    public Integer getRowsCount() {
        return rowsCount;
    }

    public void setColsCount(Integer colsCount) {
        this.colsCount = colsCount;
    }

    public Integer getColsCount() {
        return colsCount;
    }

    public void setOpenTime(Date openTime) {
        this.openTime = openTime;
    }

    public Date getOpenTime() {
        return openTime;
    }

    public void setCloseTime(Date closeTime) {
        this.closeTime = closeTime;
    }

    public Date getCloseTime() {
        return closeTime;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getStatus() {
        return status;
    }

    public void setComfortScore(Double comfortScore) {
        this.comfortScore = comfortScore;
    }

    public Double getComfortScore() {
        return comfortScore;
    }

    public void setUsingCount(Integer usingCount) {
        this.usingCount = usingCount;
    }

    public Integer getUsingCount() {
        return usingCount;
    }

    public String getAreaZone() {
        return areaZone;
    }

    public void setAreaZone(String areaZone) {
        this.areaZone = areaZone;
    }

    public String getSeatRuleNote() {
        return seatRuleNote;
    }

    public void setSeatRuleNote(String seatRuleNote) {
        this.seatRuleNote = seatRuleNote;
    }

    public Double getLatitude() {
        return latitude;
    }

    public void setLatitude(Double latitude) {
        this.latitude = latitude;
    }

    public Double getLongitude() {
        return longitude;
    }

    public void setLongitude(Double longitude) {
        this.longitude = longitude;
    }

    public Integer getSignRadiusMeter() {
        return signRadiusMeter;
    }

    public void setSignRadiusMeter(Integer signRadiusMeter) {
        this.signRadiusMeter = signRadiusMeter;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this, ToStringStyle.MULTI_LINE_STYLE)
                .append("id", getId())
                .append("name", getName())
                .append("image", getImage())
                .append("location", getLocation())
                .append("rowsCount", getRowsCount())
                .append("colsCount", getColsCount())
                .append("openTime", getOpenTime())
                .append("closeTime", getCloseTime())
                .append("status", getStatus())
                .append("comfortScore", getComfortScore())
                .append("usingCount", getUsingCount())
                .append("areaZone", getAreaZone())
                .append("seatRuleNote", getSeatRuleNote())
                .append("latitude", getLatitude())
                .append("longitude", getLongitude())
                .append("signRadiusMeter", getSignRadiusMeter())
                .toString();
    }
}
