#Install-Module -Name ReportHTML

$config_TVShowDrives = @(
                            "E:\TV Shows",
                            "G:\TV Shows",
                            "H:\TV Shows",
                            "I:\TV Shows"
                        )

$config_reportImagePath = 'images\sdnReportLogo.jpg'

$existingShows = Get-ChildItem $config_TVShowDrives -Directory | SELECT FullName, Name, Size | SORT name

$Rpt = @()
$Rpt += get-htmlopenpage -TitleText "Television Library - Master Admin Report" -LeftLogoString $config_reportImagePath -RightLogoName Alternate
$Rpt += Get-HTMLContentOpen -HeaderText "Television Show Storage Overview"
	
    $tvStorageDrives = @('E:', 'G:', 'H:', 'I:')
    
    $count = 0

    foreach ($drive in $tvStorageDrives){
            
            $count++

            $driveSpace = Get-WMIObject Win32_Logicaldisk -filter "deviceid='$drive'" -ComputerName jimmybeast-sdn | SELECT DeviceID, @{Name='UsedSpace';Expression={($_.Size/1GB -as [int]) - ([math]::Round($_.Freespace/1GB,2))}},

                                                                                                                            @{Name="freespace";Expression={[math]::Round($_.Freespace/1GB,2)}} | group DeviceID, freespace, UsedSpace

            $Rpt += Get-HTMLColumnOpen -ColumnNumber $count -ColumnCount ($tvStorageDrives).count

                $headerText = Get-WMIObject Win32_Logicaldisk -filter "deviceid='$drive'" -ComputerName jimmybeast-sdn | SELECT VolumeName 

                $rpt += Get-HTMLHeading -headerSize 1 -headingText $headerText
                
                $PieObject = Get-HTMLPieChartObject

                $rpt += Get-HTMLPieChart -ChartObject $PieObject -DataSet $driveSpace

	        $Rpt += Get-HTMLColumnClose
	        
        }

$Rpt += Get-HTMLContentclose

	
$tabarray = @('All Television','Active ONLY Shows','Movies','Statistics')
$Rpt += Get-HTMLTabHeader -TabNames $tabarray 

foreach ($tab in $tabarray ){

	if($tab -eq 'All Television'){
        
        $rpt += get-htmltabcontentopen -TabName $tab
        $Rpt += Get-HTMLContentOpen
        $Rpt += get-htmlcontentdatatable -ArrayOfObjects ($existingShows | SELECT Name, FullName, @{ expression={

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
        $Rpt += Get-HTMLContentClose


    } elseif($tab -eq 'Active ONLY Shows'){

    } elseif($tab -eq 'Movies'){

    } elseif($tab -eq 'Statistics'){

    }

}


$Rpt += Get-HTMLClosePage
Save-HTMLReport -ReportContent $rpt -ReportPath 'D:\XAMPP\htdocs\media\docs\' -ReportName "masterTV" -showreport
