package com.room.reservation.controller;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.room.common.core.controller.BaseController;
import com.room.common.core.domain.AjaxResult;
import com.room.common.core.page.TableDataInfo;
import com.room.common.utils.DateUtils;
import com.room.common.utils.SecurityUtils;
import com.room.reservation.domain.FeedbackRecord;
import com.room.reservation.domain.RoomReservation;
import com.room.reservation.domain.RoomSeat;
import com.room.reservation.service.IFeedbackRecordService;
import com.room.reservation.service.IRoomReservationService;
import com.room.reservation.service.IRoomSeatService;

@RestController
@RequestMapping("/reservation/assistant")
public class ReservationAssistantController extends BaseController
{
    @Autowired
    private IRoomSeatService roomSeatService;

    @Autowired
    private IRoomReservationService roomReservationService;

    @Autowired
    private IFeedbackRecordService feedbackRecordService;

    @PreAuthorize("isAuthenticated()")
    @GetMapping("/overview")
    public AjaxResult overview(Integer roomId)
    {
        RoomSeat seatQuery = new RoomSeat();
        seatQuery.setRoomId(roomId);
        List<RoomSeat> seats = roomSeatService.selectRoomSeatList(seatQuery);
        Set<Long> seatIdSet = seats.stream().map(s -> Long.valueOf(s.getId())).collect(Collectors.toSet());

        List<RoomReservation> reservations = roomReservationService.selectRoomReservationList(new RoomReservation());
        if (roomId != null)
        {
            reservations = reservations.stream().filter(r -> seatIdSet.contains(r.getSeatId())).collect(Collectors.toList());
        }

        long totalSeats = seats.size();
        long faultSeats = seats.stream().filter(s -> Integer.valueOf(1).equals(s.getStatus())).count();
        long activeUsing = reservations.stream().filter(r -> "使用中".equals(r.getReservationStatus())).count();
        long activeReserved = reservations.stream().filter(r -> "已预约".equals(r.getReservationStatus())).count();
        long freeSeats = Math.max(totalSeats - faultSeats - activeUsing - activeReserved, 0);

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("totalSeats", totalSeats);
        data.put("faultSeats", faultSeats);
        data.put("usingSeats", activeUsing);
        data.put("reservedSeats", activeReserved);
        data.put("freeSeats", freeSeats);
        data.put("totalReservations", reservations.size());
        data.put("breachReservations", reservations.stream().filter(r -> "违约".equals(r.getStatus())).count());
        data.put("completedReservations", reservations.stream().filter(r -> "完成预约".equals(r.getReservationStatus())).count());
        return AjaxResult.success(data);
    }

    @PreAuthorize("isAuthenticated()")
    @GetMapping("/recommend")
    public AjaxResult recommend(Integer roomId, String reservationInTime, String reservationOutTime)
    {
        if (roomId == null)
        {
            return AjaxResult.error("roomId 不能为空");
        }
        Date winIn = DateUtils.parseDate(reservationInTime);
        Date winOut = DateUtils.parseDate(reservationOutTime);
        RoomSeat query = new RoomSeat();
        query.setRoomId(roomId);
        List<RoomSeat> allSeats = roomSeatService.selectRoomSeatList(query);

        List<RoomReservation> reservations = roomReservationService.selectRoomReservationList(new RoomReservation());
        Set<Long> occupiedSeatIds = reservations.stream()
                .filter(r -> seatOccupiedInWindow(r, winIn, winOut))
                .map(RoomReservation::getSeatId)
                .collect(Collectors.toSet());

        List<RoomSeat> freeSeats = allSeats.stream()
                .filter(s -> Integer.valueOf(0).equals(s.getStatus()))
                .filter(s -> !occupiedSeatIds.contains(Long.valueOf(s.getId())))
                .collect(Collectors.toList());
        if (freeSeats.isEmpty())
        {
            return AjaxResult.error("暂无可推荐座位");
        }

        int maxRow = allSeats.stream().map(RoomSeat::getRowNum).max(Integer::compareTo).orElse(1);
        int maxCol = allSeats.stream().map(RoomSeat::getColNum).max(Integer::compareTo).orElse(1);
        final double centerRow = (maxRow + 1) / 2.0;
        final double centerCol = (maxCol + 1) / 2.0;

        freeSeats.sort(Comparator.comparingDouble(s -> scoreSeat(s, centerRow, centerCol, allSeats, occupiedSeatIds)));
        RoomSeat best = freeSeats.get(0);
        Map<String, Object> data = new HashMap<>();
        data.put("seatId", best.getId());
        data.put("seatNum", best.getSeatNum());
        data.put("rowNum", best.getRowNum());
        data.put("colNum", best.getColNum());
        return AjaxResult.success(data);
    }

