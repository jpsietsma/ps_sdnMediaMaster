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
$Rpt += Get-HTMLContentOpen -HeaderText "SDN Media Storage Overview" -IsHidden
	
    $tvStorageDrives = @('E', 'G', 'H', 'I', 'F', 'S')
    
    $count = 0

    foreach ($drive in $tvStorageDrives){
            
            $count++

            $Rpt += Get-HTMLColumnOpen -ColumnNumber $count -ColumnCount ($tvStorageDrives).count

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

	        $Rpt += Get-HTMLColumnClose
	        
        }

$Rpt += Get-HTMLContentclose

	
$tabarray = @('Overview ','Active ONLY Shows','Movies','All Television', 'Sort Drive')
$Rpt += Get-HTMLTabHeader -TabNames $tabarray 

foreach ($tab in $tabarray ){

	if($tab -eq 'All Television'){
        
        $rpt += get-htmltabcontentopen -TabName $tab -TabHeading $tab
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


    } elseif($tab -eq 'Overview'){

        

    } elseif($tab -eq 'Active ONLY Shows'){

        

    } elseif($tab -eq 'Movies'){

        

    } elseif($tab -eq 'Sort Drive'){

        

    }

}


$Rpt += Get-HTMLClosePage
Save-HTMLReport -ReportContent $rpt -ReportPath 'D:\XAMPP\htdocs\media\docs\' -ReportName "masterTV"
