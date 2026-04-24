package com.room.reservation.controller;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.room.common.core.controller.BaseController;
import com.room.common.core.domain.AjaxResult;
import com.room.common.core.page.TableDataInfo;
import com.room.common.utils.SecurityUtils;
import com.room.common.utils.StringUtils;
import com.room.common.utils.poi.ExcelUtil;
import com.room.reservation.domain.BlacklistEntry;
import com.room.reservation.domain.CleaningPlan;
import com.room.reservation.domain.FeedbackRecord;
import com.room.reservation.domain.RepairTicket;
import com.room.reservation.domain.RoomReservation;
import com.room.reservation.domain.FeedbackRecord;
import com.room.reservation.domain.ViolationRecord;
import com.room.reservation.domain.vo.ThesisGlobalExportRow;
import com.room.reservation.mapper.BusinessAuditMapper;
import com.room.reservation.mapper.FeedbackRecordMapper;
import com.room.reservation.mapper.CleaningPlanMapper;
import com.room.reservation.mapper.RepairTicketMapper;
import com.room.reservation.mapper.RoomReservationMapper;
import com.room.reservation.mapper.ThesisBlacklistMapper;
import com.room.reservation.mapper.ThesisDashboardMapper;
import com.room.reservation.mapper.ThesisStudyMapper;
import com.room.reservation.mapper.ThesisUsageAlertMapper;
import com.room.reservation.mapper.ViolationRecordMapper;
import com.room.reservation.service.IFeedbackRecordService;
import com.room.reservation.service.ThesisViolationPolicy;
import com.room.system.service.ISysConfigService;

@RestController
@RequestMapping("/thesis/admin")
public class ThesisAdminController extends BaseController
{
    @Autowired
    private ViolationRecordMapper violationRecordMapper;

    @Autowired
    private ThesisViolationPolicy thesisViolationPolicy;

    @Autowired
    private ThesisBlacklistMapper thesisBlacklistMapper;

    @Autowired
    private RepairTicketMapper repairTicketMapper;

    @Autowired
    private CleaningPlanMapper cleaningPlanMapper;

    @Autowired
    private ThesisDashboardMapper thesisDashboardMapper;

    @Autowired
    private ThesisUsageAlertMapper thesisUsageAlertMapper;

    @Autowired
    private BusinessAuditMapper businessAuditMapper;

    @Autowired
    private RoomReservationMapper roomReservationMapper;

    @Autowired
    private ISysConfigService configService;

    @Autowired
    private ThesisStudyMapper thesisStudyMapper;

    @Autowired
    private IFeedbackRecordService feedbackRecordService;

    @Autowired
    private FeedbackRecordMapper feedbackRecordMapper;

    @PreAuthorize("@ss.hasPermi('thesis:violation:list')")
    @GetMapping("/violation/list")
    public AjaxResult violationList(ViolationRecord q)
    {
        return success(violationRecordMapper.selectViolationList(q == null ? new ViolationRecord() : q));
    }

    @PreAuthorize("@ss.hasPermi('thesis:violation:add')")
    @PostMapping("/violation")
    public AjaxResult addViolation(@RequestBody ViolationRecord row)
    {
        row.setCreateBy(SecurityUtils.getUsername());
        if (row.getReservationId() != null)
        {
            RoomReservation r = roomReservationMapper.selectRoomReservationById(row.getReservationId());
            if (r != null)
            {
                row.setSignLog("预约:" + r.getReservationStatus() + " 签到:" + r.getSignInTime());
            }
        }
        if (row.getUserId() != null)
        {
            List<FeedbackRecord> fbs = feedbackRecordMapper.selectRecentByUserId(row.getUserId(), 5);
            if (fbs != null && !fbs.isEmpty())
            {
                StringBuilder fb = new StringBuilder();
                for (FeedbackRecord f : fbs)
                {
                    String c = f.getContent();
                    if (c == null)
                    {
                        c = "";
                    }
                    else if (c.length() > 80)
                    {
                        c = c.substring(0, 80);
                    }
                    fb.append("[").append(StringUtils.nvl(f.getFeedbackType(), "")).append("]").append(c.trim())
                            .append("; ");
                }
                String base = row.getSignLog() == null ? "" : row.getSignLog() + " | ";
                row.setSignLog(base + "周边反馈摘录:" + fb);
            }
        }
        violationRecordMapper.insertViolation(row);
        businessAuditMapper.insertAudit(null, "违规登记", "VIOLATION", row.getId(),
                row.getViolationType());
        thesisViolationPolicy.afterViolationRecorded(row.getUserId());
        return success(row.getId());
    }

