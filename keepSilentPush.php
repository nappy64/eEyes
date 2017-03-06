<?php
//error_reporting(0);
include 'db.php';
ignore_user_abort();//關掉瀏覽器，PHP腳本也可以繼續執行.
//set_time_limit(0);// 通過set_time_limit(0)可以讓程式無限制的執行下去 
$index = 0;
$sec = $_GET[sec];
$interval = $sec;// 每隔半小時運行
do{
    doSilentPush();
    sleep($interval);// 等待
    $index ++;
    date_default_timezone_set('Asia/Taipei');
    //取得年份/月/日 時:分:秒
    $datetime = date("Y-m-d H:i:s");
    echo $datetime."<br>";
    if ($index == 8) {
        break;
    }
}while(true);   



 function doSilentPush(){
    // Production mode
    //$certificateFile = 'output.pem';
    //$pushServer = 'ssl://gateway.push.apple.com:2195';
    //$feedbackServer = 'ssl://feedback.push.apple.com:2196';
     
    // Sandbox mode
    $certificateFile = 'output.pem';
    $pushServer = 'ssl://gateway.sandbox.push.apple.com:2195';
    $feedbackServer = 'ssl://feedback.sandbox.push.apple.com:2196';
     
    // push notification
    $streamContext = stream_context_create();           
    stream_context_set_option($streamContext, 'ssl', 'local_cert', $certificateFile);
    $fp = stream_socket_client(
        $pushServer, 
        $error, 
        $errorStr, 
        100, 
        STREAM_CLIENT_CONNECT|STREAM_CLIENT_PERSISTENT, 
        $streamContext
    );
     
    // make payload
    $payloadObject = array(
        'aps' => array(
            //'alert' => 'Server Time:'.date('Y-m-d H:i:s'),
            //'alert' => 'Sensor偵測到異常溫度',
            //'sound' => 'default',
            //'badge' => 1
            'content-available' => 1
     
        ),
         //'custom_key' => 'custom_value'
         'acme1' => 'bar',
         'acme2' => 42
    );
    $payload = json_encode($payloadObject);
     
    $deviceToken = '38880e1fe3cb9cc2b5f7f2af17ec2676ba79b69fc0d53efa69d34379de2991d6';
    $expire = time() + 3600;
    $id = time();
     
    if ($expire) {
        // Enhanced mode
        $binary  = pack('CNNnH*n', 1, $id, $expire, 32, $deviceToken, strlen($payload)).$payload;
    } else {
        // Simple mode
        $binary  = pack('CnH*n', 0, 32, $deviceToken, strlen($payload)).$payload;
    }
    $result = fwrite($fp, $binary);
    fclose($fp);
 }
?>