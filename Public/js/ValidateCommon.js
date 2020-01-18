/*
<script type="text/javascript" src="/Js/jquery.js"></script>
<script type="text/javascript" src="/Js/ValidateCommon.js"></script>
*/

function hintMessage(hintObj, error, message) {
    //É¾³ýÑùÊ½
    if (error == "error") {
        $("#" + hintObj + "").removeClass("rightTips");
        $("#" + hintObj + "").removeClass("infoTips");
        $("#" + hintObj + "").addClass("wrongTips");
    } else if (error == "right") {
        $("#" + hintObj + "").removeClass("wrongTips");
        $("#" + hintObj + "").removeClass("infoTips");
        $("#" + hintObj + "").addClass("rightTips");
    } else if (error == "info") {
        $("#" + hintObj + "").removeClass("wrongTips");
        $("#" + hintObj + "").addClass("infoTips");
        $("#" + hintObj + "").removeClass("rightTips");
    }
    $("#" + hintObj + "").html(message);
}