    @PreAuthorize("@ss.hasPermi('thesis:violation:remove')")
    @DeleteMapping("/violation/{id}")
    public AjaxResult delViolation(@PathVariable Long id)
    {
        return toAjax(violationRecordMapper.deleteViolationById(id));
    }

    @PreAuthorize("@ss.hasPermi('thesis:blacklist:list')")
    @GetMapping("/blacklist/list")
    public AjaxResult blacklist(BlacklistEntry q)
    {
        return success(thesisBlacklistMapper.selectBlacklistList(q == null ? new BlacklistEntry() : q));
    }

    @PreAuthorize("@ss.hasPermi('thesis:blacklist:add')")
    @PostMapping("/blacklist")
    public AjaxResult addBlacklist(@RequestBody BlacklistEntry row)
    {
        row.setCreateBy(SecurityUtils.getUsername());
        if (row.getStatus() == null)
        {
            row.setStatus("0");
        }
        thesisBlacklistMapper.insertBlacklist(row);
        return success();
    }

    @PreAuthorize("@ss.hasPermi('thesis:blacklist:edit')")
    @PutMapping("/blacklist")
    public AjaxResult editBlacklist(@RequestBody BlacklistEntry row)
    {
        return toAjax(thesisBlacklistMapper.updateBlacklist(row));
    }

    @PreAuthorize("@ss.hasPermi('thesis:blacklist:edit')")
    @PutMapping("/blacklist/releaseByUser")
    public AjaxResult releaseBlacklistByUser(@RequestBody Map<String, Object> body)
    {
        if (body == null || body.get("userId") == null)
        {
            return error("userId 不能为空");
        }
        Long userId = Long.valueOf(body.get("userId").toString());
        String remark = body.get("remark") == null ? "管理员手动解除禁约" : body.get("remark").toString();
        BlacklistEntry query = new BlacklistEntry();
        query.setUserId(userId);
        query.setStatus("0");
        List<BlacklistEntry> activeRows = thesisBlacklistMapper.selectBlacklistList(query);
        int released = 0;
        for (BlacklistEntry row : activeRows)
        {
            row.setStatus("1");
            String oldRemark = row.getRemark();
            row.setRemark(StringUtils.isEmpty(oldRemark) ? remark : oldRemark + "；" + remark);
            released += thesisBlacklistMapper.updateBlacklist(row);
        }
        businessAuditMapper.insertAudit(userId, "解除禁约", "BLACKLIST", userId,
                remark + "，共解除 " + released + " 条黑名单记录");
        return success(released);
    }

    @PreAuthorize("@ss.hasPermi('thesis:repair:list')")
    @GetMapping("/repair/list")
    public AjaxResult repairList(RepairTicket q)
    {
        return success(repairTicketMapper.selectRepairList(q == null ? new RepairTicket() : q));
    }

    @PreAuthorize("@ss.hasPermi('thesis:repair:add')")
    @PostMapping("/repair")
    public AjaxResult addRepair(@RequestBody RepairTicket row)
    {
        if (row.getStatus() == null)
        {
            row.setStatus("待处理");
        }
        if (StringUtils.isNotEmpty(row.getFaultType()))
        {
            if (row.getFaultType().contains("网络"))
            {
                row.setAssignee("网络维保组");
            }
            else if (row.getFaultType().contains("桌椅"))
            {
                row.setAssignee("后勤维修组");
            }
            else
            {
                row.setAssignee("综合维修组");
            }
        }
        repairTicketMapper.insertRepair(row);
        businessAuditMapper.insertAudit(null, "新建报修工单", "REPAIR", row.getId(),
                row.getFaultType());
        return success(row.getId());
    }

    @PreAuthorize("@ss.hasPermi('thesis:repair:edit')")
    @PutMapping("/repair")
    public AjaxResult editRepair(@RequestBody RepairTicket row)
    {
        return toAjax(repairTicketMapper.updateRepair(row));
    }

    @PreAuthorize("@ss.hasPermi('thesis:repair:remove')")
    @DeleteMapping("/repair/{ids}")
    public AjaxResult delRepair(@PathVariable Long[] ids)
    {
        for (Long id : ids)
        {
            repairTicketMapper.deleteRepairById(id);
        }
        return success();
    }

    @PreAuthorize("@ss.hasPermi('thesis:cleaning:list')")
    @GetMapping("/cleaning/list")
    public AjaxResult cleaningList(CleaningPlan q)
    {
        return success(cleaningPlanMapper.selectCleaningList(q == null ? new CleaningPlan() : q));
    }

