# Import the Active Directory Module
Import-Module ActiveDirectory

$InactiveDaysOld = 30
$InactiveDaysNew = 15
$InactiveDays = 90
$UsersOU = 'OU=_USERS,DC=mydomain,DC=com'
$InactiveOU = 'OU=_INACTIVE,DC=mydomain,DC=com'

# Define inactivity threshold for the users
$DaysInactiveThresholdOld = (Get-Date).AddDays(-$InactiveDaysOld)
$DaysInactiveThresholdNew = (Get-Date).AddDays(-$InactiveDaysNew)

# Define the search parameters
$InactiveUsersParam = @{
     UsersOnly = $true
     SearchBase = $UsersOU
     AccountInactive = $true
}

# Find the inactive old and new users
$InactiveOldUsers = Search-ADAccount @InactiveUsersParam | Where-Object { $_.LastLogonDate -ne $null -and $_.LastLogonDate -lt $DaysInactiveThresholdOld }
$InactiveNewUsers = Search-ADAccount @InactiveUsersParam | Where-Object { $_.LastLogonDate -eq $null -and $_.WhenCreated -lt $DaysInactiveThresholdNew }

# Move inactive old and new users to the _INACTIVE OU and disable them
$InactiveOldUsers | Disable-ADAccount -PassThru
$InactiveOldUsers | Move-ADObject -TargetPath $InactiveOU
$InactiveNewUsers | Disable-ADAccount -PassThru
$InactiveNewUsers | Move-ADObject -TargetPath $InactiveOU

# Define the new search parameters
$SearchParam = @{
     UsersOnly = $true
     SearchBase = $InactiveOU
     AccountInactive = $true
     TimeSpan = $InactiveDays
}

# Remove the users from Inactive OU
$InactiveUsers = Search-ADAccount @SearchParam
$InactiveUsers | Remove-ADUser