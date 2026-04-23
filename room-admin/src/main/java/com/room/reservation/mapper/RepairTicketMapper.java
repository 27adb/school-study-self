package com.room.reservation.mapper;

import java.util.List;
import com.room.reservation.domain.RepairTicket;

public interface RepairTicketMapper
{
    List<RepairTicket> selectRepairList(RepairTicket q);

    RepairTicket selectRepairById(Long id);

    int insertRepair(RepairTicket row);

    int updateRepair(RepairTicket row);
    
    int deleteRepairById(Long id);
}
