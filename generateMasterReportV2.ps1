#Install-Module -Name ReportHTML
.".\SDNMedia.charts.functions.ps1"
.".\SDNMedia.sqldatabase.functions.ps1"
.".\SDNMedia.filesystem.functions.ps1"
.".\SDNMedia.media.classes.ps1"


$config_TVShowDrives = @(
                            "E:\TV Shows",
                            "G:\TV Shows",
                            "H:\TV Shows",
                            "I:\TV Shows"
                        )

$config_MoviesDrives = @(   "F:\",
                            "M:\"
                        )

$tvStorageDrives = @('E', 'G', 'H', 'I', 'F', 'S')

$config_reportImagePath = 'images\sdnReportLogo.jpg'

$existingShows = Get-ChildItem $config_TVShowDrives -Directory | SELECT FullName, Name, Size | SORT name
$existingMovies = Get-Childitem $config_MoviesDrives -Recurse -File | SELECT Name, FullName, Size | SORT name

$rpt = @()
$rpt += get-htmlopenpage -TitleText "SDN Media Libraries - Master Admin Report" -LeftLogoString $config_reportImagePath -RightLogoName Alternate
	
$tabarray = @('Overview','Active Shows','Movies','All Television', 'Sort Drive', 'Missing Episodes', 'Media Health', 'RSS Feeds')
$rpt += Get-HTMLTabHeader -TabNames $tabarray 

