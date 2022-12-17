$header = Get-Content $PSScriptRoot/../assets/report.css

$sslCertificateDetails = Get-Content "$PSScriptRoot/../sslCertificateDetails.json" | ConvertFrom-Json

$html = $sslCertificateDetails | Select-Object -ExcludeProperty DaysToExpire -Property service,environment,hostname,Issuer, @{n="Days To Expire"; e={$_.DaysToExpire}}, Severity | ConvertTo-Html -As Table -Head $header 

$html = $html -replace '<td>Error</td>', '<td class="AlertConditionHigh">ERROR</td>'
$html = $html -replace '<td>High</td>', '<td class="AlertConditionHigh">HIGH</td>'
$html = $html -replace '<td>Medium</td>', '<td class="AlertConditionMedium">MEDIUM</td>'
$html = $html -replace '<td>Low</td>', '<td class="AlertConditionLow">LOW</td>'
$html = $html -replace '<td>None</td>', '<td>N/A</td>'

New-Item -Type Directory -Path "$PSScriptRoot/../_site" -Force -Verbose
$html | Out-File -FilePath "$PSScriptRoot/../_site/index.html" -Force -Verbose