    @PreAuthorize("isAuthenticated()")
    @GetMapping("/groupRecommend")
    public AjaxResult groupRecommend(Integer roomId, Integer size, String reservationInTime, String reservationOutTime)
    {
        if (roomId == null)
        {
            return AjaxResult.error("roomId 不能为空");
        }
        Date winIn = DateUtils.parseDate(reservationInTime);
        Date winOut = DateUtils.parseDate(reservationOutTime);
        int groupSize = size == null || size < 2 ? 2 : size;
        RoomSeat query = new RoomSeat();
        query.setRoomId(roomId);
        List<RoomSeat> allSeats = roomSeatService.selectRoomSeatList(query);
        Map<String, RoomSeat> availableMap = new HashMap<>();

        List<RoomReservation> reservations = roomReservationService.selectRoomReservationList(new RoomReservation());
        Set<Long> occupiedSeatIds = reservations.stream()
                .filter(r -> seatOccupiedInWindow(r, winIn, winOut))
                .map(RoomReservation::getSeatId)
                .collect(Collectors.toSet());

        allSeats.stream()
                .filter(s -> Integer.valueOf(0).equals(s.getStatus()))
                .filter(s -> !occupiedSeatIds.contains(Long.valueOf(s.getId())))
                .forEach(s -> availableMap.put(s.getRowNum() + "-" + s.getColNum(), s));

        int maxRow = allSeats.stream().map(RoomSeat::getRowNum).max(Integer::compareTo).orElse(0);
        int maxCol = allSeats.stream().map(RoomSeat::getColNum).max(Integer::compareTo).orElse(0);

        for (int row = 1; row <= maxRow; row++)
        {
            for (int col = 1; col <= maxCol - groupSize + 1; col++)
            {
                List<Map<String, Object>> result = new ArrayList<>();
                boolean ok = true;
                for (int i = 0; i < groupSize; i++)
                {
                    RoomSeat seat = availableMap.get(row + "-" + (col + i));
                    if (seat == null)
                    {
                        ok = false;
                        break;
                    }
                    Map<String, Object> item = new LinkedHashMap<>();
                    item.put("seatId", seat.getId());
                    item.put("seatNum", seat.getSeatNum());
                    item.put("rowNum", seat.getRowNum());
                    item.put("colNum", seat.getColNum());
                    result.add(item);
                }
                if (ok)
                {
                    return AjaxResult.success(result);
                }
            }
        }
        return AjaxResult.error("未找到连续拼座");
    }

    @PreAuthorize("isAuthenticated()")
    @PostMapping("/feedback")
    public AjaxResult addFeedback(@RequestBody FeedbackRecord feedbackRecord)
    {
        feedbackRecord.setUserId(SecurityUtils.getUserId());
        feedbackRecord.setCreateBy(SecurityUtils.getUsername());
        if (feedbackRecord.getStatus() == null || feedbackRecord.getStatus().isEmpty())
        {
            feedbackRecord.setStatus("待处理");
        }
        return toAjax(feedbackRecordService.insertFeedbackRecord(feedbackRecord));
    }

    @PreAuthorize("isAuthenticated()")
    @GetMapping("/feedback/list")
    public TableDataInfo listFeedback(FeedbackRecord query)
    {
        FeedbackRecord actual = query == null ? new FeedbackRecord() : query;
        boolean canViewAll = SecurityUtils.hasPermi("thesis:feedback:list")
                || SecurityUtils.hasPermi("thesis:feedback:query");
        if (!canViewAll)
        {
            actual.setUserId(SecurityUtils.getUserId());
        }
        startPage();
        List<FeedbackRecord> list = feedbackRecordService.selectFeedbackRecordList(actual);
        return getDataTable(list);
    }

    @PreAuthorize("@ss.hasAnyPermi('thesis:feedback:list,thesis:feedback:query')")
    @PutMapping("/feedback/{id}/status")
    public AjaxResult updateFeedbackStatus(@PathVariable Long id, @RequestBody FeedbackRecord feedbackRecord)
    {
        FeedbackRecord db = feedbackRecordService.selectFeedbackRecordById(id);
        if (db == null)
        {
            return AjaxResult.error("记录不存在");
        }
        db.setStatus(feedbackRecord.getStatus());
        db.setHandleRemark(feedbackRecord.getHandleRemark());
        db.setUpdateBy(SecurityUtils.getUsername());
        return toAjax(feedbackRecordService.updateFeedbackRecord(db));
    }

    private double scoreSeat(RoomSeat seat, double centerRow, double centerCol, List<RoomSeat> allSeats, Set<Long> occupied)
    {
        double nearCenter = Math.abs(seat.getRowNum() - centerRow) + Math.abs(seat.getColNum() - centerCol);
        int occupiedNear = 0;
        int[][] delta = new int[][] { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } };
        Set<String> occupiedPos = new HashSet<>();
        allSeats.stream()
                .filter(s -> occupied.contains(Long.valueOf(s.getId())))
                .forEach(s -> occupiedPos.add(s.getRowNum() + "-" + s.getColNum()));
        for (int[] d : delta)
        {
            if (occupiedPos.contains((seat.getRowNum() + d[0]) + "-" + (seat.getColNum() + d[1])))
            {
                occupiedNear++;
            }
        }
        return occupiedNear * 3.0 + nearCenter;
    }

    /**
     * 某预约记录在指定时段内是否占用座位（未传时段则凡已预约/使用中都视为占用，兼容旧客户端）
     */
    private static boolean seatOccupiedInWindow(RoomReservation r, Date in, Date out)
    {
        if (!"已预约".equals(r.getReservationStatus()) && !"使用中".equals(r.getReservationStatus()))
        {
            return false;
        }
        if (in == null || out == null)
        {
            return true;
        }
        if (r.getReservationInTime() == null || r.getReservationOutTime() == null)
        {
            return true;
        }
        return r.getReservationInTime().before(out) && r.getReservationOutTime().after(in);
    }
}

