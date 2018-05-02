class SpiceworksSession {
    [Microsoft.PowerShell.Commands.WebRequestSession]$WebSession

    [String]$AuthenticityToken

    [String]$Server

    [Bool]$UseHTTPS
    
    [Nullable[Int]]$Port

    [String]$Username

    [URI] GetURI([String] $fragment) {

        $Builder = [URIBuilder]::new()

        If ($this.UseHTTPS) {
            $Builder.Scheme = "https"
        } Else {
            $Builder.Scheme = "http"
        }

        $Builder.Host = $this.Server

        If ($this.Port.HasValue) {
            $Builder.Port = $this.Port
        }

        If ($fragment) {
            $Builder.Path = $fragment
        }

        return $Builder.URI

    }

    [URI] GetURI() {

        return $this.GetURI("")

    }


}