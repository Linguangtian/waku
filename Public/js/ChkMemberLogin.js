if (top.location !== self.location) {
    top.location = self.location;
}
CheckBrowser();

$(document).ready(function() {

    $("#Button1").click(function() {
        return checkInput();
    });
});

function checkInput() {

    if (!checkUserName()) {
        alert("請輸入玩家編號！");
        $("#txtUserName").focus();
        return false;
    }
//    if (!istrue() && !istrue2()) {
//        alert("請輸入正确的玩家編號！");
//        $("#UserName").focus();
//        return false;
//    }

    if (!checkUserPass()) { alert("請輸入玩家密碼！"); $("#txtUserPass").focus(); return false; }

    $("#Button1").hide();
    $("#showText").html('<input type="button" value="登陸中…" class="buttom1" />')
    return true;
}

function checkUserName() {
    var strUserName = $("#txtUserName").val();
    if (strUserName == "" || strUserName == "UserName" || strUserName == "玩家编号" || strUserName == "玩家編號") {
        return false;
    }
    else {
        return true;
    }
}
function istrue() {
    var strUserName = $("#txtUserName").val();
    var reg = /^[fc|FC]+[0-9]{6}$/;
    return reg.test(strUserName);
}
function istrue2() {
    var strUserName = $("#txtUserName").val();
    var reg = /^[fc|FC]+[0-9]{8}$/;
    return reg.test(strUserName);
}
function checkUserPass() {
    if ($("#txtUserPass").val() == "" || $("#txtUserPass").val() == "******") {
        return false;
    }
    return true;
}


function Clear_Txt(_Txt_Val, _Txt) {
    var txt_value = $("#" + _Txt_Val).val();
    if (txt_value == _Txt) { $("#" + _Txt_Val).val(""); }
}

function Restore_Txt(_Txt_Val, _Txt) {
    var txt_value = $("#" + _Txt_Val).val();
    if (txt_value == "") { $("#" + _Txt_Val).val(_Txt); }
}

document.onkeydown = mykeydown;
function mykeydown() {
    if (event.keyCode == 116) {
        window.event.keyCode = 0;
        return false;
    }
}