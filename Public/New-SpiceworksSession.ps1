Function New-SpiceworksSession {
    [CmdletBinding()]
    [OutputType("Spiceworks.Session")]
    Param(
        [Parameter(
            Mandatory=$true, 
            Position=0
        )]
        [ValidateNotNullOrEmpty()]
        [String]
        $Server,
    
        [Parameter(
            Mandatory=$true,
            Position=1
        )]
        [PSCredential][System.Management.Automation.Credential()]
        $SpiceworksCredential,
    
        [Switch]
        $UseHTTPS = $false
    )
    
        $SpiceworksSession = [Spiceworks.Session]::new()

        $SpiceworksSession.Server = $Server

        $SpiceworksSession.UseHTTPS = $UseHTTPS




        Write-Verbose "Checking Spiceworks Presence..."
        $InitialSessionResponse = Invoke-WebRequest -Method Get -Uri $SpiceworksSession.GetURI("pro_users/login") -SessionVariable "SpiceworksWebSession"
    
        If ($InitialSessionResponse.ParsedHtml.Title -notmatch "Spiceworks") {
            # We're not in Spiceworks! Throw.
            Throw [System.Net.WebException]("Spiceworks login page not detected.")
        }

        $SpiceworksLoginForm = $InitialSessionResponse.Forms | Where-Object id -eq login_form
        
        If (($SpiceworksLoginForm | Measure-Object).Count -ne 1) {
            Throw [System.Net.WebException]("Incorrect number of form objects on login page (Found $(($SpiceworksLoginForm | Measure-Object).Count), Expected 1.)")
        }
        Write-Verbose "Spiceworks detected, attempting login with $($SpiceworksCredential.UserName)..."
    
        $SpiceworksLoginForm.Fields['pro_user[email]'] = $SpiceworksCredential.UserName
        $SpiceworksLoginForm.Fields['pro_user[password]'] = $SpiceworksCredential.GetNetworkCredential().Password
    
        $SpiceworksLoginResponse = Invoke-WebRequest -Uri $SpiceworksSession.GetURI("pro_users/login")  -SessionVariable "SpiceworksWebSession" -Method Post -Body $SpiceworksLoginForm -ContentType "application/x-www-form-urlencoded"
        If ($SpiceworksLoginResponse.Forms["login_form"]) {
            # Spiceworks sent us back to the login page. This usually means our credentials were bad.
            # Apparently not using -UseHTTPS could also break this...
            Throw [System.Net.WebException]("Spiceworks login page redirected to login page during login attempt. This is usually due to invalid credentials.")
        } Elseif (!$SpiceworksLoginResponse.Forms["community"]) {
            # Spiceworks didn't redirect to the dashboard. Something's wrong. Throw.
            Throw [System.Net.WebException]("Spiceworks response does not match the Spiceworks Dashboard.")
        }
    
        # Yay, we're logged in!
        Write-Verbose "Login appears successful. Finding authenticity token..."
        $SpiceworksDashboard = Invoke-WebRequest -Uri $SpiceworksSession.GetURI("dashboard") -WebSession $SpiceworksWebSession -Headers @{"Content-Type" = ""}
    
        $SpiceworksToken = $SpiceworksDashboard.InputFields | Where-Object Name -eq "authenticity_token" | Select-Object -First 1 | ForEach-Object Value
        Write-Verbose "Authenticity Token found: $SpiceworksToken"

        $SpiceworksSession.AuthenticityToken = $SpiceworksToken
        $SpiceworksSession.WebSession = $SpiceworksWebSession
        $SpiceworksSession.Username = $SpiceworksCredential.UserName
    
        return $SpiceworksSession
    }