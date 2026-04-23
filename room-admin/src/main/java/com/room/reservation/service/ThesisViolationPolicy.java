package com.room.reservation.service;

import java.util.Calendar;
import java.util.Date;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import com.room.common.core.text.Convert;
import com.room.common.utils.StringUtils;
import com.room.reservation.domain.BlacklistEntry;
import com.room.reservation.mapper.ThesisBlacklistMapper;
import com.room.reservation.mapper.ViolationRecordMapper;
import com.room.system.service.ISysConfigService;

/**
 * 违规累计达阈值时自动写入黑名单（可配置关闭）
 */
@Component
public class ThesisViolationPolicy
{
    @Autowired
    private ViolationRecordMapper violationRecordMapper;

    @Autowired
    private ThesisBlacklistMapper thesisBlacklistMapper;

    @Autowired
    private ISysConfigService configService;

    public void afterViolationRecorded(Long userId)
    {
        if (userId == null)
        {
            return;
        }
        String en = configService.selectConfigByKey("violation.auto.blacklist.enabled");
        if (StringUtils.isEmpty(en) || !"true".equalsIgnoreCase(en.trim()))
        {
            return;
        }
        if (thesisBlacklistMapper.countActiveByUserId(userId) > 0)
        {
            return;
        }
        int threshold = Convert.toInt(configService.selectConfigByKey("violation.count.threshold"), 3);
        int lookbackDays = Convert.toInt(configService.selectConfigByKey("violation.lookback.days"), 90);
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.DAY_OF_MONTH, -lookbackDays);
        Date since = cal.getTime();
        int cnt = violationRecordMapper.countSince(userId, since);
        if (cnt < threshold)
        {
            return;
        }
        int banDays = Convert.toInt(configService.selectConfigByKey("violation.blacklist.days"), 7);
        Calendar until = Calendar.getInstance();
        until.add(Calendar.DAY_OF_MONTH, banDays);
        BlacklistEntry row = new BlacklistEntry();
        row.setUserId(userId);
        row.setReason("系统自动：累计违规达 " + cnt + " 次（近 " + lookbackDays + " 天）");
        row.setUntilDate(until.getTime());
        row.setStatus("0");
        row.setCreateBy("system");
        thesisBlacklistMapper.insertBlacklist(row);
    }
}
