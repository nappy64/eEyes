<?php

error_reporting(0);

$dbhost = "localhost";             // 資料庫位置
$dbuser = $_GET[username];         // 帳戶名稱
$dbpass = $_GET[password];         // 帳戶密碼
$dbname = $_GET[database];         // 資料庫名稱
$type = $_GET[type];               // 動作

$appName = $_GET[appUserName];         // app user name
$appPassword = $_GET[appPassword]; // app user name

$db = new pdo("mysql:host=$dbhost;port=8889",$dbuser,$dbpass);  // 連結 MySQL
$db->query("set names 'utf8'");     // 1. 設定連接的編碼
$db->query("use `$dbname`");        // 2. 使用資料庫

if($type == "getSensorByUser") {
// http://localhost/dbinfoGet.php?username=root&password=root&database=eEyes&appUserName=user&appPassword=password&type=getSensorByUser

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
            $json = '{"result":"true","sensors":[';
            $sqlString = "SELECT * FROM `SensorInfo` WHERE (`UserID` = '$userID')";

            foreach ($db->query($sqlString) as $key => $value) {
                $sensorID = $value["SensorID"];
                $sensorName = $value["SensorName"];
                $hiAlarm = $value["HiAlarmValue"];
                $loAlarm = $value["LoAlarmValue"];
                $latitude = $value["Latitude"];
                $longitude = $value["Longitude"];
                $sensorTypeID = $value["SensorType"];

                // get seosnor info. by sensor type ID
                $sqlSensorTypeString = "SELECT * FROM `SensorType` WHERE (`ID` = '$sensorTypeID')";
                foreach ($db->query($sqlSensorTypeString) as $key => $value) {
                    $sensorType = $value["SensorType"];
                    $rangeHi = $value["RangeHi"];
                    $rangeLo = $value["RangeLo"];
                    $unit = $value["Unit"];
                    $description = $value["Description"];

                    // get Sensor Value Association Table Name by sensor ID
                    $sqlValueTypeString = "SELECT * FROM `SensorValueAssociation` WHERE (`SensorID` = '$sensorID')";
                    $dbRealValueTable = "";
                    $dbAverageValueTable = "";

                    foreach ($db->query($sqlValueTypeString) as $key => $value) {
                        if($value["ValueType"] == 1) {              // Real Value Table
                            $dbRealValueTable = $value["TableName"];
                        } else if($value["ValueType"] == 2) {       // Average Value Table
                            $dbAverageValueTable = $value["TableName"];
                        }
                    }

                    // combine JSON string
                    $json = $json.'{"sensorID":'.$sensorID.',"sensorName":"'.$sensorName .'","hiAlarm":'.$hiAlarm.',"loAlarm":'.$loAlarm .',"latitude":'.$latitude.',"longitude":'.$longitude.',"sensorType":"'.$sensorType.'","rangeHi":'.$rangeHi.',"rangeLo":'.$rangeLo.',"unit":"'.$unit.'","description":"'.$description.'","dbRealValueTable":"'.$dbRealValueTable.'","dbAverageValueTable":"'.$dbAverageValueTable.'"},';
                }
            }
            // remove ','
            $json = substr_replace($json, '', strlen($json)-1, 1);
            $json = $json.']}';

            echo $json;
        }
    }
    
} else if($type == "setHiLoAlarm") {

// http://localhost/dbInfoGet.php?username=root&password=root&database=eEyes&sensorID=2&type=setHiLoAlarm&data={"sensorID":1,"hiAlarm":56,"loAlarm":15}
// http://localhost/dbInfoGet.php?username=root&password=root&database=eEyes&sensorID=2&type=setHiLoAlarm&data={"sensorID":2,"hiAlarm":90,"loAlarm":50}
    $json = $_GET[data]; 
    // '{
    //  "sensorID":1,
    //  "hiAlarm":56,
    //  "loAlarm":15
    // }'; 

    // parse json to array
    $jsonParsed = json_decode($json);

    // get table name and setup value and date field
    $sensorID = $jsonParsed->sensorID;
    $hiAlarm = $jsonParsed->hiAlarm;
    $loAlarm = $jsonParsed->loAlarm;
    // update DB
    $db->query("UPDATE `SensorInfo` SET `HiAlarmValue`='$hiAlarm', `LoAlarmValue`='$loAlarm' WHERE `SensorID`='$sensorID'");
    // UPDATE `SensorInfo` SET `HiAlarmValue`='100',`LoAlarmValue`='0' WHERE `SensorID`='1'

            // echo $json;
            // echo $sensorID;
            // echo $hiAlarm;
            // echo $loAlarm;
}

?>