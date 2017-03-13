<?php

error_reporting(0);

$dbhost = "localhost";             // 資料庫位置
$dbuser = $_POST[username];         // 帳戶名稱
$dbpass = $_POST[password];         // 帳戶密碼
$dbname = $_POST[database];         // 資料庫名稱
$type = $_POST[type];               // 動作

$appName = $_POST[appUserName];         // app user name
$appPassword = $_POST[appPassword]; // app user name

$db = new pdo("mysql:host=$dbhost;port=8889",$dbuser,$dbpass);  // 連結 MySQL
$db->query("set names 'utf8'");     // 1. 設定連接的編碼
$db->query("use `$dbname`");        // 2. 使用資料庫

if($type == "getAlarmByUser") {
// http://localhost/dbAlarmInfoGet.php?username=root&password=root&database=eEyes&appUserName=user&appPassword=password&type=getAlarmByUser

    // get UserID by user name
    $userID = "";
    $sqlString = "SELECT * FROM `UserInfo` WHERE (`Username` = '$appName')";

    foreach ($db->query($sqlString) as $key => $value) {
        $userID = $value["UserID"];
    }

    // if username not existed
    if($userID == "") {
        echo '{"result" : "false","errorCode":"USER_NAME_NOT_EXIST"}';
    } else {

        // get UserID by password
        $sqlString = "SELECT * FROM `UserInfo` WHERE (`UserID` = '$userID' and `Password` = '$appPassword')";
        $userID = "";
 
        foreach ($db->query($sqlString) as $key => $value) {
            $userID = $value["UserID"];
        }

        // if password incorrect
        if($userID == "") {
            echo '{"result" : "false","errorCode":"USER_PASSWORD_INCORRECT"}';
        } else {
            $json = '{"result":"true","alarms":[';
            $sqlString = "SELECT * FROM `AlarmRecord` ORDER BY `AlarmID` DESC";

            foreach ($db->query($sqlString) as $key => $value) {
                $sensorID = $value["SensorID"];
                $date = $value["DateTime"];
                $alarmValue = $value["AlarmValue"];
                $alarmType = $value["AlarmType"];

                // combine JSON string
                $json = $json.'{"sensorID":'.$sensorID.',"date":"'.$date .'","alarmValue":'.$alarmValue.',"alarmType":"'.$alarmType.'"},';
            }
            // remove ','
            $json = substr_replace($json, '', strlen($json)-1, 1);
            $json = $json.']}';

            echo $json;
        }
    }
    
}

?>