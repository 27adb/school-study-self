package com.room.reservation.task;

import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import com.room.common.core.text.Convert;
import com.room.reservation.mapper.ThesisDashboardMapper;
import com.room.reservation.mapper.ThesisUsageAlertMapper;
import com.room.system.service.ISysConfigService;

/**
 * 预约率超阈值时生成高峰预警（管理员在「全局数据看板」查看）
 */
@Component
public class ThesisUsageAlertScheduleTask
{
    @Autowired
    private ThesisDashboardMapper thesisDashboardMapper;

    @Autowired
    private ThesisUsageAlertMapper thesisUsageAlertMapper;

    @Autowired
    private ISysConfigService configService;

    @Scheduled(cron = "0 15 * * * ?")
    public void scanUsage()
    {
        int threshold = Convert.toInt(configService.selectConfigByKey("reservation.alert.usagePercent"), 70);
        Calendar cal = Calendar.getInstance();
        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);
        Date today = cal.getTime();
        List<Map<String, Object>> rows = thesisDashboardMapper.selectTodayRoomUsage();
        for (Map<String, Object> row : rows)
        {
            Number ts = (Number) row.get("totalSeats");
            Number rs = (Number) row.get("reservedToday");
            Number rid = (Number) row.get("roomId");
            if (ts == null || rid == null || ts.intValue() == 0)
            {
                continue;
            }
            double pct = (rs == null ? 0 : rs.doubleValue()) * 100.0 / ts.intValue();
            if (pct >= threshold)
            {
                if (thesisUsageAlertMapper.countAlertOnDate(rid.longValue(), today) > 0)
                {
                    continue;
                }
                thesisUsageAlertMapper.insertAlert(rid.longValue(), today, pct,
                        "自习室「" + row.get("name") + "」今日预约率已达 " + (int) pct + "%，建议开放备用区域。");
            }
        }
    }
}
