<?
$username = "ap104eeyes";		// 帳號
$password = "m1n2b3v4dd";		// 密碼
$mobile = $_POST[phoneNumber];	// 電話
$message = $_POST[message];	// 簡訊內容
$MSGData = "";

$msg = "username=".$username."&password=".$password."&mobile=".$mobile."&message=".urlencode($message);
$num = strlen($msg);		

// 打開 API 閘道
$fp = fsockopen ("api.twsms.com", 80);
if ($fp) {
	$MSGData .= "POST /smsSend.php HTTP/1.1\r\n";
	$MSGData .= "Host: api.twsms.com\r\n";
	$MSGData .= "Content-Length: ".$num."\r\n";
	$MSGData .= "Content-Type: application/x-www-form-urlencoded\r\n";
	$MSGData .= "Connection: Close\r\n\r\n";
	$MSGData .= $msg."\r\n";
	fputs ($fp, $MSGData);

	// 取出回傳值
	while (!feof($fp)) $Tmp.=fgets ($fp,128); 

	// 關閉閘道
	fclose ($fp);

	echo "傳送完成:".$Tmp;
} else {
	echo "您無法連接 TwSMS API Server";
}
?>
