#Query Database for all shows
function Get-SDNMediaShows {

[cmdletbinding()]
param( 
    [string]$SearchQuery, 
    [string]$FileFilter = '*.*', 
    [int]$dataNumResults = 14
    )


return $results
}

#$showStats = Get-SDNMediaShows -SearchQuery 'Charles in Charge' -FileFilter '*.mkv'

#Query Database for episode
function Get-SDNMediaEpisodes {
[cmdletbinding()]
param( 
    [string]$SearchQuery, 
    [string]$FileFilter = '*.*', 
    [int]$dataNumResults = 14
    )


return $results
}

#$showStats = Get-SDNMediaShows -SearchQuery 'Charles in Charge' -FileFilter '*.mkv'

function Get-SDNMediaMovies {
[cmdletbinding()]
param( 
    [string]$SearchQuery, 
    [string]$FileFilter = '*.*', 
    [int]$dataNumResults = 14
    )


return $results
}

#Get-SDNMediaShows -SearchQuery 'Charles in Charge' -FileFilter '*.mkv'


<#
Function Name: SDN-EpisodeExists

Notes:
Passing an unformatted episode name to this function
results in searching sort drive for existing downloads 


parameters:
[0] - string episode name to search
[1] - bool is episode name sanitized or not {ie Show.SxxExx.mkv}

Usage (formatted):
SDN-EpisodeExists -EpisodeName 'e' -IsFormatted $false

#>

function SDN-EpisodeExists {
[cmdletbinding()]
param( 
    [string]$EpisodeName,
    [bool]$IsFormatted = $true,
    [string]$SortPath = ''
    )

    switch($isFormatted){

        $true {
        
            #Searches existing show folders for passed formatted episode name
            Write-Host 'File has been properly formatted.'
        
        }

        $false {
        
            #Searches Sort Drive for passed unformatted filename
            $files = Get-ChildItem $SortPath -File
            Write-Host $files
        
        }

    }

return $results
}

#SDN-EpisodeExists -EpisodeName 'e' -IsFormatted $false

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