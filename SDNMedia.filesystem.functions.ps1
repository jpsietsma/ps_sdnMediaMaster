function SDN-GenerateMediaID {
[cmdletbinding()]
param( [string]$FilePath, [string]$Date = (Get-Date -UFormat "%m%d%y").ToString(), [string]$Time = (((Get-Date -UFormat "%H%M%S").ToString()) -replace ':', ''))

    Process{
        
        $generatedID = ($FilePath[0].ToString())
        $generatedID += $Date
        $generatedID += '-'
        $generatedID += $Time
        $generatedID += (Get-Item -LiteralPath $FilePath).Length

        return $generatedID
    }

}

#SDN-GenerateMediaID -FilePath 'S:\Deep.State.S01E08.HDTV.x264-MTB[eztv].mkv'

function SDN-SearchRSS ($url ) {

        $wc = New-Object Net.Webclient
        ([xml]$wc.downloadstring($url)).rss.channel.item

}