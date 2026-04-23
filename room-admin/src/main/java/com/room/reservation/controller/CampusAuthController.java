package com.room.reservation.controller;

import java.util.Calendar;
import java.util.Date;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.room.common.annotation.Anonymous;
import com.room.common.constant.Constants;
import com.room.common.constant.UserConstants;
import com.room.common.core.domain.AjaxResult;
import com.room.common.core.domain.entity.SysUser;
import com.room.common.core.domain.model.LoginUser;
import com.room.common.core.text.Convert;
import com.room.common.utils.DateUtils;
import com.room.common.utils.SecurityUtils;
import com.room.common.utils.StringUtils;
import com.room.framework.web.service.SysPermissionService;
import com.room.framework.web.service.TokenService;
import com.room.framework.web.service.UserDetailsServiceImpl;
import com.room.reservation.domain.CampusVerifyCode;
import com.room.reservation.mapper.CampusVerifyCodeMapper;
import com.room.system.service.ISysConfigService;
import com.room.system.service.ISysUserService;

/**
 * 校园账号 + 短信验证码（演示模式 config campus.sms.mock=true 固定 123456）
 */
@Anonymous
@RestController
@RequestMapping("/campus")
public class CampusAuthController
{
    @Autowired
    private CampusVerifyCodeMapper campusVerifyCodeMapper;

    @Autowired
    private ISysConfigService configService;

    @Autowired
    private ISysUserService userService;

    @Autowired
    private UserDetailsServiceImpl userDetailsServiceImpl;

    @Autowired
    private TokenService tokenService;

    @Autowired
    private SysPermissionService permissionService;

    @PostMapping("/sendCode")
    public AjaxResult sendCode(@RequestBody Map<String, String> body)
    {
        String campus = body.get("campusAccount");
        if (StringUtils.isEmpty(campus))
        {
            return AjaxResult.error("请输入校园账号/学号");
        }
        campusVerifyCodeMapper.deleteExpired();
        String mock = configService.selectConfigByKey("campus.sms.mock");
        String code;
        if ("true".equalsIgnoreCase(StringUtils.trim(mock)))
        {
            code = "123456";
        }
        else
        {
            code = String.valueOf(100000 + (int) (Math.random() * 900000));
        }
        CampusVerifyCode row = new CampusVerifyCode();
        row.setCampusAccount(campus);
        row.setCode(code);
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.MINUTE, 5);
        row.setExpireTime(cal.getTime());
        campusVerifyCodeMapper.insertCampusVerifyCode(row);
        AjaxResult ok = AjaxResult.success();
        if ("true".equalsIgnoreCase(StringUtils.trim(mock)))
        {
            ok.put("demoCode", code);
            ok.put("msg", "演示模式验证码（勿用于生产）");
        }
        return ok;
    }

    /**
     * 学号 + 短信码登录（用户须已注册，用户名为学号）
     */
    @PostMapping("/loginBySms")
    public AjaxResult loginBySms(@RequestBody Map<String, String> body)
    {
        String campus = body.get("campusAccount");
        String sms = body.get("smsCode");
        if (StringUtils.isEmpty(campus) || StringUtils.isEmpty(sms))
        {
            return AjaxResult.error("学号与验证码不能为空");
        }
        CampusVerifyCode latest = campusVerifyCodeMapper.selectLatest(campus);
        if (latest == null || latest.getExpireTime().before(new Date()))
        {
            return AjaxResult.error("验证码已失效，请重新获取");
        }
        if (!sms.equals(latest.getCode()))
        {
            return AjaxResult.error("验证码错误");
        }
        SysUser user = userService.selectUserByUserName(campus);
        if (user == null)
        {
            return AjaxResult.error("账号不存在，请先使用注册接口");
        }
        // 手动构建 LoginUser 对象，避免方法签名不匹配
        LoginUser loginUser = new LoginUser(user.getUserId(), user.getDeptId(), user, permissionService.getMenuPermission(user));
        String token = tokenService.createToken(loginUser);
        AjaxResult ajax = AjaxResult.success();
        ajax.put(Constants.TOKEN, token);
        return ajax;
    }

    /**
     * 学号 + 短信验证码注册（须开启 sys.account.registerUser），默认角色见配置 campus.register.roleId（默认 2）
     */
    @PostMapping("/registerBySms")
    public AjaxResult registerBySms(@RequestBody Map<String, String> body)
    {
        if (!"true".equalsIgnoreCase(StringUtils.trim(configService.selectConfigByKey("sys.account.registerUser"))))
        {
            return AjaxResult.error("当前系统没有开启注册功能");
        }
        String campus = body.get("campusAccount");
        String sms = body.get("smsCode");
        String password = body.get("password");
        String nickName = body.get("nickName");
        if (StringUtils.isEmpty(campus) || StringUtils.isEmpty(sms) || StringUtils.isEmpty(password))
        {
            return AjaxResult.error("学号、验证码与登录密码不能为空");
        }
        if (password.length() < UserConstants.PASSWORD_MIN_LENGTH || password.length() > UserConstants.PASSWORD_MAX_LENGTH)
        {
            return AjaxResult.error("密码长度必须在5到20个字符之间");
        }
        CampusVerifyCode latest = campusVerifyCodeMapper.selectLatest(campus);
        if (latest == null || latest.getExpireTime().before(new Date()))
        {
            return AjaxResult.error("验证码已失效，请重新获取");
        }
        if (!sms.equals(latest.getCode()))
        {
            return AjaxResult.error("验证码错误");
        }
        if (userService.selectUserByUserName(campus) != null)
        {
            return AjaxResult.error("该学号已注册，请直接登录");
        }
        SysUser user = new SysUser();
        user.setUserName(campus);
        user.setNickName(StringUtils.isNotEmpty(nickName) ? nickName : campus);
        user.setPwdUpdateDate(DateUtils.getNowDate());
        user.setPassword(SecurityUtils.encryptPassword(password));
        user.setStatus("0");
        Long roleId = Convert.toLong(configService.selectConfigByKey("campus.register.roleId"), 2L);
        user.setRoleIds(new Long[] { roleId });
        userService.insertUser(user);
        return AjaxResult.success();
    }
}
