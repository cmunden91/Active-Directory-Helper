$global:selected_ad_User = $null
function menu {
        param(
            [int]$menu_num = "0"
        )
        switch ($menu_num) {
            default {
                Write-Host "=================================="
                Write-Host "Active Directory Helper Main Menu"
                Write-Host "=================================="
                selectedUser
                Write-Host "=================================="
                Write-Host "1) Look up User"
                Write-Host "2) User Actions"
                Write-Host "c) Clear Selected User"
                Write-Host "q) Quit"
                $input = Read-Host "Please Make a Selection"
                switch($input) {
                    '1' {
                        menu(1)
                    }
                    '2' {
                        menu(2)
                    }
                    '3' {
                        if($null -eq $selected_ad_User) {
                            Write-Error "No User Selected"
                            menu(0)
                        }
                        else {
                            Write-Host ($selected_ad_User | Format-Table | Out-String)
                            menu(0)
                        }
                    }
                    'c' {
                        clearUser
                        menu
                    }
                    'q' {
                        clearUser
                        break
                    }
                    default {
                        menu
                    }
                }
            }
            '1' {
                Write-Host "=================================="
                Write-Host "Active Directory Helper Look up Menu"
                Write-Host "=================================="
                selectedUser
                Write-Host "=================================="
                Write-Host "1) Look up by User Name"
                Write-Host "2) Look up by Name"
                Write-Host "3) Look up by Email"
                Write-Host "4) Look up by Display Name"
                Write-Host "5) Look up by Phone Number"
                Write-Host "q) Return to Main Menu"
                $input = Read-Host "Please Make a Selection"
                switch($input) { 
                    default {
                        lookUpADUser($input)
                        menu(1)
                    }
                    'q' {
                      menu(0)  
                    }

                }
            }
            '2' {
                Write-Host "=================================="
                Write-Host "Active Directory Helper Action Menu"
                Write-Host "=================================="
                selectedUser
                Write-Host "=================================="
                Write-Host "1) Unlock Account"
                Write-Host "2) Reset Password"
                Write-Host "3) Disable Account"
                Write-Host "4) Enable Account"
                Write-Host "5) Delete Account"
                Write-Host "6) Create Account"
                Write-Host "q) Return to Main Menu"
                $input = Read-Host "Please Make a Selection"
                switch($input) {
                    "1" {
                        if($null -eq $selected_ad_User) {
                            Write-Error "No User Selected"
                            menu(2)
                        }
                        else {
                            Unlock-AdAccount -PassThru $selected_ad_User -Confirm
                            menu(2)
                        }
                    }
                    "2" {
                        if($null -eq $selected_ad_User) {
                            Write-Error "No User Selected"
                            menu(2)
                        }
                        else {
                            $newPassword = randomPassword:randomString
                            Set-AdAccountPassword -PassThru $selected_ad_User -Reset -NewPassword(ConvertTo-SecureString -asPlainText "$newPassword" -Force)
                            Set-AdUser -PassThru $selected_ad_User -ChangePasswordAtLogon $true
                            Write-Host "The new User Password is: " $newPassword " Please provide this to the user."
                            menu(2)
                        }
                    }
                    "q" {
                        menu(0)
                    }
                    default {
                        menu(2)
                    }
                }
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
    $specialCharacterArray = ('!','#','$','%','&','(',')','*','.','/',';','?','@','[',']','^','_','`','{','|','}','~','+','<','=','>')
    for($i=0; $i -lt $length; $i++) {
        $characterTypeRequirement = 4
        $characterType
        if($i -lt $characterTypeRequirement) {
            $characterType = $i
        }
        else {
            $characterType = Get-Random -Minimum -0 -Maximum 4
        }
        switch($characterType) {
            0 {
                $randomString = $randomString + (Get-Random -Minimum 0 -Maximum 10)
                Write-Host "I is: " $i "and String is" $randomString
            }
            1 {
                $randomString = $randomString + ($lowerCaseCharacterArray[(Get-Random -Minimum 0 -Maximum ($lowerCaseCharacterArray.length))])
                Write-Host "I is: " $i "and String is" $randomString
            }
            2 {
                $randomString = $randomString + ($upperCaseCharacterArray[(Get-Random -Minimum 0 -Maximum ($upperCaseCharacterArray.length))])
                Write-Host "I is: " $i "and String is" $randomString
            }
            3 {
                $randomString = $randomString + ($specialCharacterArray[(Get-Random -Minimum 0 -Maximum ($specialCharacterArray.length))])
                Write-Host "I is: " $i "and String is" $randomString
            }
        }
    }
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
        '1' {
            $input = Read-Host "Please Enter User Name"
            $result = Get-ADUser -Identity "$input" -Properties *
            selectUser($result)
        }
        '2' {
            $firstName = "*"
            $lastName = "*"
            $input = Read-Host "Please Enter First Name"
            if ($input -ne "") {$firstName = $input}
            $input = Read-Host "Please Enter Last Name"
            if ($input -ne "") {$lastName = $input}
            $result = Get-ADUser -Filter {GivenName -like $firstName -and Surname -like $lastName} -Properties *
            selectUser($result)
        }
        '3' {
            $input = Read-Host "Please Enter Email Address"
            $result = Get-ADUser -Filter {EmailAddress -like $input} -Properties *
            selectUser($result)
        }
        '4' {
            $input = Read-Host "Please Enter Display Name"
            $result = Get-ADUser -Filter {DisplayName -like $input} -Properties *
            selectUser($result)
        }
        '5' {
            $input = Read-Host "Please Enter Phone Number (Include Dashes: IE ###-###-####)"
            $result = Get-ADUser -Filter {TelephoneNumber -like $input} -Properties *
            selectUser($result)
        }

    }
}
function selectUser {
    param(
        [Object]$users
    )
    if($users -is [array]) {
        Write-Host "=================================="
        for ($i = 0; $i -lt $users.Length; $i++) {
            "#$i) User Name:" + $users[$i].SamAccountName + " Email Address:" + $users[$i].EmailAddress + " Display Name:" + $users[$i].DisplayName + " Full Name:" + $users[$i].GivenName + " " + $users[$i].Surname + " Phone Number:" + $users[$i].TelephoneNumber
        }
        Write-Host "#c) Cancel Selection"
        Write-Host "=================================="
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
            [Object]$global:selected_ad_User = [Object]$users[[int]$input]
        }
    }
    elseif($null -ne $users) {
        Write-Host "User" $users.SamAccountName "Selected."
        [Object]$global:selected_ad_User = [Object]$users
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
function clearUser {
    $global:selected_ad_User = $null
}
menu

#Get-AdUser -Filter 'Name -like "user*"' -Properties * | Format-Table SamAccountName,EmailAddress,DisplayName,GivenName,Surname,TelephoneNumber,memberOf