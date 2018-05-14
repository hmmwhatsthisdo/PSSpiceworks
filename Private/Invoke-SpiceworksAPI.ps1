function Invoke-SpiceworksAPI {
    [CmdletBinding()]
    param (
        [Spiceworks.Session]$Session,

        [String]$Endpoint,

        [Microsoft.PowerShell.Commands.WebRequestMethod]$Method,

        [Hashtable]$Parameters
    )
    
    begin {
    }
    
    process {

        $MethodURI = $Session.GetURI("/api/$Endpoint")

        Invoke-RestMethod -Method $Method -Uri $MethodURI -WebSession $Session.WebSession -Body $Parameters

    }
    
    end {
    }
}