
<B><U>Results:</U></B><BR><BR>
<?php
ini_set("memory_limit","3200M");

global $rdomain,$html;
$mode=$_REQUEST['mode'];
$subject = $_REQUEST['sub'];
$from = $_REQUEST['from'];
$testemail = $_REQUEST['email'];
$msg = $_REQUEST['message'];
$sid = $_REQUEST['sid'];
$list = $_REQUEST['list'];
$limit = $_REQUEST['limit'];
$datafile = $_REQUEST['data'];
$rdomain = $_REQUEST['rdomain'];
$offer1 = $_REQUEST['offer'];
list($offer,$nmvalue) = explode("#",trim($offer1));
$userid = $_REQUEST['userid'];
$html=$_REQUEST['html'];
$sendtype = $_REQUEST['sendtype'];
$box=$_POST['box'];
list($ip,$hname)=explode("|",$box[0]);
$dd = date("Ymd");
$offersent=array();
$offersent1=array();
/*-------------------------------*/
This part get the tets maild selected from check box ans performs below operations.
$temp=1;
$box1=$_POST['box1'];
list($eid)=explode("|",$box1[0]);
$total=count($box1);
$testemail=$eid;
#$rmid1=rand(926000000,926999999);
#$rmid1=md5($rmid1);
$rmid2=rand(5260000,5269999);
$mdte1=date ("Ymdhis");
$mdte=date ("Y.m.d.h.i.s");
$name=explode("@",$testemail);
$name=explode(".",$name[0]);
$name=ucwords($name[0]);

/*-------------------------------*/
$timezone_local = 1;
$time = time();
$timezone_offset = date("Z");
$timezone_add = round($timezone_local*60*60);
$time = round($time-$timezone_offset+$timezone_add);
$date = date("l dS F Y h:i:s A", $time);
$dte= $date;

/*-------------------------------*/

$rmid1=rand(174212478,17422147514);
$rmid1= base_convert($rmid1,10,16);


/*-------------------------------*/
$codelenght = 12;
while($newcode_length < $codelenght) 
{
$x=1;
$y=3;
$part = rand($x,$y);
if($part==1){$a=48;$b=57;}  // Numbers
if($part==2){$a=65;$b=90;}  // UpperCase
if($part==3){$a=97;$b=122;} // LowerCase
$code_part=chr(rand($a,$b));
$newcode_length = $newcode_length + 1;
$newcode = $newcode.$code_part;
} 

/*-------------------------------*/

$frm= strToHex("robinhood");
function strToHex($string)
{
    $hex='';
    for ($i=0; $i < strlen($string); $i++)
    {
        $hex .= dechex(ord($string[$i]));
    }
    return $hex;
}

$ename=base64_encode($name);
$ename=explode("=",$ename);
$ename=$ename[0];


/*-------------------------------*/

$mid="<$mdte1-$ename-$frm-$newcode.inmail.$name@peixeurbano.com.br>";
$ret="<$frm-$mdte-$newcode.$name=mail@cheetahmail.com.br>";
/*-------------------------------*/

