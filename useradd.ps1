
1
2
3
4cybage.03
5
[ADSI]$server="WinNT://ip-0AC2034E"
$HelpDesk=$server.Create("User","arane")
$HelpDesk
$HelpDesk.SetPassword("cybage.03")
$HelpDesk.SetInfo()
 
distinguishedName :
Path              : WinNT://GLOBOMANTICS/CHI-FP01/HelpDesk

NET USER arane "cybage.03" /ADD
NET LOCALGROUP "Administrators" "arane" /add


usvalzwkprd27

yhasabnis

Dynect Concierge <concierge@dynect.com>


