function Get-SpiceworksTicket {
    [CmdletBinding(
        SupportsPaging = $true
    )]
    # [OutputType("SpiceworksTicket")]
    param (
        [Spiceworks.Session]$Session,
        
        [Int[]]$ID
    )
    
    begin {
    }
    
    process {

        If ($ID) {
            $ID | ForEach-Object {
                Invoke-SpiceworksAPI -Session $Session -Endpoint "tickets/$_.json" -Method Get
            }
        }
    }
    
    end {
    }
}