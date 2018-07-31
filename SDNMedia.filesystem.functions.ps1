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

function SDN-GetShowStatus($showName){

$drives = @('E:\TV Shows\','G:\TV Shows\', 'H:\TV Shows\', 'I:\TV Shows\', 'Q:\TV Shows\')
$finalShowStatus = "New Show"
 
    foreach($drive in $drives){

        if(Test-Path -LiteralPath ($drive + $showName)){

            $finalShowStatus = "Existing"

        }

    }

    return $finalShowStatus
}

function SDN-GetAiringStatus($uShow){

$drives = @('E:\TV Shows','G:\TV Shows', 'H:\TV Shows', 'I:\TV Shows', 'Q:\TV Shows')
$finalAiringStatus = 'unknown'
 
    $driveItems = Get-ChildItem $drives -Directory | SELECT FullName

    foreach($ShowFolder in $driveItems){

        if($ShowFolder -match ('.*' + $uShow)){
            $finalAiringStatus = 'Airing'
        }

    }
    $finalAiringStatus

}

function SDN-GetEpisodeExists($uFileName){
$finalExists


return "True"
#return $finalExists
}

function SDN-GetShowFileInfo($title){

$title -match '(.*)((S\d\d).*(E\d\d))' | Out-Null

$showName = $Matches[1]

$showSeason = $Matches[3]
$showSeasonNum = $showSeason[1] + $showSeason[2]

$showEpisode = $Matches[4]
$showEpisodeNum = $showEpisode[1] + $showEpisode[2]

$showStatusSDN = SDN-GetShowStatus -showName $Matches[1]
$showHomePath = "{Show_Home}"

$showInfo = @{"ShowName"=$showName;"ShowNameUnformatted"=$title;"ShowSeason"=$showSeason;"SeasonNum"=$showSeasonNum;"ShowEpisode"=$showEpisode;"EpisodeNum"=$showEpisodeNum;"ShowStatusSDN"=$showStatusSDN;"ShowHomePath"=$showHomePath;}

return $showInfo
}

function SDN-GetShowName($FileName){

$FileName -match '(.*)((S\d\d).*(E\d\d))' | Out-Null

return $Matches[1]
}