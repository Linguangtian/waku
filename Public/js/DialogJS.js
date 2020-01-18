//-------------Member DialogJS
//According to the size of the screen shows two layer---show btnCancel
function showMsgFloat(msg) {
    var range = getRange();
    $$('divBox').style.width = range.width + "px";
    $$('divBox').style.height = range.height + "px";
    $$('divBox').style.display = "block";
    document.getElementById("divMsg").style.display = "";
    document.getElementById("showbtnCancel").style.display = "";
    document.getElementById("divShowMsg").innerHTML = msg;
}
//According to the size of the screen shows two layer----no show btnCancel
function showMsgFloat2(msg) {
    var range = getRange();
    $$('divBox').style.width = range.width + "px";
    $$('divBox').style.height = range.height + "px";
    $$('divBox').style.display = "block";
    document.getElementById("divMsg").style.display = "";
    document.getElementById("showbtnCancel").style.display = "none";
    document.getElementById("divShowMsg").innerHTML = msg;
}
//hidden layer
function ShowNo() {
    document.getElementById("divBox").style.display = "none";
    document.getElementById("divMsg").style.display = "none";
}
//$$--自定义函数，不能使用$，否则会与jquery冲突，导致下拉菜单失效！
function $$(id) {
    return (document.getElementById) ? document.getElementById(id) : document.all[id];
}
//Get the size of the screen
function getRange() {
    var top = document.body.scrollTop;
    var left = document.body.scrollLeft;
    var height = document.body.clientHeight;
    var width = document.body.clientWidth;

    if (top == 0 && left == 0 && height == 0 && width == 0) {
        top = document.documentElement.scrollTop;
        left = document.documentElement.scrollLeft;
        height = document.documentElement.clientHeight;
        width = document.documentElement.clientWidth;
    }
    return { top: top, left: left, height: height, width: width };
}
//iframe auto heidth
$(function () {
    $("#frmX").load(function () {
        $(this).height($(this).contents().find("#content").height() + 40);
    });
});

//show msg
function startRequest() {
    $.ajax({
        type: "get",
        url: "/WS/CheckMsg.ashx",
        //dataType: 'text',
        data: "action=chkMsg&username=" + $("#<%=lblUserName.ClientID%>").text(), //CheckMsg.ashx?action=chkMsg&username=
        success: function (msg) {
            //alert(msg);//msg is return values
            if (msg != "0") {
                showMsgFloat2("<div class=NewMsgBox><img src='/App_Themes/new2013/Images/newmsg.png'> <a href=MyMsg.aspx>尊敬的玩家，您好！您當前有" + msg + "條新消息！點擊查看！</a> <input type=\"button\" value=\"立即查看\" class=\"buttom\" onclick=\"window.location='MyMsg.aspx'\" /></div>");
            }
        }
    });
}