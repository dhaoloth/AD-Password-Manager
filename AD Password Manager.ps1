# Import the Active Directory module
Import-Module ActiveDirectory

# Function to authenticate an administrator
function Authenticate-Admin {
    param (
        [string]$GroupDN,    # Enter the Distinguished Name (DN) of the AD group for admin authentication
        [string]$Server      # Enter the AD server address
    )

    while ($true) {
        $adminCredential = Get-Credential -Message "Enter admin credentials"

        try {
            # Attempt authentication using provided credentials
            $adminUser = Get-ADUser -Identity $adminCredential.UserName -Server $Server -Credential $adminCredential -ErrorAction Stop

            # Check group membership
            $isMember = Get-ADGroupMember -Identity $GroupDN -Server $Server -Credential $adminCredential | Where-Object { $_.SamAccountName -eq $adminCredential.UserName }

            if ($isMember) {
                Write-Host "Authentication successful."
                return $adminCredential
            } else {
                Write-Host "Authentication failed."
            }
        } catch {
            Write-Host "Authentication error. Please try again."
        }
    }
}

# Function to generate a secure random password
function Generate-Password {
    param (
        [int]$length = 12  # Default password length
    )

    if ($length -lt 8) {
        throw "Password length should be at least 8 characters."
    }

    # Define character sets
    $lowercase = "abcdefghijklmnopqrstuvwxyz"
    $uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    $digits = "0123456789"
    $specialChars = "!@#$%^&*()-_=+[]{}|;:,.<>?/`~"

    # Combine all character sets
    $allChars = $lowercase + $uppercase + $digits + $specialChars

    # Create a secure random number generator
    $cryptoProvider = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
    $byteArray = New-Object byte[] $length
    $cryptoProvider.GetBytes($byteArray)

    # Generate the password
    $password = -join ((0..($length - 1)) | ForEach-Object {
        $index = [math]::Abs([BitConverter]::ToUInt32($byteArray, $_ * 4)) % $allChars.Length
        $allChars[$index]
    })

    # Ensure the password meets complexity requirements
    if ($password -notmatch "[a-z]") { $password += $lowercase[0] }
    if ($password -notmatch "[A-Z]") { $password += $uppercase[0] }
    if ($password -notmatch "\d") { $password += $digits[0] }
    if ($password -notmatch "[!@#$%^&*()\-_=+[\]{}|;:,.<>?/`~]") { $password += $specialChars[0] }

    # Shuffle the password characters
    $password = -join ($password.ToCharArray() | Sort-Object { [System.Guid]::NewGuid() })

    return $password
}

# Function to send an email with a signature
function Send-Email {
    param (
        [string]$To,
        [string]$Subject,
        [string]$Body,
        [string]$Signature
    )
    $Outlook = New-Object -ComObject Outlook.Application
    $Mail = $Outlook.CreateItem(0)
    $Mail.To = $To
    $Mail.Subject = $Subject
    $Mail.BodyFormat = [Microsoft.Office.Interop.Outlook.OlBodyFormat]::olFormatHTML
    $Mail.HTMLBody = "<html><body style='font-family: 'Times New Roman', Times, serif; font-size: 12pt;'>$Body<br><br>$Signature</body></html>"
    $Mail.Send()
}

# Function to log password changes
function Log-PasswordChange {
    param (
        [string]$AdminFullName,
        [string]$TargetUserLogin,
        [string]$TargetUserFullName,
        [string]$Time,
        [string]$LogPath   # Path to store the log file (ensure you have write permissions)
    )
    $logPath = $LogPath
    $logContent = @"
    <html>
    <head>
        <title>Password Change Report</title>
    </head>
    <body>
        <h1>Password Change Report for $(Get-Date -Format 'dd.MM.yyyy')</h1>
        <table border="1">
            <tr>
                <th>Administrator (Full Name)</th>
                <th>Target User Login</th>
                <th>Target User Full Name</th>
                <th>Operation Time</th>
            </tr>
"@

    if (Test-Path $logPath) {
        $logContent = Get-Content $logPath -Raw
        $logContent = $logContent -replace '</table>', ''
        $logContent = $logContent -replace '</body>', ''
        $logContent = $logContent -replace '</html>', ''
    }

    $logContent += @"
    <tr>
        <td>$AdminFullName</td>
        <td>$TargetUserLogin</td>
        <td>$TargetUserFullName</td>
        <td>$Time</td>
    </tr>
        </table>
    </body>
    </html>
"@

    $logContent | Set-Content $logPath
}