    @PreAuthorize("@ss.hasPermi('thesis:cleaning:edit')")
    @PutMapping("/cleaning")
    public AjaxResult updateCleaning(@RequestBody CleaningPlan row)
    {
        return toAjax(cleaningPlanMapper.updateCleaning(row));
    }

    @PreAuthorize("@ss.hasPermi('thesis:cleaning:add')")
    @PostMapping("/cleaning/generate")
    public AjaxResult generateCleaning()
    {
        List<Map<String, Object>> usage = thesisDashboardMapper.selectTodayRoomUsage();
        int added = 0;
        Date tomorrow = new Date(System.currentTimeMillis() + 86400000L);
        for (Map<String, Object> row : usage)
        {
            Number ts = (Number) row.get("totalSeats");
            Number rs = (Number) row.get("reservedToday");
            if (ts == null || ts.intValue() == 0)
            {
                continue;
            }
            double rate = rs == null ? 0 : rs.doubleValue() * 100.0 / ts.intValue();
            Number rid = (Number) row.get("roomId");
            if (rate >= 40 || (row.get("comfortScore") != null
                    && ((Number) row.get("comfortScore")).doubleValue() < 4.0))
            {
                CleaningPlan p = new CleaningPlan();
                p.setRoomId(rid.longValue());
                p.setPlanDate(tomorrow);
                p.setTimeSlot("早晨");
                p.setCleaner("待指派保洁");
                p.setStatus("待执行");
                p.setReason("系统依据使用率" + (int) rate + "%与舒适度生成");
                cleaningPlanMapper.insertCleaning(p);
                added++;
            }
        }
        return success("生成行数:" + added);
    }

    @PreAuthorize("@ss.hasPermi('thesis:dashboard:list')")
    @GetMapping("/dashboard/summary")
    public AjaxResult dashboard()
    {
        AjaxResult ajax = AjaxResult.success();
        ajax.put("roomUsage", thesisDashboardMapper.selectTodayRoomUsage());
        ajax.put("monthly", thesisDashboardMapper.selectMonthlyReservationCount());
        ajax.put("comfort", thesisDashboardMapper.selectComfortDistribution());
        ajax.put("studyRank", thesisDashboardMapper.selectStudyTimeRank());
        ajax.put("hourly", thesisDashboardMapper.selectHourlyReservationToday());
        ajax.put("alerts", thesisUsageAlertMapper.selectUnreadAlerts());
        return ajax;
    }

    @PreAuthorize("@ss.hasPermi('thesis:dashboard:export')")
    @GetMapping("/dashboard/exportData")
    public AjaxResult exportData()
    {
        return dashboard();
    }

    /** 全局数据 Excel 导出（与看板 summary 同源） */
    @PreAuthorize("@ss.hasPermi('thesis:dashboard:export')")
    @PostMapping("/dashboard/exportExcel")
    public void exportDashboardExcel(HttpServletResponse response)
    {
        List<ThesisGlobalExportRow> rows = new ArrayList<>();
        for (Map<String, Object> u : thesisDashboardMapper.selectTodayRoomUsage())
        {
            rows.add(new ThesisGlobalExportRow("今日座位负荷", String.valueOf(u.get("name")),
                    "预约占比="
                            + (u.get("totalSeats") != null && ((Number) u.get("totalSeats")).intValue() > 0
                                    ? Math.round((((Number) u.get("reservedToday")) == null ? 0
                                            : ((Number) u.get("reservedToday")).doubleValue())
                                            * 100.0 / ((Number) u.get("totalSeats")).intValue())
                                    : 0)
                            + "%;舒适=" + u.get("comfortScore")));
        }
        for (Map<String, Object> m : thesisDashboardMapper.selectMonthlyReservationCount())
        {
            rows.add(new ThesisGlobalExportRow("月度预约量", String.valueOf(m.get("ym")),
                    String.valueOf(m.get("cnt"))));
        }
        for (Map<String, Object> c : thesisDashboardMapper.selectComfortDistribution())
        {
            rows.add(new ThesisGlobalExportRow("舒适度分布", String.valueOf(c.get("name")),
                    String.valueOf(c.get("comfortScore"))));
        }
        for (Map<String, Object> s : thesisDashboardMapper.selectStudyTimeRank())
        {
            rows.add(new ThesisGlobalExportRow("学习时长排行", "userId=" + s.get("userId"),
                    String.valueOf(s.get("totalMinutes")) + "分钟"));
        }
        for (Map<String, Object> h : thesisDashboardMapper.selectHourlyReservationToday())
        {
            rows.add(new ThesisGlobalExportRow("今日热门时段", String.valueOf(h.get("hr")) + "时",
                    "预约数=" + h.get("cnt")));
        }
        ExcelUtil<ThesisGlobalExportRow> util = new ExcelUtil<ThesisGlobalExportRow>(ThesisGlobalExportRow.class);
        util.exportExcel(response, rows, "全局自习数据");
    }

