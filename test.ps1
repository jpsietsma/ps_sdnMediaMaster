cls
."C:\Users\JimmyS\Documents\GitHub\ps_sdnMediaMaster\SDNMedia.filesystem.functions.ps1"

$title = "12.Monkeys.S04E07.720p.HDTV.x264-KILLERS[eztv].mkv"
$testTitle = "21.Monkeys."

function SDN-GetShowFileInfo($title, $separator){

    $separator = "[" + $separator + "]"

    if($title -match '(.*)' + $separator + '((S\d\d)(E\d\d)).*'){

        $showName = $Matches[1] -replace $separator, ' '

        $showSeason = $Matches[3]
        $showSeasonNum = $showSeason[1] + $showSeason[2]

        $showEpisode = $Matches[4]
        $showEpisodeNum = $showEpisode[1] + $showEpisode[2]

        $showStatusSDN = SDN-GetShowStatus -showName $showName

        $showHomePath = "{Show_Home}"

        $showInfo = @{"ShowName"=$showName;"ShowNameUnformatted"=$title;"ShowSeason"=$showSeason;"SeasonNum"=$showSeasonNum;"ShowEpisode"=$showEpisode;"EpisodeNum"=$showEpisodeNum;"ShowStatusSDN"=$showStatusSDN;"ShowHomePath"=$showHomePath;}
    }

return $showInfo

}

$item = SDN-GetShowFileInfo -title $title -separator '.'
$item 
