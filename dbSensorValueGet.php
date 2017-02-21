<?php

// http://localhost/dbSensorValueGet.php?username=root&password=root&database=eEyes&table=SensorRawData&field=RawValue&sensorID=2&datefield=StartDate&startdate=2017-01-25%2021:50:00&enddate=2017-01-25%2021:59:00&type=getRange

// error_reporting(0);

$dbhost = "localhost";              // 資料庫位置
$dbuser = $_GET[username];          // 帳戶名稱
$dbpass = $_GET[password];          // 帳戶密碼
$dbname = $_GET[database];          // 資料庫名稱
$dbtable = $_GET[table];            // 資料表
$dbfield = $_GET[field];            // 資料欄位
$dbdatefield = $_GET[datefield];    // 時間欄位
$dbstartdate = $_GET[startdate];    // 開始時間
$type = $_GET[type];                // 動作

$db = new pdo("mysql:host=$dbhost;port=8889",$dbuser,$dbpass);  // 連結 MySQL
$db->query("set names 'utf8'");     // 1. 設定連接的編碼
$db->query("use `$dbname`");        // 2. 使用資料庫

if($type == "getRange" || $type == "getNew") {
    
    $dbenddate = $_GET[enddate];        // 結束時間
    $xml = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n";
    $xml .= "<article>\n";

    if($type == "getRange") {

        $sensorID = $_GET[sensorID];
        $sqlGetRangeString = "SELECT * FROM `$dbtable` WHERE (`$dbdatefield` >= '$dbstartdate' AND `$dbdatefield` <= '$dbenddate' AND `SensorID` = '$sensorID')";

        $index = 0;
        foreach ($db->query($sqlGetRangeString) as $key => $value) {
            $xml2 = simplexml_load_string($value["$dbfield"]);

            for($i = 0; $i < 60; $i++) {
                // echo $xml2->Data[i]->attributes()->time;
                $xml .= createXMLItem($value["ID"], $xml2->Data[$i]->attributes()->value, $xml2->Data[$i]->attributes()->time);    
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
        $insertdata = $_GET[insertdata];    
        $insertdate = $_GET[insertdate];
        $db->query("INSERT INTO `$dbtable` (`$dbfield`, `$dbdatefield`) VALUES ('$insertdata', '$insertdate')");
        echo "pass".$insertdata." ".$insertdate." ";
    } else if($type == "insertAverage") {
// http://localhost/dbSensorValueGet.php?username=root&password=root&database=eEyes&table=SensorRawData&field=Value&sensorID=2&datefield=Date&startdate=2017-01-25%2021:50:00&enddate=2017-01-25%2021:59:00&type=insertAverage&data={%20%22dbAverageValueTable%22:%22AverageID10001%22,%20%22dataCount%22:6,%20%22data%22:%20[%20{%22date%22:%222017-02-21%2010:00:00%22,%22value%22:23.4},%20{%22date%22:%222017-02-21%2010:01:00%22,%22value%22:23.4},%20{%22date%22:%222017-02-21%2010:02:00%22,%22value%22:23.4},%20{%22date%22:%222017-02-21%2010:03:00%22,%22value%22:23.4},%20{%22date%22:%222017-02-21%2010:04:00%22,%22value%22:23.4},%20{%22date%22:%222017-02-21%2010:05:00%22,%22value%22:23.4}%20]%20}
    $json = $_GET[data]; 
    // '{
    //  "dbAverageValueTable":"AverageID10001",
    //  "dataCount":6,
    //  "data":
    //  [
    //     {"date":"2017-02-21 10:00:00","value":23.4},
    //     {"date":"2017-02-21 10:01:00","value":23.4},
    //     {"date":"2017-02-21 10:02:00","value":23.4},
    //     {"date":"2017-02-21 10:03:00","value":23.4},
    //     {"date":"2017-02-21 10:04:00","value":23.4},
    //     {"date":"2017-02-21 10:05:00","value":23.4}
    //  ]
    // }'; 

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

            // echo $dbTable;
            // echo $dbfield;
            // echo $insertData;
            // echo $dbdatefield;
            // echo $insertDate;
        }

}

//  创建XML单项
function createXMLItem($title_data, $content_data, $pubdate_data) {
    $item = "<item>\n";
    $item .= "<id>" . $title_data . "</id>\n";
    $item .= "<value>" . $content_data . "</value>\n";
    $item .= " <date>" . $pubdate_data . "</date>\n";
    $item .= "</item>\n";
 
    return $item;
}   





?>