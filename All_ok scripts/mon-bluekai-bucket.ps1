function send_mail
{
    param([Parameter(Mandatory=$true)]
    $bucket) 
    
    #Constructing Email Parameters

    $emailMessage = New-Object System.Net.Mail.MailMessage
    $emailMessage.From = "ssingh@videologygroup.com"
    $emailMessage.To.Add("sanjeev@videologygroup.com") 
	#$emailMessage.To.Add("rgupta.consultant@videologygroup.com") 	
	$emailMessage.To.Add("ssingh.consultant@videologygroup.com") 
	$emailMessage.To.Add("nstefanidis@videologygroup.com")
	$emailMessage.To.Add("dpandey@videologygroup.com")
    $emailMessage.Subject = "One or more folder in vg-s2s-us has zero files"
    $SMTPClient= New-Object Net.Mail.SmtpClient("outlook.office365.com","587")
    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential("ssingh@videologygroup.com","MISpass2580")
    $SMTPClient.EnableSsl = $true

    #Writing content to Body.
    $body += "Below Buckets contains no files!!"+"`r`n"
    $body += "`r`n"
   
    $body += "`r`n"
    for ($i=0 ; $i -le 2 ; $i++)
		{
			$body += $bucket[$i]+"`r`n"
		}
    $body += "`r`n"
    $emailMessage.Body = $Body

    #Sending Mail
    $SMTPClient.Send($emailMessage)
} 

$year = (get-date).year 
$month = (get-date).month
$date = (get-date).day
$hour = @()
$hour += (get-date).hour

if($year -lt 10) { $year = "0"+$year}
if($month -lt 10) { $month = "0"+$month}
if($date -lt 10) { $date = "0"+$date}
if($hour[0] -le 11) {

switch ($hour)
{
    11 {$hour+= $hour[0]-1; $tmp = $hour[1]-1; $hour += "0"+$tmp}
    10 {$tmp = $hour[0]-1; $hour += "0"+$tmp; $tmp = $hour[1]-1; $hour += "0"+$tmp}
    9 {$hour[0] = "0"+$hour[0];$tmp = $hour[0]-1; $hour += "0"+$tmp; $tmp = $hour[1]-1; $hour += "0"+$tmp}
    8 {$hour[0] = "0"+$hour[0];$tmp = $hour[0]-1; $hour += "0"+$tmp; $tmp = $hour[1]-1; $hour += "0"+$tmp}
    7 {$hour[0] = "0"+$hour[0];$tmp = $hour[0]-1; $hour += "0"+$tmp; $tmp = $hour[1]-1; $hour += "0"+$tmp}
    6{$hour[0] = "0"+$hour[0];$tmp = $hour[0]-1; $hour += "0"+$tmp; $tmp = $hour[1]-1; $hour += "0"+$tmp}
    5 {$hour[0] = "0"+$hour[0];$tmp = $hour[0]-1; $hour += "0"+$tmp; $tmp = $hour[1]-1; $hour += "0"+$tmp}
    4 {$hour[0] = "0"+$hour[0];$tmp = $hour[0]-1; $hour += "0"+$tmp; $tmp = $hour[1]-1; $hour += "0"+$tmp}
    3 {$hour[0] = "0"+$hour[0];$tmp = $hour[0]-1; $hour += "0"+$tmp; $tmp = $hour[1]-1; $hour += "0"+$tmp}
    2 {$hour[0] = "0"+$hour[0];$tmp = $hour[0]-1; $hour += "0"+$tmp; $tmp = $hour[1]-1; $hour += "0"+$tmp}
    1 {$hour[0] = "0"+$hour[0];$tmp = $hour[0]-1; $hour += "0"+$tmp; $hour += 23}
    0 {$hour[0] = "0"+$hour[0];$hour += 23; $tmp = $hour[1]-1; $hour += $tmp; }
}
}else 
{$hour += $hour[0]-1; $hour += $hour[1]-1}

$bucket="vg-s2s-us"
$line = @()
$bucket_name = @()
for ($i=0; $i -le 2;$i++)
	{
		$key = "/dts-service-log/y=$year/m=$month/d=$date"
		$key = $key+"/h="+$hour[$i]
		$line += get-s3object -bucketname $bucket -Key $key | measure-object -line
		$bucket_name += $bucket+$key
	}


if($line[0].Lines -lt 2 -and $line[1].Lines -lt 2 -and $line[2].Lines -lt 2)
	{
		send_mail $bucket_name
	}