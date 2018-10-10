package com.zcreate.tree.controller;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.zcreate.tree.dao.MemberMapper;
import com.zcreate.tree.pojo.Member;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller

@RequestMapping("/")
public class MemberController {
    private static Logger log = LoggerFactory.getLogger(MemberController.class);
    @Autowired
    private MemberMapper memberMapper;
    private Gson gson = new GsonBuilder().serializeNulls().setDateFormat("yyyy-MM-dd HH:mm").create();

    @ResponseBody
    @RequestMapping(value = "/listMember", method = RequestMethod.GET, produces = "text/html;charset=UTF-8")
    public String listMember(@RequestParam(value = "memberNo", required = false) String memberNo,
                             @RequestParam(value = "phone", required = false) String phone,
                             @RequestParam(value = "idCard", required = false) String idCard,
                             @RequestParam(value = "parentNo", required = false) String parentNo,
                             @RequestParam(value = "parentNo2", required = false) String parentNo2,
                             @RequestParam(value = "realName", required = false) String realName,
                             @RequestParam(value = "bankCard", required = false) String bankCard,
                             @RequestParam(value = "threeThirty", required = false) Boolean threeThirty,
                             @RequestParam(value = "search[value]", required = false) String searchValue,
                             @RequestParam(value = "draw", required = false) Integer draw,
                             @RequestParam(value = "start", required = false) Integer start,
                             @RequestParam(value = "length", required = false, defaultValue = "100") Integer length
    ) {
      /*  log.debug("searchValue=" + searchValue);
        log.debug("threeThirty=" + threeThirty);
        log.debug("memberNo={}", memberNo);*/
        Map<String, Object> param = new HashMap<>();
        param.put("memberNo", memberNo);
        param.put("phone", phone);
        param.put("idCard", idCard);
        param.put("realName", realName);
        param.put("bankCard", bankCard);
        param.put("threeThirty", threeThirty);
        param.put("parentNo", parentNo);
        param.put("parentNo2", parentNo2);
        param.put("start", start);
        if (parentNo == null)
            param.put("length", length);
        List<Member> members = memberMapper.selectMember(param);
        int recordCount = memberMapper.getMemberCount(param);

        Map<String, Object> result = new HashMap<>();
        result.put("data", members);
        result.put("draw", draw);//draw——number类型——请求次数计数器，每次发送给服务器后原封返回，因为请求是异步的，为了确保每次请求都能对应到服务器返回到的数据。
        result.put("recordsTotal", recordCount);
        result.put("recordsFiltered", recordCount);
        return gson.toJson(result);
    }

    @ResponseBody
    @RequestMapping(value = "/memberTree", method = RequestMethod.GET, produces = "text/html;charset=UTF-8")
    public String memberTree(@RequestParam(value = "memberNo", required = false) String memberNo) {
        Map<String, Object> param = new HashMap<>();
        param.put("parentNo", memberNo);
        List<Member> members = memberMapper.selectMember(param);

        Map<String, Object> result = new HashMap<>();
        Map<String, Object> obj = new HashMap<>();
        //List<Map<String, Object>> oj = new List<HashMap<>>();
        for (Member member : members) {
            Map<String, Object> item = new HashMap<>();
            String baseText = "层级:" + member.getLevel() + "，" + ("".equals(member.getRealName()) ? member.getMemberNo() : member.getRealName()) + "，手机：" + member.getPhone();
            if (member.getDirectCount() > 0) {
                baseText += "，下级深度：" + member.getChildDepth() + "，下级总数：" + member.getChildTotal();
                item.put("type", "folder");
            } else {
                baseText = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i class='ace-icon fa fa-user'></i>&nbsp;" + baseText;
                item.put("type", "item");
            }

            item.put("text", baseText);

            Map<String, Object> addParam = new HashMap<>();
            addParam.put("children", member.getDirectCount() > 0 ? true : null);
            addParam.put("id", member.getMemberNo());
            //addParam.put("info", member.getMemberInfo());

            item.put("additionalParameters", addParam);

            obj.put("node_" + member.getMemberNo(), item);
        }

        result.put("data", obj);
        result.put("status", "OK");
        return gson.toJson(result);
    }

    @ResponseBody
    @RequestMapping(value = "/memberZTree", method = RequestMethod.POST, produces = "text/html;charset=UTF-8")
    public String memberZTree(@RequestParam(value = "id", required = false) String memberNo) {
        Map<String, Object> param = new HashMap<>();
        param.put("parentNo", memberNo);
        List<Member> members = memberMapper.selectMember(param);

        //Map<String, Object> result = new HashMap<>();
        //Map<String, Object> obj = new HashMap<>();
        List<Map<String, Object>> list = new ArrayList<>();
        for (Member member : members) {
            Map<String, Object> item = new HashMap<>();
            String value = member.getMemberNo() + "，姓名：" + (member.getRealName() != null ? member.getRealName() : "") + "，手机：" + member.getPhone();
            if (member.getDirectCount() > 0)// item.put("name", member.getRealName() + "，下级深度：" + member.getChildDepth() + "，下级总数：" + member.getChildTotal());
                value += "，下级深度：" + member.getChildDepth() + "，下级总数：" + member.getChildTotal();

            item.put("name", value);
            item.put("isParent", member.getDirectCount() > 0);
            item.put("id", member.getMemberNo());

            list.add(item);
        }

        return gson.toJson(list);
    }

    @ResponseBody
    @RequestMapping(value = "/getPurseType", method = RequestMethod.GET, produces = "text/html;charset=UTF-8")
    public String getPurseType(@RequestParam(value = "memberNo") String memberNo) {
        Map<String, Object> param = new HashMap<>();
        param.put("memberNo", memberNo);
        List<Map<String, Object>> purseTypes = memberMapper.selectPurseType(param);

        return gson.toJson(purseTypes);
    }

