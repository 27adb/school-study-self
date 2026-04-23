package com.room.reservation.domain;

import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.room.common.annotation.Excel;
import com.room.common.core.domain.BaseEntity;

/**
 * 自习室座位对象 room_seat
 *
 * @author FMBOY
 * @date 2025-10-31
 */
public class RoomSeat extends BaseEntity {
    private static final long serialVersionUID = 1L;

    /**
     * 编号
     */
    private Integer id;

    /**
     * 座位号
     */
    @Excel(name = "座位号")
    private String seatNum;

    /**
     * 自习室ID
     */
    @Excel(name = "自习室ID")
    private Integer roomId;

    /**
     * 行号
     */
    @Excel(name = "行号")
    private Integer rowNum;

    /**
     * 列号
     */
    @Excel(name = "列号")
    private Integer colNum;

    /**
     * 状态
     */
    @Excel(name = "状态")
    private Integer status;

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getId() {
        return id;
    }

    public void setSeatNum(String seatNum) {
        this.seatNum = seatNum;
    }

    public String getSeatNum() {
        return seatNum;
    }

    public void setRoomId(Integer roomId) {
        this.roomId = roomId;
    }

    public Integer getRoomId() {
        return roomId;
    }

    public void setRowNum(Integer rowNum) {
        this.rowNum = rowNum;
    }

    public Integer getRowNum() {
        return rowNum;
    }

    public void setColNum(Integer colNum) {
        this.colNum = colNum;
    }

    public Integer getColNum() {
        return colNum;
    }

    public void setStatus(Integer status) {
        this.status = status;
    }

    public Integer getStatus() {
        return status;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this, ToStringStyle.MULTI_LINE_STYLE).append("id", getId()).append("seatNum", getSeatNum()).append("roomId", getRoomId()).append("rowNum", getRowNum()).append("colNum", getColNum()).append("status", getStatus()).toString();
    }
}
