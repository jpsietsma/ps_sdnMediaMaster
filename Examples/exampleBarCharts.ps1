﻿#.".\SDNMedia.charts.functions.ps1"

function SDN-BuildBarChartDataSet {
[cmdletbinding()]
param( [string]$DataDirectory, [string]$FileFilter = '*.*', [int]$NumResults = 14)

    Process{
        $dataResults = Get-ChildItem $DataDirectory -filter $FileFilter | sort -property lastWriteTime

        foreach($item in $dataResults){
            $fDate = ($item.lastWriteTime) -split ' '
            $DataSet += @([pscustomobject]@{name=$fDate[0]; data=$fDate[0];})
        }

        $DataSet = $DataSet | group name | select -Last $NumResults
        return $DataSet

    }

}

#Gathering TV data and building chart
$tvDropDir = "s:\~drops\tvdrop"
$tvFilter = '*.sdn_tv_added'

$tvChart = Get-HTMLBarChartObject
$tvChart.title = 'TV Torrent Downloads - Last 14 Days'
$tvDataSet = SDN-BuildBarChartDataSet -DataDirectory $tvDropDir -FileFilter $tvFilter
$tvDataSet

#Gathering Movie data and building chart
$movieDropDir = "s:\~drops\moviedrop"
$movieFilter = '*.sdn_movie_added'

$movieChart = Get-HTMLBarChartObject
$movieDataSet = SDN-BuildChartDataSet -DataDirectory $movieDropDir -FileFilter $movieFilter

$rpt += GET-HTMLOpenPage -TitleText "SDN Media Libraries - Download History" -LeftLogoString $config_reportImagePath -RightLogoName Alternate

$rpt += Get-HTMLContentOpen -HeaderText "SDN Media Downloads - Last 14 days" -IsHidden
$rpt += Get-HTMLColumnOpen -ColumnNumber 1 -ColumnCount 2
$rpt += Get-HTMLContentOpen -HeaderText "TV Torrent Downloads"
$rpt += Get-HTMLBarChart -ChartObject $tvChart -DataSet $tvDataSet 
$rpt += Get-HTMLContentClose
$rpt += Get-HTMLColumnClose
$rpt += Get-HTMLColumnOpen -ColumnNumber 2 -ColumnCount 2
$rpt += Get-HTMLContentOpen -HeaderText "Movie Torrent Downloads"
$rpt += Get-HTMLBarChart -ChartObject $movieChart -DataSet $movieDataSet 
$rpt += Get-HTMLContentClose
$rpt += Get-HTMLColumnClose
$rpt += Get-HTMLContentclose

$rpt += Get-HTMLClosePage

save-htmlreport -reportcontent $rpt -showreport