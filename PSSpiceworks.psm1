# Get all of the pub/priv scripts 
$Scripts = @{
	Public = Get-ChildItem "$PSScriptRoot\Public\*.ps1" -ErrorAction SilentlyContinue
	Private = Get-ChildItem "$PSScriptRoot\Private\*.ps1" -ErrorAction SilentlyContinue
}

# Import them
foreach ($Type in @("Public","Private")) {
	Write-Verbose "Importing $Type functions..."
	foreach ($ImportScript in $Scripts.$Type) {
		Write-Verbose "Importing function $($ImportScript.Basename)..."
		try {
			. $ImportScript.FullName
		} 
		catch {
			Write-Error "Failed to import $type function $($ImportScript.BaseName): $_"
		}
		
	}
}



# We don't have any libraries for the time being, so this isn't a concern
<#
Write-Verbose "Importing Libraries..."
$Assemblies = @{}
foreach ($Library in (Get-Childitem "$PSScriptRoot\Library\*.dll")) {
	Write-Verbose "Importing $($Library.Basename)..."
	try {
		$Assemblies[$Library.BaseName] = Add-Type -Path $Library.Fullname -PassThru
	} catch {
		Write-Error "Failed to import DLL $($Library.BaseName): $_"
	}
}
#>

$Classes = @{
	
    ps1 = Get-ChildItem "$PSScriptRoot\Class\*.class.ps1" -ErrorAction SilentlyContinue
    cs = Get-ChildItem "$PSScriptRoot\Class\*.cs" -ErrorAction SilentlyContinue

}

# Import classes defined via PoSH
$Classes.ps1 | ForEach-Object {

    $Class = $_

    Write-Verbose $Class.FullName
    try {
        Write-Verbose "Importing PowerShell classes from $($Class.Name)..."
        . $Class.FullName		
    }
    catch {
        Write-Error "Failed to import PowerShell class from $($Class.Name): $_"
    }

}

# Import classes defined via C# (because PoSH classes don't support namespaces... yet?)
if ($Classes.cs) {

    Write-Verbose "Importing C# classes..."	

    # This is probably a bad idea, but I don't know enough about the CLR to understand why this is the case.
    $Script:ReferencedAssemblies = ([System.AppDomain]::CurrentDomain.GetAssemblies() | Sort-Object -unique -Property FullName | Where-Object Location | ForEach-Object Location | Select-Object -unique)

    try {
        Add-Type -Path ($Classes.cs | Foreach-Object Fullname) -Verbose -ReferencedAssemblies $Script:ReferencedAssemblies
    }
    catch {
        Write-Error "Failed to import C# classes: $_"
    }

}
    
# Export our functions
$Scripts.Public | ForEach-Object BaseName | Export-ModuleMember

