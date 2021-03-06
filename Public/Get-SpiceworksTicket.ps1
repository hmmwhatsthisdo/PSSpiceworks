function Get-SpiceworksTicket {
    [CmdletBinding(
        SupportsPaging = $true
    )]
    # [OutputType("SpiceworksTicket")]
    param (
        [Parameter(
            Mandatory = $true
        )]
        [Spiceworks.Session]$Session,
        
        [Parameter(
            ValueFromPipelineByPropertyName = $true
        )]
        [Int[]]$ID
    )
    
    begin {
        function Get-SpiceworksTicketPage {
            [CmdletBinding()]
            Param(

                [Spiceworks.Session]$Session,

                [Int[]]$Page,

                [Int]$PageSize

            )
            
            Process {
                $Page | ForEach-Object {
                    Write-Verbose "Fetching ticket page $_"
                    Invoke-SpiceworksAPI -Session $Session -Endpoint "tickets.json" -Method Get -Parameters @{
                        page_size = $PageSize
                        page = $_
                    } | Write-Output
                }
            }

        }

        # Unfortunately, Spiceworks' API is bugged and does not properly respect the page_size parameter when retrieving tickets.
        # As a result, tickets are always returned in batches of 100.
        $PageSize = 100
    }
    
    process {

        If ($ID) {
            $ID | ForEach-Object {
                Invoke-SpiceworksAPI -Session $Session -Endpoint "tickets/$_.json" -Method Get
            }
        } Elseif ($PSCmdlet.PagingParameters.First -le [int32]::MaxValue) {

            

            # Determine the starting page.
            $StartPage = (($PSCmdlet.PagingParameters.Skip) / $PageSize) -as [int] + 1

            # Determine the last page to retrieve.
            $EndPage = [Math]::Ceiling(($PSCmdlet.PagingParameters.Skip + $PSCmdlet.PagingParameters.First) / $PageSize)

            Write-Verbose "Retrieving ticket pages $StartPage through $EndPage."
            Get-SpiceworksTicketPage -Session $Session -Page ($StartPage..$EndPage) -PageSize $PageSize | Select-Object -Skip ($PSCmdlet.PagingParameters.Skip % $PageSize) -First $PSCmdlet.PagingParameters.First 
            
        } Else {
            # Retrieve all tickets in SW.
            # This requires first knowing how many tickets are available.

            $TicketCount = Invoke-SpiceworksAPI -Session $Session -Endpoint "tickets.json" -Method Get -Parameters @{total_count = $true} | ForEach-Object Count

            Write-Verbose "$TicketCount tickets available as reported by Spiceworks."

            $EndPage = [Math]::Ceiling($TicketCount / $PageSize)

            Write-Verbose "Retrieving ticket pages 1 through $EndPage."
            Get-SpiceworksTicketPage -Session $Session -Page (1..$EndPage) -PageSize $PageSize
        }
    }
    
    end {
    }
}