    @ResponseBody
    @RequestMapping(value = "/getReasonCode", method = RequestMethod.GET, produces = "text/html;charset=UTF-8")
    public String getReasonCode(@RequestParam(value = "memberNo") String memberNo,
                                @RequestParam(value = "purseType", required = false) Integer purseTypeID) {
        Map<String, Object> param = new HashMap<>();
        param.put("memberNo", memberNo);
        param.put("purseType", purseTypeID);
        List<Map<String, Object>> purseTypes = memberMapper.selectReasonCode(param);

        return gson.toJson(purseTypes);
    }

    @RequestMapping(value = "/member", method = RequestMethod.GET)
    public String member(@RequestParam(value = "searchKey", required = false) String searchKey, ModelMap model) {
        log.debug("url = member");

        return "/member";
    }

    @RequestMapping(value = "/memberInfo", method = RequestMethod.GET)
    public String memberInfo(@RequestParam(value = "memberNo", required = false) String memberNo, ModelMap model) {
        log.debug("url = memberInfo");
        Map<String, Object> param = new HashMap<>();
        param.put("memberNo", memberNo);

        List<Member> members = memberMapper.selectMember(param);
        if (members.size() >= 1)
            model.addAttribute("member", members.get(0));


        return "/memberInfo";
    }

    @ResponseBody
    @RequestMapping(value = "/memberIntegral", method = RequestMethod.GET, produces = "text/html;charset=UTF-8")
    public String memberIntegral(@RequestParam(value = "memberNo", required = false) Integer memberNo,
                                 @RequestParam(value = "purseType", required = false) Integer purseType,
                                 @RequestParam(value = "purseName", required = false) String purseName,
                                 @RequestParam(value = "reasonCode", required = false) Integer reasonCode,
                                 @RequestParam(value = "draw", required = false) Integer draw,
                                 @RequestParam(value = "start", required = false) Integer start,
                                 @RequestParam(value = "length", required = false, defaultValue = "100") Integer length) {
        Map<String, Object> param = new HashMap<>();
        param.put("memberNo", memberNo);
        param.put("purseType", purseType);
        param.put("purseName", purseName);
        param.put("reasonCode", reasonCode);
        param.put("start", start);
        param.put("length", length);

        //model.addAttribute("integral", memberMapper.selectMemberIntegral(param));
        int recordCount = memberMapper.selectMemberIntegralCount(param);
        Map<String, Object> result = new HashMap<>();
        result.put("data", memberMapper.selectMemberIntegral(param));
        result.put("draw", draw);/*draw——number类型——请求次数计数器，每次发送给服务器后原封返回，因为请求是异步的，为了确保每次请求都能对应到服务器返回到的数据。*/
        result.put("recordsTotal", recordCount);
        result.put("recordsFiltered", recordCount);
        return gson.toJson(result);
        //return "/memberIntegral";
    }

    @ResponseBody
    @RequestMapping(value = "/memberWithdraw", method = RequestMethod.GET, produces = "text/html;charset=UTF-8")
    public String memberWithdraw(@RequestParam(value = "memberNo", required = false) String memberNo,
                                 @RequestParam(value = "bankcard", required = false) String bankcard,
                                 @RequestParam(value = "draw", required = false) Integer draw,
                                 @RequestParam(value = "start", required = false) Integer start,
                                 @RequestParam(value = "length", required = false, defaultValue = "100") Integer length) {
        Map<String, Object> param = new HashMap<>();
        param.put("memberNo", memberNo);
        param.put("bankcard", bankcard);
        param.put("start", start);
        param.put("length", length);

        //int recordCount = memberMapper.selectWithdrawCount(param);
        List<Map<String, Object>> withdraws = memberMapper.selectWithdraw(param);
       /* Double total = 0.0;
        for (Map map : withdraws) total += map.get("status") == "成功" ? (Double) map.get("amount") : 0.0;*/
        Map<String, Object> result = new HashMap<>();
        result.put("data", withdraws);
        //result.put("total", total);
        result.put("draw", draw);/*draw——number类型——请求次数计数器，每次发送给服务器后原封返回，因为请求是异步的，为了确保每次请求都能对应到服务器返回到的数据。*/
        /*result.put("recordsTotal", recordCount);
        result.put("recordsFiltered", recordCount);*/
        return gson.toJson(result);
    }

    @RequestMapping(value = "/memberInfo2", method = RequestMethod.GET)
    public String memberInfo2(@RequestParam(value = "memberNo", required = false) String memberNo, ModelMap model) {
        log.debug("url = memberInfo");
        Map<String, Object> param = new HashMap<>();
        param.put("memberNo", memberNo);
        List<Member> members = memberMapper.selectMember(param);
        if (members.size() >= 1)
            model.addAttribute("member", members.get(0));


        return "/memberInfo2";
    }

    @ResponseBody
    @RequestMapping(value = "/getParent", method = RequestMethod.GET, produces = "text/html;charset=UTF-8")
    public String getParent(@RequestParam(value = "memberNo") String memberNo,
                            @RequestParam(value = "maxlevel", required = false, defaultValue = "30") Integer maxlevel) {
        HashMap<String, Object> param = new HashMap<>();
        param.put("memberNo", memberNo);
        param.put("maxlevel", maxlevel);
        List<Map<String, Object>> recordCounts = memberMapper.selectParent(param);

        Map<String, Object> result = new HashMap<>();
        result.put("data", recordCounts);
        result.put("recordsTotal", recordCounts.size());
        result.put("recordsFiltered", recordCounts.size());
        return gson.toJson(result);
    }
}
