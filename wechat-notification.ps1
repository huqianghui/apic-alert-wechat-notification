
#代码演示
param ( 
    [Parameter(Mandatory=$false)]
    [object] $WebhookData
)

if ($WebhookData)
{
    # Get the data object from WebhookData
    $WebhookBody = (ConvertFrom-Json -InputObject $WebhookData.RequestBody)

	Write-Output "111111111"

    $schemaId = $WebhookBody.schemaId
    
    $message = "There is an alert from $schemaId."

	Write-Output $schemaId

    if ($schemaId -eq "azureMonitorCommonAlertSchema") 
	{

		Write-Output "222222"

        # This is the common Metric Alert schema (released March 2019)
        $Essentials = [object] ($WebhookBody.data).essentials

        # Get the first target only as this script doesn't handle multiple
        $alertTargetIdArray = (($Essentials.alertTargetIds)[0]).Split("/")
        $SubId = ($alertTargetIdArray)[2]
        $ResourceGroupName = ($alertTargetIdArray)[4]
        $ResourceType = ($alertTargetIdArray)[6] + "/" + ($alertTargetIdArray)[7]
        $ResourceName = ($alertTargetIdArray)[-1]
        $monitoringService=$Essentials.monitoringService


        $monitoringService

        
        $status = $Essentials.monitorCondition
        $alertRule= $Essentials.alertRule
        $severity=$Essentials.severity
        $monitorCondition=$Essentials.monitorCondition
        $firedDateTime=$Essentials.firedDateTime
        $alertContext= ($WebhookBody.data).alertContext
        $eventSource = $AlertContext.eventSource
        # monitor the Resource Health with common Metric Alert schema
        if ($monitoringService -eq "Platform")
		{

			Write-Output "33333"
			#代码演示
			$response = Invoke-RestMethod 'https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=wwf4a09cc0921d5e00&corpsecret=XXXXXXXXX' -Method 'GET' 
			
			If($response.errcode -eq 0)
			{

				Write-Output "444444"
				$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
				$headers.Add("Content-Type", "application/json")
				$toUser="huqianghui"
				$body = @{
						touser = $toUser
						toparty=""
						totag=""
						msgtype="text"
						agentid="1000002"
						text=@{content=$monitorCondition+": "+ $severity +" " +$alertRule+" on " +$ResourceName}
				} | ConvertTo-Json

				Write-Output "55555"
				$accessToken=$response.access_token

				Write-Output $accessToken

				Write-Output "66666"

				Write-Output $headers

				Write-Output $body

				$response = Invoke-RestMethod "https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=${accessToken}" -Method 'POST' -Headers $headers -Body $body

				Write-Output $response
			}
		
        }
    }   
}