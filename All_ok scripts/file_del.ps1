dir D:\old-nagios\nagios\objects\services -recurse  | where { ((get-date)-$_.creationTime).days -gt 60} | remove-item -force -recurse