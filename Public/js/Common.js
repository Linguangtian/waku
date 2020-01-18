/*
<script language='JavaScript' type='text/JavaScript'>
CheckBrowser();
</script>
*/

//检测客户端浏览器是否支持Cookie
function CookieEnable()
{
    var result=false;
    if(navigator.cookiesEnabled)
      return true;
    document.cookie = "testcookie=yes;";
    var cookieSet = document.cookie;
    if (cookieSet.indexOf("testcookie=yes") > -1)
      result=true;
    document.cookie = "";
    return result;
}
if(!CookieEnable())
{
    alert("对不起，您的浏览器的Cookie功能被禁用，请开启");
}

//检测浏览器版本
function CheckBrowser() {

  var app=navigator.appName;
  var verStr=navigator.appVersion;
  //alert(verStr);
 if(app.indexOf('Microsoft') != -1) {
     //if (verStr.indexOf('MSIE 3.0')!=-1 || verStr.indexOf('MSIE 4.0') != -1 || verStr.indexOf('MSIE 5.0') != -1 || verStr.indexOf('MSIE 5.1') != -1 || verStr.indexOf('MSIE 6.0') != -1)
     if (verStr.indexOf('MSIE 3.0') != -1 || verStr.indexOf('MSIE 4.0') != -1 || verStr.indexOf('MSIE 5.0') != -1 || verStr.indexOf('MSIE 5.1') != -1 || verStr.indexOf('MSIE 5.5') != -1)
         alert('溫馨提示：\n 您的浏覽器版本太低，可能會導致無法使用系統的部分功能。建議您使用 IE6.0 或以上版本。');
  }
}

//JS判断浏览器类型与版本
function getOs()  
{  
   var OsObject = "";  
   if(navigator.userAgent.indexOf("MSIE")>0) {  
        return "MSIE";  
   }  
   if(isFirefox=navigator.userAgent.indexOf("Firefox")>0){  
        return "Firefox";  
   }  
   if(isSafari=navigator.userAgent.indexOf("Safari")>0) {  
        return "Safari";  
   }   
   if(isCamino=navigator.userAgent.indexOf("Camino")>0){  
        return "Camino";  
   }  
   if(isMozilla=navigator.userAgent.indexOf("Gecko/")>0){  
        return "Gecko";  
   }
}

//小写转大写
function upperCase(x)
{
    var y=document.getElementById(x).value
    document.getElementById(x).value=y.toUpperCase()
}

//大写转小写
function lowerCase(x)
{
    var y=document.getElementById(x).value
    y=DBC2SBC(y)
    document.getElementById(x).value=y.toLowerCase()
}

//全角转半角
function DBC2SBC(str)
{
    var result="";
    for(var i=0;i<str.length;i++)
    {
        code = str.charCodeAt(i);//获取当前字符的unicode编码
        if (code >= 65281 && code <= 65373)//在这个unicode编码范围中的是所有的英文字母已经各种字符
        { 
            var d=str.charCodeAt(i)-65248;
            result += String.fromCharCode(d);//把全角字符的unicode编码转换为对应半角字符的unicode码
        }
        else if (code == 12288)//空格
        {
            var d=str.charCodeAt(i)-12288+32;
            result += String.fromCharCode(d);
        }
        else
        {
            result += str.charAt(i);
        }
    }
    return result;
}

//设置默认回车键
function SubmitKey(button)  
{   
    if (event.keyCode == 13)  
    {   
        event.returnValue = false;  
        document.all[button].click();
    }
}

//loading
function sAlert(str){
    var msgw,msgh,bordercolor;
    msgw = 300; //window width
    msgh = 50; //window height
    bordercolor="#075198";//window boder color     
    var sWidth,sHeight;
    sWidth="102%";
    sHeight="100%";
    var bgObj=document.createElement("div");
    bgObj.setAttribute('id','bgDiv');
    bgObj.style.position="absolute";
    bgObj.style.top="0";
    bgObj.style.background="#F4FBFF";
    bgObj.style.filter="progid:DXImageTransform.Microsoft.Alpha(style=3,opacity=25,finishOpacity=75";   
    bgObj.style.opacity="0.6";   
    bgObj.style.left="0";   
    bgObj.style.width=sWidth  
    bgObj.style.height=sHeight
    bgObj.style.zIndex = "10000";
    document.body.appendChild(bgObj);   
    var msgObj=document.createElement("div")   
    msgObj.setAttribute("id","msgDiv");   
    msgObj.setAttribute("align","center");   
    msgObj.style.background="white";   
    msgObj.style.border="1px solid " + bordercolor;   
    msgObj.style.position = "absolute";   
    msgObj.style.left = "50%";   
    msgObj.style.top = "50%";   
    msgObj.style.marginLeft = "-225px" ;   
    msgObj.style.marginTop = -75+document.documentElement.scrollTop+"px";   
    msgObj.style.width = msgw + "px";
    msgObj.style.height =msgh + "px";
    msgObj.style.textAlign = "center";   
    msgObj.style.lineHeight ="25px";   
    msgObj.style.zIndex = "10001";   
    var title=document.createElement("h4");
    document.body.appendChild(msgObj);   
    document.getElementById("msgDiv").appendChild(title); 
    var txt=document.createElement("p");
    txt.style.margin="1em 0"
    txt.setAttribute("id","msgTxt");
    txt.innerHTML="<table width='100%' height='100%' border='0' cellspacing='0' cellpadding='0'><tr><td align='center' valign='middle' scope='col'><img src='../images/loading.gif' width='16' height='16' align='absmiddle'>&nbsp;&nbsp;" + str + "</td></tr></table>";
    document.getElementById("msgDiv").appendChild(txt);
}