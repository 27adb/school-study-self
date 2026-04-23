package com.room.reservation.domain.vo;

import com.room.common.annotation.Excel;

/**
 * 全局数据看板导出（Excel 行）
 */
public class ThesisGlobalExportRow
{
    @Excel(name = "区块")
    private String section;

    @Excel(name = "名称或指标")
    private String label;

    @Excel(name = "数值")
    private String value;

    public ThesisGlobalExportRow()
    {
    }

    public ThesisGlobalExportRow(String section, String label, String value)
    {
        this.section = section;
        this.label = label;
        this.value = value;
    }

    public String getSection()
    {
        return section;
    }

    public void setSection(String section)
    {
        this.section = section;
    }

    public String getLabel()
    {
        return label;
    }

    public void setLabel(String label)
    {
        this.label = label;
    }

    public String getValue()
    {
        return value;
    }

    public void setValue(String value)
    {
        this.value = value;
    }
}
