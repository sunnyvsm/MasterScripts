function send_mail
{
    param([Parameter(Mandatory=$true)]
    $bucket1) 
    
    #Constructing Email Parameters

    $emailMessage = New-Object System.Net.Mail.MailMessage
    $emailMessage.From = "ssingh@videologygroup.com"
    $emailMessage.To.Add("sanjeev@videologygroup.com") 
	#$emailMessage.To.Add("rgupta.consultant@videologygroup.com") 	
	$emailMessage.To.Add("ssingh.consultant@videologygroup.com") 
	$emailMessage.To.Add("nstefanidis@videologygroup.com")
	$emailMessage.To.Add("dpandey@videologygroup.com")
    $emailMessage.Subject = "One or more Buckets in vg-s2s-us/FTP has files older than 24 hours"
    $SMTPClient= New-Object Net.Mail.SmtpClient("outlook.office365.com","587")
    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential("ssingh@videologygroup.com","MISpass2580")
    $SMTPClient.EnableSsl = $true

    #Writing content to Body.
    $body += "Below FTP Buckets are having files older than 24 hours."+"`r`n" 
	$body += "`r`n"
	$body += "Bucket Name:"+"`t`t`t"+"File Count"+"`r`n"
	$body += "------------------------------------------------------------"+"`r`n"
    for ($i=0 ; $i -le $bucket1.count-1 ; $i++)
		{
			$body += "`r`n"
			$body += $bucket1[$i]+"`r`n"
		}
    $body += "`r`n"

	
    <#for ($i=0 ; $i -le $bucket2.count-1 ; $i++)
		{
			$body += $bucket2[$i]+"`r`n"
		}#>
    $emailMessage.Body = $Body
    #$body
    #Sending Mail
    $SMTPClient.Send($emailMessage)
} 

$bucket="vg-s2s-us"
$key = "/FTP/"
$foldername = ""
$S3Object = get-s3object -bucketname $bucket -Key $key | select Key
$Empty_bucket1 = @()
#$Empty_bucket2 = @()

foreach($s3obj in $S3Object)
    {
          [string]$fileobj = $s3obj.key		  
		  $count = 0 	  
		  if($fileobj.Chars($fileobj.length-1) -eq "/")
                {
                    for($var = $fileobj.length-1; $var -ge 0; $var--)
                        {
                            $temp0 = $fileobj.Chars($var)
                            If($temp0 -eq "/")
                                {
                                    if ($count -eq 0)
                                        {
                                            $foldername = $fileobj
                                        }
                                    break
                                }
                            $count++
                        }						
					if($foldername -ne "FTP/")
                        {
                            if((Get-S3Object -BucketName $bucket -Key $foldername | ? {$_.LastModified -lt (get-date).AddHours(-24)} | Measure-Object -Line).Lines -gt 1)
                                {
                                    $line = (Get-S3Object -BucketName $bucket -Key $foldername | ? {$_.LastModified -lt (get-date).AddHours(-24)} | Measure-Object -Line).Lines -1
									$Empty_bucket1 += $foldername+"`t`t"+"-"+"`t"+$line
                                }                            
                        }
                }
    }

if($Empty_bucket1)
    {
        send_mail $Empty_bucket1
    }