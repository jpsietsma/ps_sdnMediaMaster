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
$Rpt += get-htmlopenpage -TitleText "Media Master report" -LeftLogoString $config_reportImagePath -RightLogoName Alternate
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

$Rpt += Get-HTMLContentClose
$Rpt += Get-HTMLClosePage
Save-HTMLReport -ReportContent $rpt -ReportPath 'D:\XAMPP\htdocs\media\docs\' -ReportName "masterTV" -showreport
