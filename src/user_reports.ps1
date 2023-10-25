# Import the Active Directory Module
Import-Module ActiveDirectory

# Specify OU and file path
$UsersOU = 'OU=_USERS,DC=mydomain,DC=com'

$CurrentDate = Get-Date -Format 'dd-MM-yyyy_HH-mm-ss'
$FilePath = "C:\ADReports\User-Reports\User_Report_$CurrentDate.csv"

# Specify attributes and the filters to include in the search
$Attributes = 'SamAccountName', 'GivenName', 'Surname', 'DisplayName', 'Title', 'Department'
$DepartmentFilter = ".*"

# Create a user report
Get-ADUser -Filter * -SearchBase $UsersOU -Properties $Attributes |
Where-Object { $_.Department -match $DepartmentFilter } |
Select-Object -Property $Attributes |
Export-Csv $FilePath -NoTypeInformation

Write-Host "User report exported to: $FilePath"
