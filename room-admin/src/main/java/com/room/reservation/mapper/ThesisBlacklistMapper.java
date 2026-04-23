package com.room.reservation.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.room.reservation.domain.BlacklistEntry;

public interface ThesisBlacklistMapper
{
    int countActiveByUserId(@Param("userId") Long userId);

    List<BlacklistEntry> selectBlacklistList(BlacklistEntry query);

    BlacklistEntry selectBlacklistById(Long id);

    int insertBlacklist(BlacklistEntry row);

    int updateBlacklist(BlacklistEntry row);

    int deleteBlacklistById(Long id);
}
