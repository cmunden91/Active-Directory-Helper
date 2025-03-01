function adhMain {
    $script:selected_ad_User = $null
    function mainMenu {
        Clear-Host
        spacer
        Write-Host "Active Directory Helper Main Menu"
        spacer
        selectedUser
        spacer
        Write-Host "1) Look up User"
        Write-Host "2) User Actions"
        Write-Host "c) Clear Selected User"
        Write-Host "q) Quit"
        $input = Read-Host "Please Make a Selection"
        switch ($input) {
            '1' {
                lookUpMenu
            }
            '2' {
                actionMenu
            }
            '3' {
                if ($null -eq $selected_ad_User) {
                    Write-Error "No User Selected"
                    mainMenu
                }
                else {
                    Write-Host ($selected_ad_User | Format-Table | Out-String)
                    mainMenu
                }
            }
            'c' {
                clearUser
                mainMenu
            }
            'q' {
                break
            }
            default {
                mainMenu
            }
        }
    }
    function actionMenu {
        Clear-Host
        spacer
        Write-Host "Active Directory Helper Action Menu"
        spacer
        selectedUser
        spacer
        Write-Host "1) Unlock Account"
        Write-Host "2) Reset Password"
        Write-Host "3) Disable Account"
        Write-Host "4) Enable Account"
        Write-Host "5) Delete Account"
        Write-Host "6) Create Account"
        Write-Host "7) Quick Diagnosis"
        Write-Host "q) Return to Main Menu"
        $input = Read-Host "Please Make a Selection"
        switch ($input) {
            "1" {
                if ($null -eq $selected_ad_User) {
                    Write-Error "No User Selected"
                    actionMenu
                }
                else {
                    Unlock-AdAccount -Identity $selected_ad_User -Confirm
                    selectUser(Get-ADUser -Identity $selected_ad_User)
                    actionMenu
                }
            }
            "2" {
                if ($null -eq $selected_ad_User) {
                    Write-Error "No User Selected"
                    actionMenu
                }
                else {
                    [String]$newPassword = randomPassword
                    $newPassword = $newPassword.replace(' ', '')
                    Set-AdAccountPassword -Identity $selected_ad_User -Reset -NewPassword(ConvertTo-SecureString -asPlainText "$newPassword" -Force)
                    Set-AdUser -Identity $selected_ad_User -ChangePasswordAtLogon $true
                    Write-Host "The new User Password is:" $newPassword "Please provide this to the user."
                    Read-Host -Prompt "Press any key to continue or CTRL+C to quit" | Out-Null
                    actionMenu
                }
            }
            "3" {
                if ($null -eq $selected_ad_User) {
                    Write-Error "No User Selected"
                    actionMenu
                }
                else {
                    Disable-ADAccount -Identity $selected_ad_User -Confirm
                    selectUser(Get-ADUser -Identity $selected_ad_User)
                    actionMenu
                }
            }
            "4" {
                if ($null -eq $selected_ad_User) {
                    Write-Error "No User Selected"
                    actionMenu
                }
                else {
                    Enable-ADAccount -Identity $selected_ad_User -Confirm
                    selectUser(Get-ADUser -Identity $selected_ad_User)
                    actionMenu
                }
            }
            "5" {
                if ($null -eq $selected_ad_User) {
                    Write-Error "No User Selected"
                    actionMenu
                }
                else {
                    Remove-ADUser -Identity $selected_ad_User -Confirm
                    clearUser
                    actionMenu
                }
            }
            "6" {
                [String]$newPassword = randomPassword
                $newPassword = $newPassword.replace(' ', '')
                $newUser = @{
                    Name            = Read-Host "Please Enter User Name"
                    AccountPassword = ConvertTo-SecureString -asPlainText $newPassword -Force
                    GivenName       = Read-Host "Please Enter First Name"
                    Surname         = Read-Host "Please Enter Last Name"
                    DisplayName     = Read-Host "Please Enter Display Name"
                    EmailAddress    = Read-Host "Please Enter Email"
                    homePhone       = Read-Host "Please Enter Phone Number (Format: ###-###-####)"
                    EmployeeID      = Read-Host "Please Enter Employee ID"
                }
                New-ADUser @newUser
                Write-Host "New User Password is: " $newPassword ". Please provide it to them."
                Read-Host -Prompt "Press any key to continue or CTRL+C to quit" | Out-Null
                selectUser(Get-ADUser -Identity $newUser.Name)
                $enable = Read-Host "Would you like to enable the account? y/n"
                if (($enable -eq "y" -or $enable -eq "Y")) { Enable-ADAccount -Identity $selected_ad_User }
                actionMenu
            }
            "7" {
                if ($null -eq $selected_ad_User) {
                    Write-Error "No User Selected"
                    actionMenu
                }
                else {
                    Write-Host "The account is currently:"
                    if ($selected_ad_User.LockedOut) { Write-Host "IS locked out." } else { Write-Host "NOT locked out." }
                    if ($selected_ad_User.Enabled) { Write-Host "Is ENABLED." } else { Write-Host "Is DISABLED." }
                    if ($selected_ad_User.isDeleted) { Write-Host "IS Deleted." } else { Write-Host "Is NOT Deleted." }
                    $timeZone = Get-TimeZone
                    Write-Host "The Accounts last login was: "$selected_ad_User.LastLogonDate $timeZone.DisplayName"."
                    Write-Host "The Accounts last login attempt was:"$selected_ad_User.LastBadPasswordAttempt $timeZone.DisplayName"."
                    actionMenu
                }
            }
            "q" {
                mainMenu
            }
            default {
                actionMenu
            }
        }
    }
    function lookUpMenu {
        Clear-Host
        spacer
        Write-Host "Active Directory Helper Look up Menu"
        spacer
        selectedUser
        spacer
        Write-Host "1) Look up by User Name (exact)"
        Write-Host "2) Look up by User Name"
        Write-Host "3) Look up by Name"
        Write-Host "4) Look up by Email"
        Write-Host "5) Look up by Display Name"
        Write-Host "6) Look up by Phone Number"
        Write-Host "7) Look up by Employee ID"
        Write-Host "q) Return to Main Menu"
        $input = Read-Host "Please Make a Selection"
        switch ($input) { 
            default {
                lookUpMenu
            }
            '1' {
                $input = Read-Host "Please Enter User Name"
                $result = Get-ADUser -Identity "$input" -Properties *
                selectUser($result)
                lookUpMenu
            }
            '2' {
                $username = "*"
                $input = Read-Host "Please Enter User Name"
                if ($input -ne "") { $username = $input }
                $result = Get-ADUser -Filter { SamAccountName -like $username } -Properties *
                selectUser($result)
                lookUpMenu
            }
            '3' {
                $firstName = "*"
                $lastName = "*"
                $input = Read-Host "Please Enter First Name"
                if ($input -ne "") { $firstName = $input }
                $input = Read-Host "Please Enter Last Name"
                if ($input -ne "") { $lastName = $input }
                $result = Get-ADUser -Filter { GivenName -like $firstName -and Surname -like $lastName } -Properties *
                selectUser($result)
                lookUpMenu
            }
            '4' {
                $email = "*"
                $input = Read-Host "Please Enter Email Address"
                if ($input -ne "") { $email = $input }
                $result = Get-ADUser -Filter { EmailAddress -like $email } -Properties *
                selectUser($result)
                lookUpMenu
            }
            '5' {
                $displayName = "*"
                $input = Read-Host "Please Enter Display Name"
                if ($input -ne "") { $displayName = $input }
                $result = Get-ADUser -Filter { DisplayName -like $displayName } -Properties *
                selectUser($result)
                lookUpMenu
            }
            '6' {
                $phoneNumber = "*"
                $input = Read-Host "Please Enter Phone Number (Include Dashes: IE ###-###-####)"
                if ($input -ne "") { $phoneNumber = $input }
                $result = Get-ADUser -Filter { TelephoneNumber -like $phoneNumber } -Properties *
                selectUser($result)
                lookUpMenu
            }
            '7' {
                $employeeID = "*"
                $input = Read-Host "Please Enter Employee ID"
                if ($input -ne "") { $employeeID = $input }
                $result = Get-ADUser -Filter { EmployeeID -like $employeeID } -Properties *
                selectUser($result)
                lookUpMenu
            }
            'q' {
                mainMenu  
            }

        }
    }
    function randomPassword {
        param (
            [int]$length = 10
        )
        $randomString = ""
        $lowerCaseCharacterArray = ('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z')
        $upperCaseCharacterArray = ('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z')
        $specialCharacterArray = ('!', '#', '$', '%', '&', '(', ')', '*', '.', '/', ';', '?', '@', '[', ']', '^', '_', '`', '{', '|', '}', '~', '+', '<', '=', '>')
        for ($i = 0; $i -lt $length; $i++) {
            $characterTypeRequirement = 4
            $characterType
            if ($i -lt $characterTypeRequirement) {
                $characterType = $i
            }
            else {
                $characterType = Get-Random -Minimum -0 -Maximum 4
            }
            switch ($characterType) {
                0 {
                    $randomString = $randomString + (Get-Random -Minimum 0 -Maximum 10)
                }
                1 {
                    $randomString = $randomString + ($lowerCaseCharacterArray[(Get-Random -Minimum 0 -Maximum ($lowerCaseCharacterArray.length))])
                }
                2 {
                    $randomString = $randomString + ($upperCaseCharacterArray[(Get-Random -Minimum 0 -Maximum ($upperCaseCharacterArray.length))])
                }
                3 {
                    $randomString = $randomString + ($specialCharacterArray[(Get-Random -Minimum 0 -Maximum ($specialCharacterArray.length))])
                }
            }
            Clear-Variable characterType
        }
        Clear-Variable lowerCaseCharacterArray
        Clear-Variable upperCaseCharacterArray
        Clear-Variable specialCharacterArray
        Clear-Variable characterType
        return $randomString
    }
    function lookUpADUser {
        param (
            [int]$lookup_type
        )
        switch ($lookup_type) {
            default {
                Write-Host "Invalid Lookup Type"
            }

        }
    }
    function selectUser {
        param(
            [Object]$users
        )
        if ($users -is [array]) {
            Clear-Host
            spacer
            for ($i = 0; $i -lt $users.Length; $i++) {
                "#$i) User Name:" + $users[$i].SamAccountName + " Email Address:" + $users[$i].EmailAddress + " Display Name:" + $users[$i].DisplayName + " Full Name:" + $users[$i].GivenName + " " + $users[$i].Surname + " Phone Number:" + $users[$i].TelephoneNumber
            }
            Write-Host "#c) Cancel Selection"
            spacer
            $input = Read-Host "Please Select User:"
            if ($input -eq "c") {
                break
            }
            elseif ([int]$input -lt 0 -or [int]$input -gt $users.Length) {
                Write-Error "Invalid Selection, Please try again"
                selectUser($users)
            }
            else {
                Write-Host "User" $users[[int]$input].SamAccountName "Selected."
                [Object]$script:selected_ad_User = [Object]$users[[int]$input]
            }
        }
        elseif ($null -ne $users) {
            Write-Host "User" $users.SamAccountName "Selected."
            [Object]$script:selected_ad_User = [Object]$users
        }
        else {
            Write-Host "No User Found."
        }
    }
    function selectedUser {
        if ($null -eq $selected_ad_User) {
            Write-Host "No User Selected"
        }
        else {
            "User Selected = User Name: " + $selected_ad_User.SamAccountName + " Full Name: " + $selected_ad_User.GivenName + " " + $selected_ad_User.Surname + " Phone Number: " + $selected_ad_User.TelephoneNumber
        }
    }
    function spacer {
        Write-Host "=================================="
    }
    function clearUser {
        $script:selected_ad_User = $null
    }
    mainMenu
}
adhMain
Clear-Host