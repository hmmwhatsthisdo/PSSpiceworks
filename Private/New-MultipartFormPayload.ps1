Function New-MultipartFormPayload {
    [CmdletBinding()]
    Param(
    [Parameter(
        Mandatory=$true, 
        Position=0
    )]
    [Hashtable]
    $Data,
    
    [Parameter(
        Mandatory=$true,
        Position=1
    )]
    [String]
    $Boundary
    )
    
    $OutputString = ""
    
        $Data.GetEnumerator() | ForEach-Object {
            $OutputString += "--$Boundary`r`n" +
                             "Content-Disposition: form-data; name=`"$($_.Key)`"`r`n`r`n" + 
                             "$($_.Value)`r`n"
        }
    
        $OutputString += "--$Boundary--`r`n"
    
        return $OutputString
    }