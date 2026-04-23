package com.room.reservation.mapper;

import java.util.List;
import com.room.reservation.domain.CleaningPlan;

public interface CleaningPlanMapper
{
    List<CleaningPlan> selectCleaningList(CleaningPlan q);

    int insertCleaning(CleaningPlan row);

    int updateCleaning(CleaningPlan row);

    int deleteCleaningById(Long id);
}
