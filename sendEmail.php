<?php
error_reporting(1);
    $name = $_POST[name];
    $email = $_POST[email];
    $subject = $_POST[subject];
    $body = $_POST[body];

function sendEmail($name,$email,$subject,$body){
    require_once('PHPMailer-master/PHPMailerAutoload.php'); //引入phpMailer 記得將路徑換成您自己的path
    $mail= new PHPMailer(); //初始化一個PHPMailer物件
    $mail->Host = "smtp.gmail.com"; //SMTP主機 (這邊以gmail為例，所以填寫gmail stmp)
    $mail->IsSMTP(); //設定使用SMTP方式寄信
    $mail->SMTPAuth = true; //啟用SMTP驗證模式
    $mail->Username = "e.environment00@gmail.com"; //您的 gamil 帳號
    $mail->Password = "M1N2B3V4dd"; //您的 gmail 密碼
    $mail->SMTPSecure = "ssl"; // SSL連線 (要使用gmail stmp需要設定ssl模式) 
    $mail->Port = 465; //Gamil的SMTP主機的port(Gmail為465)。
    $mail->CharSet = "utf-8"; //郵件編碼
      
    $mail->From = "environment00@gmail.com"; //寄件者信箱
    $mail->FromName = "e.Eyes"; //寄件者姓名
    $mail->AddAddress($email, $name); //收件人郵件和名稱
    $mail->AddBCC(''); //設定 密件副本收件人 
    
    $mail->IsHTML(true); //郵件內容為html 
    //$mail->addAttachment('', ''); //添加附件(若不需要則註解掉就好)
     
    $mail->Subject = $subject; //郵件標題
    $mail->Body = $body; //郵件內容
    $mail->AltBody = '當收件人的電子信箱不支援html時，會顯示這串~~';
     
    if(!$mail->send()) {
        echo '信件發送失敗!!';    
        echo 'Mailer Error: ' . $mail->ErrorInfo;
    } else {    
        echo '信件已發送!!';
    }

}
    sendEmail($name,$email,$subject,$body);

?>