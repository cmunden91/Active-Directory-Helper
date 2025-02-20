$ad_Identity = ""
$ad_FirstName = ""
$ad_LastName = ""
$ad_PhoneNumber =""
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
                    'c' {
                        clearUser
                        menu
                    }
                    'q' {
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
                Write-Host "2) Look up by Phone Number"
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
        }
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
        }
        '2' {
            $input = Read-Host "Please Enter Name"
        }
        '3' {
            $input = Read-Host "Please Enter Phone Number"
        }

    }
}

function selectedUser {
    if (($ad_Identity -eq "") -and ($ad_FirstName -eq "") -and ($ad_LastName -eq "") -and ($ad_PhoneNumber -eq "")) {
        Write-Host "No User Selected"
    }
    else {
        Write-Host "User Selected = User Name:'$ad_Identity' Name:'$ad_FirstName $ad_LastName' Phone Number:'$ad_PhoneNumber'"
    }
}
function clearUser {
    $global:ad_Identity = ""
    $global:ad_FirstName = ""
    $global:ad_LastName = ""
    $global:ad_PhoneNumber = ""
}
menu