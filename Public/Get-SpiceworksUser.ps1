function Get-SpiceworksUser {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true
        )]
        [Spiceworks.Session]$Session,

        [Parameter(
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Int[]]$ID
    )
    
    begin {
    }
    
    process {

        If ($ID) {
            $ID | ForEach-Object {
                Invoke-SpiceworksApi -Session $Session -Endpoint "users/$_.json" -Method Get
            }
        } Else {
            Invoke-SpiceworksApi -Session $Session -Endpoint "users.json" -Method Get
        }

    }
    
    end {
    }
}