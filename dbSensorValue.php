<?php

error_reporting(0);

$dbhost = "localhost";              // 資料庫位置
$dbuser = $_POST[username];          // 帳戶名稱
$dbpass = $_POST[password];          // 帳戶密碼
$dbname = $_POST[database];          // 資料庫名稱
$dbtable = $_POST[table];            // 資料表
$dbfield = $_POST[field];            // 資料欄位
$dbdatefield = $_POST[datefield];    // 時間欄位
$dbstartdate = $_POST[startdate];    // 開始時間
$type = $_POST[type];                // 動作

$db = new pdo("mysql:host=$dbhost;port=8889",$dbuser,$dbpass);  // 連結 MySQL
$db->query("set names 'utf8'");     // 1. 設定連接的編碼
$db->query("use `$dbname`");        // 2. 使用資料庫

if($type == "getRange" || $type == "getNew") {
    
    $dbenddate = $_POST[enddate];        // 結束時間
    $xml = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n";
    $xml .= "<article>\n";

    if($type == "getRange") {

        $sensorID = $_POST[sensorID];

        $sqlGetRangeString = "SELECT * FROM `$dbtable` WHERE (`$dbdatefield` >= '$dbstartdate' AND `$dbdatefield` <= '$dbenddate' AND `SensorID` = '$sensorID')";
        $index = 0;
        foreach ($db->query($sqlGetRangeString) as $key => $value) {

  //           <Rows>
  //            <Data time="2016-12-11 18:41:53.713" value="1279.800" />
  //            <Data time="2016-12-11 18:41:54.724" value="1279.800" />
  //            <Data time="2016-12-11 18:41:55.736" value="1280.200" />
  //            </Rows>
            
            $xml2 = simplexml_load_string($value["$dbfield"]);

            for($i = 0; $i < 60; $i++) {
                // echo $xml2->Data[i]->attributes()->time;
                $xml .= createXMLItem($value["ID"], $xml2->Data[$i]->attributes()->value, $xml2->Data[$i]->attributes()->time, $type);    
            }

            $index++;
        } 
    } else if($type == "getNew") {

        $sqlGetNewString = "SELECT * FROM `$dbtable` WHERE (`$dbdatefield` > '$dbstartdate')";
        $index = 0;
        foreach ($db->query($sqlGetNewString) as $key => $value) {
            // echo $index." ".$value["$dbdatefield"]." ".$value["$dbfield"]."~\n";
            $xml .= createXMLItem($value["ID"], $value["$dbfield"], $value["$dbdatefield"]);
            $index++;
        }
    }
     
    $xml .= "</article>\n";
     
    echo $xml;

} else if($type == "insert") {
    $insertdata = $_POST[insertdata];    
    $insertdate = $_POST[insertdate];                    // 動作
    $db->query("INSERT INTO `$dbtable` (`$dbfield`, `$dbdatefield`) VALUES ('$insertdata', '$insertdate')");
    echo "pass".$insertdata." ".$insertdate." ";
}else if($type == "updateDeviceToken") {
    //  Check if device is already exist.
    $insertdata = $_POST[insertdata];    
    $insertdate = $_POST[insertdate];
    //select * from deviceTokenList where UserName='$userName' and GroupName='$groupName'
    // $res = $db->query("SELECT * FROM deviceToken WHERE `DeviceToken`='$insertdata'");
    //$res = $db->query("SELECT * FROM deviceToken WHERE `DeviceToken`='$insertdata'");
    $row = $db->query("SELECT * FROM deviceToken WHERE `DeviceToken`='$insertdata'") -> fetch();


    

    if($row['id'] != ''){
                // $sql = "update DeviceTokenList set
                // DeviceToken = '$deviceToken',
                // UserName = '$userName',            
                // LastUpdateDateTime = now()
                // where UserName='$userName' and GroupName='$groupName'";
                $db->query("UPDATE `$dbtable` SET `UserName` = '$dbuser',`$dbdatefield` = '$insertdate' WHERE `$dbfield`='$insertdata'"); 
            }else{
                //  Upload DeviceToken
                $db->query("INSERT INTO `$dbtable` (`UserName`,`$dbfield`, `$dbdatefield`) VALUES ('$dbuser','$insertdata', '$insertdate')");
                echo "pass".$insertdata." ".$insertdate." ";
            }
}   else if($type == "insertAverage") {

        // get json in data
        $json = $_POST[data];

        // parse json to array
        $jsonParsed = json_decode($json);

        // get table name and setup value and date field
        $dbTable = $jsonParsed->dbAverageValueTable;

        // get value and date to insert DB
        foreach($jsonParsed->data as $mydata) {
            $insertData = $mydata->value;   // get value
            $insertDate = $mydata->date;    // get date
            // insert DB
            $db->query("INSERT INTO `$dbTable` (`$dbfield`, `$dbdatefield`) VALUES ('$insertData', '$insertDate')");
        }
        
        // return result
        echo '{"result" : "true"}';
}

//  创建XML单项
function createXMLItem($title_data, $content_data, $pubdate_data, $type) {

    if($type == "getRange") {
        $pubdate_data = substr_replace($pubdate_data, '', strlen($json)-4, 4);
        $pubdate_data = substr_replace($pubdate_data, '', 0, 11);
    }
    
    $item = "<item>\n";
    $item .= "<id>" . $title_data . "</id>\n";
    $item .= "<value>" . $content_data . "</value>\n";
    $item .= " <date>" . $pubdate_data . "</date>\n";
    $item .= "</item>\n";
 
    return $item;
}   





?>