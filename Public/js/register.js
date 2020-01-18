function send_verfiycodeRegister(obj) {
    if (!$(obj).hasClass("disabled")) {
		alert(111111);
		exit;
        var username = $.trim($("#username").val()),
        phone = $.trim($("#phone").val()),
        telReg = !!phone.match(/^(0|86|17951)?(13[0-9]|15[012356789]|17[678]|18[0-9]|14[57])[0-9]{8}$/),
        _code = $.trim($("#exaCode").val());
        if (!/\d{4}/.test(_code)) return "" == username ? ($("#username").parent().addClass("form_group_error"), $("#tip_name").show().children().next().html("用户名不能为空"), void $("#exaCode").parent().removeClass("form_group_error")) : _code ? ($("#exaCode").parent().addClass("form_group_error"), void $("#tip_codeImg").show().children().next().html("验证码格式错误")) : ($("#username").parent().removeClass("form_group_error"), $("#exaCode").parent().addClass("form_group_error"), void $("#tip_codeImg").show().children().next().html("请输入验证码"));
        if ($("#exaCode").parent().removeClass("form_group_error"), $("#username").parent().removeClass("form_group_error"), $("#tip_codeImg").hide(), 1 != telReg) return "" == phone ? ($("#phone").parent().addClass("form_group_error"), void $("#tip_phone").show().children().next().html("请您填写手机号")) : ($("#phone").parent().addClass("form_group_error"), void $("#tip_phone").show().children().next().html("您的手机号格式有误，请核实"));
        var url = "/action/register.php?action=Code&tel=" + phone + "&code=" + _code + "&t=" + Math.random();
        $.ajax({
            type: "GET",
            data: {},
            url: url,
            beforeSend: function() {
                $(obj).addClass("disabled").text("发送中...")
            },
            success: function(data) {
                var status = data.status;
                return "y" == status ? (back_timeRegister(obj), $("#exa").parent().addClass("form_group_error"), $("#tip_code").show().children().next().html("短信验证码已发送，请查收"), void $("#send_call_verify").hide()) : ("exist" == data.data ? ($("#phone").parent().addClass("form_group_error"), $("#tip_phone").show().children().next().html(data.info)) : ($("#exaCode").parent().addClass("form_group_error"), $("#tip_codeImg").hide().children().next().html(data.info), alert(data.info)), void $(obj).removeClass("disabled").text("获取验证码"))
            },
            error: function() {
                $(obj).removeClass("disabled").text("获取验证码")
            },
            dataType: "json"
        }),
        $("#phone").parent().removeClass("form_group_error"),
        $("#username").parent().removeClass("form_group_error"),
        $("#tip_phone").hide().children().next().html("您的手机号格式有误，请核实")
    }
}
function back_timeRegister(o) {
    0 == wait ? ($(o).removeClass("disabled").text("获取验证码"), wait = 60, $("#send_call_verify").css("display", "block"), $("#send_call_verify") && $("#send_call_verify").empty(), $("#tip_code").length && $("#tip_code").css("display", "none"), $("#send_call_verify").length && $("#send_call_verify").html("验证码已发送到绑定手机，请注意查收！").show()) : ($(o).text("重新发送(" + wait + ")"), wait--, setTimeout(function() {
        back_timeRegister(o)
    },
    1e3))
}