if($mode == "test") // Testing of IPS
{
        $count=0;
        foreach ( $box as $value )
        {
                list($ip,$hname) = explode("|",$value);
                sendmails(1,$msg,$ip,$hname,$sid,$userid,$list,$isp,$offer,$subject,$from,$testemail,$subdate,$userip,0,$entry_date);
                $count++;
        }
        echo " <br><strong>$count</strong> Mails Sent for Testing";
        exit();
}
elseif($mode == "bulk") // Bulk mailing 
{
        $count=0;
        $fp = fopen($datafile,"r");
        while(!feof($fp))
        {
                $buffer = fgets($fp, 4096);
                @list($id,$email,$list,$isp,$clicks,$subdate,$sip,$entry_date)=explode("|",$buffer);
                if($limit > 1)
                {
                        #$dd = date("YmdHis");
                        $senddate=date("Y-m-d H:i:s");
                        if($clicks > 0){$datatype = "C";}
                        elseif($subdate >= $yesterday){$datatype = "F";}
                        else{$datatype = "N";}
                        $tet="$email|$subject|$from|$offer|$list|$ip|$isp|$senddate|$subdate|$sendtype|$datatype\n";
                        $file1="/var/www/html/SEND/sentdetails-".$isp."_$dd";
                        $fsent=fopen($file1,"a+");fputs($fsent,$tet);fclose($fsent);
                        $sendm = explode("-",$subdate);
                        $send_month = trim($sendm[1]);
                        sendmails($id,$msg,$ip,$hname,$sid,$userid,$list,$isp,$offer,$subject,$from,$email,$subdate,$sip,0,$entry_date);
/*1*/                                   updatedb($offer,$list,$isp,$sendtype,$datatype,$userid,$sid,0,$ip);
                }
                $count++;
/*
                #if($count%5==0)
                {
                        #sleep(2);
                }
*/

                if($count%$limit==0)
                {
/*2*/           if($limit > 1)
                        {
                                updatedb($offer,$list,$isp,$sendtype,$datatype,$userid,$sid,1,$ip);
                                del_lines($datafile,$limit); 
#                               echo "<br>$offer,$list,$isp,$sendtype,$datatype,$userid,$sid,1,$ip,$send_month";
                        }



                        /*-----------------------------------------------*/

                        echo " <br><strong>$count</strong> Mails Sent from IP: <strong>$ip</strong>";
                        foreach($box1 as $abc)
                                                {
                                                        echo " <br><strong></strong>Mails Sent from ID: <strong>$abc</strong> ";
                        }
                                                echo " <br><strong></strong>Mail-id selected <strong>$total</strong> <br><br>";

                        /*-----------------------------------------------*/
                       foreach ($box1 as $val1)
                                                sendmails($id,$msg,$ip,$hname,$sid,$userid,$list,$isp,$offer,$subject,$from,$val1,$subdate,$sip,1,$entry_date);
                                            /*-----------------------------------------------*/
                        //exit();
                        break;
                }
        }
        fclose($fp);
}

/*Change the Funciton*/
function updatedb($offer,$ds,$isp,$sendtype,$datatype,$uid,$sid,$update,$ip)
{
global $offersent;
$str = trim($offer)."|".trim($ds)."|".trim($isp)."|".trim($uid)."|".trim($sid)."|".trim($sendtype)."|".trim($datatype)."|".trim($ip);
if($update==0)
{
if(array_key_exists($str,$offersent)){$offersent[$str] = $offersent[$str] + 1;}
else{$offersent[$str] = 1;}
}
elseif($update==1)
{
$inp = array_keys($offersent);
foreach($inp as $data)
{
$limit = $offersent[$data];
$da = explode("|",$data);
$str = trim($da[0])."|".trim($da[1])."|".trim($da[2]);
$sdtype = trim($da[5]); $datype = trim($da[6]);$uid = trim($da[3]);$sid = trim($da[4]);$ip = trim($da[7]);


#exec("wget -b -O /dev/null -o /dev/null --no-check-certificate 'http://199.250.194.42/senddetails/update.send.3.php?off=$str|$limit|$sdtype|$datype|$uid|$sid|$ip'");

}
}
}


function del_lines($files,$X)
{
#       @chmod($files,0777);
        $start=exec("wc -l $files");
        $lines = file($files);
        $first_line = $lines[0];
        $lines = array_slice($lines, $X);
        // Write to file
        $file = fopen($files, 'w');
        fwrite($file, implode('', $lines));
        fclose($file);
        $end=exec("wc -l $files");
        $diff=$start-$end;
        echo "<br> No of ids in the file Before: <B>$start</B>  After: <B>$end</B> Difference is <b>$diff</b>";
}