    @PreAuthorize("@ss.hasPermi('thesis:suggest:list')")
    @GetMapping("/suggest")
    public AjaxResult suggest()
    {
        List<Map<String, Object>> usage = thesisDashboardMapper.selectTodayRoomUsage();
        List<String> lines = new ArrayList<>();
        for (Map<String, Object> row : usage)
        {
            String name = (String) row.get("name");
            Number ts = (Number) row.get("totalSeats");
            Number rs = (Number) row.get("reservedToday");
            if (ts != null && ts.intValue() > 0)
            {
                double rate = (rs == null ? 0 : rs.doubleValue()) / ts.intValue();
                if (rate >= 0.6)
                {
                    lines.add("建议对「" + name + "」开放备用区域或延长开放时间（当前负荷高）。");
                }
                else if (rate < 0.15)
                {
                    lines.add("「" + name + "」可用于承接其他区域分流或合并排班以节约成本。");
                }
            }
        }
        if (lines.isEmpty())
        {
            lines.add("当前各自习室负载相对均衡，可保持现状并持续观察舒适度反馈。");
        }
        Map<String, Object> res = new HashMap<>();
        res.put("lines", lines);
        return success(res);
    }

    @PreAuthorize("@ss.hasPermi('thesis:dashboard:list')")
    @PostMapping("/alert/read/{id}")
    public AjaxResult readAlert(@PathVariable Long id)
    {
        return toAjax(thesisUsageAlertMapper.markAlertRead(id));
    }

    @GetMapping("/audit/business")
    @PreAuthorize("@ss.hasPermi('thesis:dashboard:list')")
    public AjaxResult bizAudit(@RequestParam(required = false) String actionType,
            @RequestParam(required = false) Long userId,
            @RequestParam(required = false) String beginTime,
            @RequestParam(required = false) String endTime)
    {
        return success(businessAuditMapper.selectAuditList(actionType, userId, beginTime, endTime));
    }

    @PreAuthorize("@ss.hasPermi('thesis:feedback:list')")
    @GetMapping("/feedback/list")
    public TableDataInfo feedbackList(FeedbackRecord q)
    {
        startPage();
        List<FeedbackRecord> list = feedbackRecordService
                .selectFeedbackRecordList(q == null ? new FeedbackRecord() : q);
        return getDataTable(list);
    }

    @PreAuthorize("@ss.hasPermi('thesis:medal:list')")
    @GetMapping("/medal/list")
    public AjaxResult medalList()
    {
        return success(thesisStudyMapper.selectAllMedalDef());
    }

    @PreAuthorize("@ss.hasPermi('thesis:medal:add')")
    @PostMapping("/medal")
    public AjaxResult addMedal(@RequestBody Map<String, Object> body)
    {
        String code = (String) body.get("code");
        String name = (String) body.get("name");
        int need = body.get("needMinutes") == null ? 0 : Integer.parseInt(body.get("needMinutes").toString());
        String perk = body.get("perkDesc") == null ? "" : body.get("perkDesc").toString();
        int sort = body.get("sortOrder") == null ? 0 : Integer.parseInt(body.get("sortOrder").toString());
        return toAjax(thesisStudyMapper.insertMedalDef(code, name, need, perk, sort));
    }

    @PreAuthorize("@ss.hasPermi('thesis:medal:edit')")
    @PutMapping("/medal")
    public AjaxResult editMedal(@RequestBody Map<String, Object> body)
    {
        String code = (String) body.get("code");
        String name = (String) body.get("name");
        int need = body.get("needMinutes") == null ? 0 : Integer.parseInt(body.get("needMinutes").toString());
        String perk = body.get("perkDesc") == null ? "" : body.get("perkDesc").toString();
        int sort = body.get("sortOrder") == null ? 0 : Integer.parseInt(body.get("sortOrder").toString());
        return toAjax(thesisStudyMapper.updateMedalDef(code, name, need, perk, sort));
    }

    @PreAuthorize("@ss.hasPermi('thesis:medal:remove')")
    @DeleteMapping("/medal/{code}")
    public AjaxResult delMedal(@PathVariable String code)
    {
        return toAjax(thesisStudyMapper.deleteMedalDef(code));
    }
}