foreach ($tab in $tabarray ){

	if($tab -eq 'All Television'){

#region Television Tab
        $rpt += get-htmltabcontentopen -TabName $tab -TabHeading $tab
        $rpt += Get-HTMLContentOpen
        $rpt += get-htmlcontentdatatable -ArrayOfObjects ($existingShows | SELECT Name, FullName, @{ expression={

                                                                                                            $name = $_.FullName
                                                                                                            $name = $name -split("\\")

                                                                                                            switch($name[0]){

                                                                                                                "E:" { $airStatus = 'Active' }
                                                                                                                "G:" { $airStatus = 'Ended' }
                                                                                                                "H:" { $airStatus = 'Active' }
                                                                                                                "I:" { $airStatus = 'Ended' }

                                                                                                                default { $airStatus = 'unknown' }

                                                                                                            }

                                                                                                        $airStatus

                                                                                                        }; 
                                                                                             
                                                                                             label='Airing Status' }, 
                                                                                             
                                                                                             @{ expression={
                                                                                             
                                                                                                                (Get-ChildItem -Directory ($_.FullName) ).count
                                                                                                                
                                                                                                           }; 
                                                                                                
                                                                                                label='# of Seasons' }, 
                                                                                                
                                                                                             @{ expression={
                                                                                             
                                                                                                                (Get-ChildItem -Recurse -File ($_.FullName) ).count
                                                                                                                
                                                                                                           }; 
                                                                                                           
                                                                                                label='# of Episodes' }, 
                                                                                                
                                                                                             @{ expression={
                                                                                             
                                                                                                                ("Television Show")
                                                                                                                
                                                                                                           }; 
                                                                                                           
                                                                                               label='Media Type' }) 
        $rpt += get-htmltabcontentClose
        $rpt += Get-HTMLContentClose

#endregion

    } elseif($tab -eq 'Overview'){

#region Overview Tab
        $rpt += get-htmltabcontentopen -TabName $tab -TabHeading $tab
        $rpt += Get-HTMLContentOpen -HeaderText "SDN Media Storage Overview"
    
    $count = 0

    foreach ($drive in $tvStorageDrives){
            
            $count++

            $rpt += Get-HTMLColumnOpen -ColumnNumber $count -ColumnCount ($tvStorageDrives).count

                $headerText = Get-WMIObject Win32_Logicaldisk -filter "deviceid='$drive`:'" -ComputerName jimmybeast-sdn | SELECT VolumeName 

                $rpt += Get-HTMLHeading -headerSize 1 -headingText $headerText.VolumeName
                
                $dataset = @()

                $data = Get-PSDrive $drive | Select Free, Used

                $dataFreeGB = [math]::Round((((($data.Free)/1024)/1024)/1024), 2)
                $dataUsedGB = [math]::Round((((($data.Used)/1024)/1024)/1024), 2)

                $dataset += @([pscustomobject]@{name="Free Space (GB)";Count=$dataFreeGB})

                if(($drive -eq "M") -or ($drive -eq "F")){
                    
                    $dataset += @([pscustomobject]@{name="Movies (GB)";Count=$dataUsedGB})

                } else {

                    $dataset += @([pscustomobject]@{name="TV Shows (GB)";Count=$dataUsedGB})

                }

                $PieObject = Get-HTMLPieChartObject
                $PieObject.ChartStyle.ColorSchemeName = "ColorScheme4"
                $pieObject.Size.Width = '250'
                $pieObject.Size.Height = '250'

                $rpt += Get-HTMLPieChart -ChartObject $PieObject -DataSet $dataset

	        $rpt += Get-HTMLColumnClose
          	        
        }

        $rpt += Get-HTMLContentClose

        $rpt += Get-HTMLContentOpen -HeaderText "Bi-Monthly Download History Breakdown"

#region TV Torrent Bar Chart
        $tvChart = Get-HTMLBarChartObject
        $tvChart.Title = "TV Torrent Downloads - Last 14 Days"
        $tvChart.Size.Width = 450
        $tvChart.ChartStyle.responsive = $true

        $tvDropDir = "s:\~drops\tvdrop"
        $tvFilter = '*.sdn_tv_added'
        $tvDataSet = SDN-BuildChartDataSet -DataDirectory $tvDropDir -FileFilter $tvFilter

        $rpt += Get-HTMLColumnOpen -ColumnNumber 1 -ColumnCount 3
        $rpt += Get-HTMLContentOpen -HeaderText "TV Torrent Downloads - Last 14 Days" -IsHidden
        $rpt += Get-HTMLBarChart -ChartObject $tvChart -DataSet $tvDataSet 
        $rpt += Get-HTMLContentClose
        $rpt += Get-HTMLColumnClose
#endregion

#region Movie Torrent Bar Chart
        $movieChart = Get-HTMLBarChartObject
        $movieChart.Title = "Movie Torrent Downloads - Last 14 Days"
        
        $movieDropDir = "s:\~drops\moviedrop"
        $movieFilter = '*.sdn_movie_added'
        $movieDataSet = SDN-BuildChartDataSet -DataDirectory $movieDropDir -FileFilter $movieFilter

        $rpt += Get-HTMLColumnOpen -ColumnNumber 2 -ColumnCount 3
        $rpt += Get-HTMLContentOpen -HeaderText "Movie Torrent Downloads - Last 14 Days" -IsHidden
        $rpt += Get-HTMLBarChart -ChartObject $movieChart -DataSet $movieDataSet 
        $rpt += Get-HTMLContentClose
        $rpt += Get-HTMLColumnClose
#endregion

#region Software/Game Bar Chart
        $softwareChart = Get-HTMLBarChartObject
        $softwareChart.Title = "Software/Game Torrent Downloads - Last 14 Days"

        $softwareDropDir = "s:\~drops\softwaredrop"
        $softwareFilter = '*.sdn_software_added'
        $softwareDataSet = SDN-BuildChartDataSet -DataDirectory $softwareDropDir -FileFilter $softwareFilter

        $rpt += Get-HTMLColumnOpen -ColumnNumber 3 -ColumnCount 3
        $rpt += Get-HTMLContentOpen -HeaderText "Game/Software Torrent Downloads - Last 14 Days" -IsHidden
        $rpt += Get-HTMLBarChart -ChartObject $softwareChart -DataSet $softwareDataSet 
        $rpt += Get-HTMLContentClose
        $rpt += Get-HTMLColumnClose
#endregion

        $rpt += Get-HtmlContentClose

        $rpt += get-htmltabcontentClose
#endregion

    } elseif($tab -eq 'Active Shows'){

#region Active Shows Tab
        $rpt += get-htmltabcontentopen -TabName $tab -TabHeading $tab
        $rpt += Get-HTMLContentOpen -HeaderText "Coming Soon..." -IsHidden
        $rpt += Get-HTMLContentText -Heading "Active TV Show Search" -Detail "This feature is currently under development, please check back soon. "
        $rpt += Get-HtmlContentClose
        $rpt += get-htmltabcontentClose 
#endregion

    } elseif($tab -eq 'Movies'){

#region Movies Tab       
        $rpt += get-htmltabcontentopen -TabName $tab -TabHeading $tab
        $rpt += Get-HTMLContentOpen
        $rpt += get-htmlcontentdatatable -ArrayOfObjects ($existingMovies | SELECT Name, FullName, @{ expression={

                                                                                                            $name = $_.FullName
                                                                                                            $name = $name -split("\\")

                                                                                                            switch($name[0]){

                                                                                                                "E:" { $airStatus = 'Active' }
                                                                                                                "G:" { $airStatus = 'Ended' }
                                                                                                                "H:" { $airStatus = 'Active' }
                                                                                                                "I:" { $airStatus = 'Ended' }

                                                                                                                default { $airStatus = 'unknown' }

                                                                                                            }

                                                                                                        $airStatus

                                                                                                        }; 
                                                                                             
                                                                                             label='Media Genre' }, 
                                                                                             
                                                                                             @{ expression={
                                                                                             
                                                                                                                ("No")
                                                                                                                
                                                                                                           }; 
                                                                                                
                                                                                                label='Subtitles?' }, 
                                                                                                                                                                                                                                                                                      
                                                                                             @{ expression={
                                                                                             
                                                                                                                ("Movie")
                                                                                                                
                                                                                                           }; 
                                                                                                           
                                                                                               label='Media Type' }) 
        $rpt += get-htmltabcontentClose
        $rpt += Get-HTMLContentClose
#endregion       

    } elseif($tab -eq 'Sort Drive'){

#region Sort Drive Tab
        $rpt += get-htmltabcontentopen -TabName $tab -TabHeading $tab
         
         $fileList = Get-ChildItem 'S:' -File | SELECT Name, FullName, CreationTime

        $rpt += Get-HtmlContentOpen -HeaderText "Files waiting to be processed" 
	    $rpt += Get-HtmlContentTable $fileList

        $rpt += get-htmltabcontentClose 
        $rpt += Get-HtmlContentClose 
#endregion

    } elseif($tab -eq 'Missing Episodes'){

#region Missing Episodes Tab
        $rpt += get-htmltabcontentopen -TabName $tab -TabHeading $tab
        $rpt += Get-HTMLContentOpen -HeaderText "Coming Soon..." -IsHidden
        $rpt += Get-HTMLContentText -Heading "Missing Episode Report" -Detail "This feature will show all missing episodes on currently downloaded shows.  This feature is currently under development, please check back soon. "
        $rpt += Get-HtmlContentClose
        $rpt += get-htmltabcontentClose 
#endregion

    } elseif($tab -eq 'Media Health'){

#region Media Health Tab
        $rpt += get-htmltabcontentopen -TabName $tab -TabHeading $tab
        $rpt += Get-HTMLContentOpen -HeaderText "Coming Soon..." -IsHidden
        $rpt += Get-HTMLContentText -Heading "Media Health Status Report" -Detail "This feature will report on shows where episode names are not properly formatted, as well as any file type violations.  This feature is currently under development, please check back soon. "
        $rpt += Get-HtmlContentClose
        $rpt += get-htmltabcontentClose 
#endregion

    } elseif($tab -eq 'RSS Feeds'){

#region RSS Feeds Tab
        $eztvRSSResults = SDN-SearchRSS "https://eztv.ag/ezrss.xml"
        $limeRSSResults = SDN-SearchRSS "https://www.limetorrents.cc/rss/"
        $yifyRSSResults = SDN-SearchRSS "https://yts.am/rss"

        $rpt += get-htmltabcontentopen -TabName $tab -TabHeading $tab

        $eztvItems = @()
        $limeItems = @()
        $yifyItems = @()

        #Creates EZTV RSS data table
        foreach($eztv in $eztvRSSResults){

            $url = 'URL01' + $eztv.enclosure.url + 'URL02' + $filename + 'URL03'
            $filename = $eztv.fileName
            $seeds = $eztv.seeds
            $peers = $eztv.peers

            $eztvItem = @([pscustomobject]@{filename=$filename;link=$url;seeds=$seeds;peers=$peers})
            $eztvItems += $eztvItem

        }

        #Creates YIFY RSS data table
        foreach($yify in $yifyRSSResults){

            $url = 'URL01' + $yify.enclosure.url + 'URL02' + $title + 'URL03'
            $title = $yify.title
            $upDate = $yify.pubDate
            $description = $yify.description

            $yifyItem = @([pscustomobject]@{title=$title;link=$url;uploadDate=$upDate;description=$description})
            $yifyItems += $yifyItem

        }

        #Creates LimeTorrents RSS data table
        foreach($lime in $limeRSSResults){
        
            $url = 'URL01' + $lime.enclosure.url + 'URL02' + $title + 'URL03'
            $title = $lime.title
            $size = $lime.size
            
            $limeItem = @([pscustomobject]@{title=$title;'Download URL'=$url;'Size (MB)'=[math]::Round((($size/1024)/1024), 2)})
            $limeItems += $limeItem
        
        }

        $rpt += Get-HTMLContentOpen -HeaderText "EZTV.ag RSS Feed"
        $rpt += get-htmlcontentdatatable -ArrayOfObjects ($eztvItems)
        $rpt += Get-HTMLContentClose       
        $rpt += Get-HTMLContentOpen -HeaderText "Limetorrents.cc RSS Feed"
        $rpt += get-htmlcontentdatatable -ArrayOfObjects ($limeItems)
        $rpt += Get-HTMLContentClose
        $rpt += Get-HTMLContentOpen -HeaderText "Yts.am RSS Feed"
        $rpt += get-htmlcontentdatatable -ArrayOfObjects ($yifyItems)
        $rpt += Get-HTMLContentClose
        $rpt += get-htmltabcontentClose
#endregion

    }
}

$rpt += Get-HTMLClosePage
Save-HTMLReport -ReportContent $rpt -ReportPath 'D:\XAMPP\htdocs\media\docs\' -ReportName "masterSDNv2"

$rpt = ''
