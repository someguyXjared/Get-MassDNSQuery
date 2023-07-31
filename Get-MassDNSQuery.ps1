$ErrorActionPreference= 'silentlycontinue'
cls

$Domains = Get-Content .\Domains.txt
$TempDomProps = @{'Domain Name'='';'Type'='';'Host'='';'Preference'='';'Strings'='';}

	$FinalDNSRecords = @()
		
	$DNSServer1 = '8.8.8.8'
	$DNSServer2 = '8.8.4.4'
	$DNStoUse = $DNSServer1
	
	$DNSConnection = Test-Connection $DNSServer1 -quiet
	If ($DNSConnection -eq $False){
		$DNStoUse = $DNSServer2
		$DNSServer = 'Data pulled from 8.8.4.4'
	}

$Domains | %{
	Write-Host 'Checking' $_ -ForegroundColor Cyan
	
	$MXRecords = @()
	$MXRecords = resolve-dnsname -name $_ -Type MX -Server $DNStoUse -NoHostsFile -DNSOnly
	Write-Host '     Getting MX Records' -ForegroundColor Green
	ForEach ($Rec in $MXRecords){
		$TempMXObj = New-Object -TypeName PSObject -Prop $TempDomProps
		$TempMXObj.{Domain Name} = $_
		$TempMXObj.Type = 'MX'
		$TempMXObj.Host = $Rec.NameExchange
		$TempMXObj.Preference = $Rec.Preference
	
		$FinalDNSRecords += $TempMXObj
	
	}
	
#	$SPFRecords = @()
#	$SPFRecords = resolve-dnsname -name $_ -Type TXT -Server $DNStoUse -NoHostsFile -DNSOnly
#	Write-Host '     Getting SPF Records' -ForegroundColor Green
#	Write-Host
	
#	ForEach ($Record in $SPFRecords){
	
#		If ($SPFRecords.strings -like '*SPF*'){
#			$TempSPFObj = New-Object -TypeName PSObject -Prop $TempDomProps
#			$TempSPFObj.{Domain Name} = $_
#			$TempSPFObj.Type = 'TXT/SPF'
#			[string] $SPFText = $Record.Strings
#			$TempSPFObj.Strings = $SPFText
			
#			$FinalDNSRecords += $TempSPFObj
#		}
	}


	
#}

Write-Host 'Exporting DomainDNSQueryResults.CSV' -ForegroundColor Yellow
Write-Host
$FinalDNSRecords | Select 'Domain Name',Type,Host,Preference | Sort 'Domain Name',Type,Preference | Export-CSV .\DomainDNSQueryResults.csv -notypeinformation
# $FinalDNSRecords | Select 'Domain Name',Type,Host,Preference,Strings | Sort 'Domain Name',Type,Preference | Export-CSV .\DomainDNSQueryResults.csv -notypeinformation