function updatedb_sd($offer,$ds,$isp,$sendtype,$datatype,$uid,$sid,$update,$ip,$send_month)
{
        global $offersent1;
        $str = trim($offer)."|".trim($ds)."|".trim($isp)."|".trim($uid)."|".trim($sid)."|".trim($sendtype)."|".trim($datatype)."|".trim($ip)."|".trim($send_month);
        if(0 == $update)
        {
                if(array_key_exists($str,$offersent1)){$offersent1[$str] = $offersent1[$str] + 1;}
                else{$offersent1[$str] = 1;}
        }
        elseif(1 == $update)
        {
                $inp = array_keys($offersent1);
                foreach($inp as $data)
                {
                        $limit = $offersent1[$data];
                        $da = explode("|",$data);
                        $str = trim($da[0])."|".trim($da[1])."|".trim($da[2]);
                        $sdtype = trim($da[5]); $datype = trim($da[6]);$uid = trim($da[3]);$sid = trim($da[4]);$ip = trim($da[7]);

                }
        }
}



function sendmails($id,$message,$ip,$hname,$sid,$uid,$list,$isp,$offer,$sub,$from,$email,$subdate,$e_ip,$show,$sdate)
{
global $rdomain,$html,$sendtype,$temp,$mid,$datatype,$nmvalue;
$job = trim($offer)."|".trim($list)."|".trim($isp)."|".trim($uid)."|".trim($sid)."|".trim($datatype);
$job = trim(str_replace(" ","",$job));

if(!strstr($email, '@')) exit();
$sd=date("Y-m-d");
$oid = dechex($id);
$ppp="100.42.31.194";
$ipadr = explode('.',$ppp);
$HEXIP1 = sprintf('%xp%xp%xp%x', $ipadr[0], $ipadr[1], $ipadr[2], $ipadr[3]);
$hex = $HEXIP1 ;
$osid = dechex($sid);
$ouid = dechex($uid);
$date = explode('-',$sd);
$HEXDATE = sprintf('%xt%xt%x', $date[0], $date[1], $date[2]);
$url = "$oid!$HEXIP1!$osid!$ouid!$list|$isp!$offer!$HEXDATE!";

#$url = "$oid";

#echo "$HEXIP1!$HEXDATE";
#exit;
#echo $url;
$url=base64_encode($url);
#$url=rawurlencode($url);
$sname=explode("@",$email);

$mask=masking(); #1
$mask1="a.asp";
$url1="$mask/i-$url/mask1"; #2
$url2="$mask/r-$url/mask1"; #2
$url3="$mask/o-$url/mask1"; #2
$url4="$mask/u-$url/mask1"; #2
$message=str_replace("{iurl}",$url1,$message); #3
$message=str_replace("{rurl}",$url2,$message); #3
$message=str_replace("{ourl}",$url3,$message); #3
$message=str_replace("{uurl}",$url4,$message); #3

#$url=encrypt($url, "0");
#echo $url."\n";
#$url=decrypt($url, "0");
#echo $url."\n";
#$url=urlencode($url);
$zip= base64_encode($e_ip.'+'.$sdate);
$ii=base64_encode("$e_ip+$sdate+$surl");
#$ii="<img src=\"http://$hname/nrd.php?z-$ii\" border=0 align='center'>";
#$message=str_replace("{header}",$header,$message);
$message=str_replace("{sdate}",$subdate,$message);
$message=str_replace("{sip}",$e_ip,$message);
$message=str_replace("{domain}",$hname,$message);
$message=str_replace("{url}",$url,$message);
#$message=str_replace("{image}",$offimg,$message);
$message=str_replace("{sname}",$sname[0],$message);
$message=str_replace("{zip}",$zip,$message);
$message=str_replace("{email}",$email,$message);
$message=str_replace("{ip}","$ip",$message);
$sub=str_replace("{ip}","$ip",$sub);
$rep1 = "<quoted-printable@$hname>com@alt2.gmai1-smtp-1n.l.google.net.CC";
$rep = "mail@$hname";
$fromd = str_replace(" ","",$from);

$from="<noreply@$hname>($from)";
$body="$message";
$ishtml=1;
$sname=explode("@",$email);
$nam=explode("@",$email);
$ipss = explode(".",$ip);
$ipss1 = "$ipss[2]"."."."$ipss[3]";

$date=date("Ymd");

$boundary="----separate_fdst56w54tgdrfgr_zr4er65yhgxcdg546";

$boundary="--mimepart_4fec500d60c96_38db16e5ef015c";

$neg=file_get_contents("neg.txt");
$neg = chunk_split(base64_encode($neg));


/* 
$neg="norton.com
mcafee.com
kaspersky.com 
symantec.com
norton.com
mcafee.com
kaspersky.com ";  */

$headers  = "MIME-Version: 1.0\r\n";
$headers .= "X-Mailer: null\r\n";
$headers .= "From: $from\r\n";
$headers .= "To: <$nam[0]@$hname>\r\n";
$headers .= "Subject: $sub\r\n";
$headers .= "Message-Id: <dsf43456-12/31/2050.dskjafh4ty3i8gsrihfER@$hname>\r\n";
$headers .= "Content-Type: multipart/alternative; boundary=" . $boundary . "\r\n";


$message = "\r\n\r\n--" . $boundary . "\r\n";
$message .= "Content-type: text/plain; charset=\"ISO-8859-1\"\r\n";

$message .= "Precedence: bulk\r\n";

$message .= "$neg";

$message .= "\r\n\r\n--" . $boundary . "\r\n";
$message .= "Content-type: text/HTML; charset=\"ISO-8859-1\"\r\n";
$message .= "Content-Transfer-Encoding: 7bit\r\n";
$message .= "$body";

if($smtp = fsockopen("127.0.0.1",2525))
{
fputs($smtp,"helo 200.93.238.155\r\n");
$line = fgets($smtp, 1024);
fputs($smtp,"mail from: reply@$hname\r\n");
$line = fgets($smtp, 1024);
fputs($smtp,"rcpt to: $email\r\n");
$line = fgets($smtp, 1024);
fputs($smtp,"data\r\n");
$line = fgets($smtp, 1024);
#fputs($smtp,"X-virtual-MTA: $ip\r\n");
fputs($smtp,"X-virtual-MTA: gm_$ipss1\r\n");
fputs($smtp,"x-job: $job\r\n");
fputs($smtp,"x-envid: 016gdfv28yxjas\r\n");
fputs($smtp,"$headers\r\n");
fputs($smtp,"$message\r\n");
fputs($smtp,".\r\n");
$line = fgets($smtp, 1024);
fputs($smtp, "QUIT\r\n");
fclose($smtp);
}
else{echo "!! Error, can't connect to the server $host on the port $port";}

}



function masking(){
for ($s = '', $i = 0, $z = strlen($a = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz')-1; $i != 32; $x = rand(0,$z), $s .= $a{$x}, $i++);
#$arr = str_split($s, 8);
$arr= substr($s, 0, 8);
$arr1=substr($s, 8, 8);
$arr2=substr($s, 16, 8);
$imp= "$arr"."/$arr1"."_$arr2";
return $imp;
}

function addlines($str)
{
        $rr=rand(10,25);
        for($i=1;$i<$rr;$i++)
        {
                $new_line.="

                ";
        }
        return $str=str_replace(">",">$new_line",$str);
}

function enip($ip)
{
        $replace= array(1,2,3,4,5,6,7,8,9,0);
        $by   = array('k','d','f','e','r','q','z','s','c','p');
        $ipe  = str_replace($replace, $by, $ip);
        return $ipe;
}

function deip($ip)
{
        $replace= array('k','d','f','e','r','q','z','s','c','p');
        $by   = array(1,2,3,4,5,6,7,8,9,0);
        $ipd  = str_replace($replace, $by, $ip);
        return $ipd;
}

?>
