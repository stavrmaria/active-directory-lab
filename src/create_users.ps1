# Import the Active Directory Module
Import-Module ActiveDirectory

# Define the .csv file and import the user data
$UserData = Import-Csv "users_data.csv"

foreach ($User in $UserData) {
    $FirstName = $User.FirstName
    $LastName = $User.LastName
    $JobTitle = $User.JobTitle
    $SamAccountName = $User.SamAccountName
    $DisplayName = $User.DisplayName
    $Department = $User.Department
    $OUPath = "OU=$Department, OU=_USERS, DC=mydomain, DC=com"
    $DefaultPassword = (ConvertTo-SecureString "P@sswOrd1" -AsPlainText -Force)

    # Check whether or not the user exists
    $Exists = Get-ADUser -Filter {SamAccountName -eq $SamAccountName}
    if ($Exists) {
        Write-Warning "User $SamAccountName already exists in Active Directory."
        continue
    }

    $NewUser = @{
        SamAccountName = $SamAccountName
        GivenName = $FirstName
        Surname = $LastName
        Name = "$FirstName $LastName"
        DisplayName = $DisplayName
        Title = $JobTitle
        Department = $Department
        Path = $OUPath
        AccountPassword = (ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force)
        Enabled = $true
        ChangePasswordAtLogon = $true
    }

    try {
        # Create a new AD user
        New-ADUser @NewUser
        Write-Host "User $SamAccountName created successfully." -ForegroundColor Green
    } catch {
        Write-Warning "Failed to create user $SamAccountName."
    }
}