# Prompt for necessary configurations
$GroupDN = Read-Host "Enter the Distinguished Name (DN) of the AD group for admin authentication (e.g., 'CN=HelpDeskIT_Groups,OU=Global_Groups,DC=example,DC=com')"
$Server = Read-Host "Enter the AD server address (e.g., 'ad.example.com')"
$LogPath = Read-Host "Enter the path to store the log file (e.g., 'C:\Logs\PasswordChangeReports\PasswordChanges.html')"

# Authenticate the administrator
$credential = Authenticate-Admin -GroupDN $GroupDN -Server $Server

# Get the full name of the administrator
$adminUser = Get-ADUser -Identity $credential.UserName -Properties DisplayName -Credential $credential
$adminFullName = $adminUser.DisplayName

# Signature template
$signatureTemplate = "Best regards,<br>$adminFullName"

do {
    # Prompt for the login of the first target user
    do {
        $targetUserLogin = Read-Host "Enter the login of the user to reset the password for"
        $targetUser = Get-ADUser -Identity $targetUserLogin -Credential $credential -Properties Surname, DisplayName -ErrorAction SilentlyContinue
        if (-not $targetUser) {
            Write-Host "Login not found. Please try again."
        }
    } while (-not $targetUser)

    # Prompt to generate a password automatically
    $generatePassword = Read-Host "Generate password automatically? (y/n)"

    if ($generatePassword -eq "y") {
        # Generate a new password
        $newPassword = Generate-Password
    } else {
        # Prompt for password manually
        $newPassword = Read-Host "Enter the new password"
    }

    # Change the user password
    Set-ADAccountPassword -Identity $targetUser -NewPassword (ConvertTo-SecureString -String $newPassword -AsPlainText -Force) -Reset -Credential $credential

    # Prompt for the email of the second target user
    do {
        $secondUserEmail = Read-Host "Enter the email of the user to notify about the password change"
        $secondUserLogin = $secondUserEmail.Split('@')[0]
        $secondUser = Get-ADUser -Identity $secondUserLogin -Credential $credential -Properties GivenName, DisplayName -ErrorAction SilentlyContinue
        if (-not $secondUser) {
            Write-Host "Email not found. Please try again."
        }
    } while (-not $secondUser)

    # Get the surname of the first target user
    $targetUserSurname = $targetUser.Surname

    # Get the given name of the second target user
    $secondUserGivenName = $secondUser.GivenName

    # Create email body
    $emailBody = "$($secondUserGivenName), good day!<br><br>New credentials for user $($targetUser.DisplayName): $newPassword"

    # Send the email
    $emailSubject = "Password Change for '$targetUserSurname'"
    Send-Email -To $secondUserEmail -Subject $emailSubject -Body $emailBody -Signature $signatureTemplate

    Write-Host "Password successfully changed and email sent."

    # Log the password change
    $currentTime = Get-Date -Format "HH:mm"
    Log-PasswordChange -AdminFullName $adminFullName -TargetUserLogin $targetUserLogin -TargetUserFullName $targetUser.DisplayName -Time $currentTime -LogPath $LogPath

    # Ask if another password change is needed
    $continue = Read-Host "Is another password change needed? (y/n)"
} while ($continue -eq "y")

Write-Host "Script execution completed."
