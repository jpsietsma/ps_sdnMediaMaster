function SDN-BuildChartDataSet {
[cmdletbinding()]
param( [string]$DataDirectory, [string]$FileFilter = '*.*', [int]$NumResults = 14)

    Process{
        $dataResults = Get-ChildItem $DataDirectory -filter $FileFilter | sort -property lastWriteTime

        foreach($item in $dataResults){
            $fDate = ($item.lastWriteTime) -split ' '
            $DataSet += @([pscustomobject]@{name=$fDate[0]; data=$fDate[0]})
        }

        $DataSet = $DataSet | select count, name, data -Last $NumResults | group name 
        return $DataSet

    }

}
