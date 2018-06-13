class SDNMediaFile {



}

class Episode { 

[string]$FileName
[string]$Show
[string]$Season
[string]$Episode
[DateTime]$DownloadDate
[DateTime]$DownloadTime

} 

class Movie {
[string]$Name
[int]$Year
[string]$Genre

    [string]GetGenre([Movie]$movieName){

        return this.$Genre

    }

    [int]GetYear([Movie]$movieName){

        return this.$Year

    }

    [string]GetName([Movie]$movieName){

        return this.$Year

    }

}