# Bitlocker Check for SolarWinds RMM
#
# --- SOFTWARE SUPPORT, SUITABILITY AND DAMAGES DISCLAIMER ---
# The sample scripts provided here are not supported under any standard
# any kind. I further disclaim all implied warranties including, without
# limitation, any implied warranties of merchantability or of fitness for a
# particular purpose. The entire risk arising out of the use or performance of the
# sample scripts and documentation remains with you. In no event shall I,
# its authors, or anyone else involved in the creation, production, or delivery of
# the scripts be liable for any damages whatsoever (including, without limitation,
# damages for loss of business profits, business interruption, loss of business
# information, or other pecuniary loss) arising out of the use of or inability to
# use the sample scripts or documentation, even if I have been advised of
# the possibility of such damages.
# Furthermore these scripts were not developed by, and therefore not supported
# by, SolarWinds or SolarWinds MSP.

$wmiDomain = Get-WmiObject Win32_NTDomain -Filter "DnsForestName = '$( (Get-WmiObject Win32_ComputerSystem).Domain)'"
$domain = $wmiDomain.DomainName
$EncryptionStatus = 0
$BitLockerStatus = 0
$EncryptionStatusText = "Null"
$BitLockerStatusText = "Null"

#Get Bitlocker status
$OutputVariable = (powershell {Get-BitlockerVolume -MountPoint "C:" -ErrorAction SilentlyContinue -ErrorVariable BitLockerError -OutVariable $FullOutput})

#If command fails return error that Bitlocker is not installed
If ($BitLockerError)
  {
  Write-Host("FAILED")
  Write-Host("-- Bitlocker Not Installed")
  Exit 1001
  }

#Check results of Bitlocker status
If ($OutputVariable.protectionstatus -like "Off")
  {
  $BitLockerStatusText = "OFF"
  $BitLockerStatus = 0
  }
Else
  {
  $BitLockerStatusText = "ON"
  $BitLockerStatus = 1
  }

#Check results of Bitlocker encryption status
If ($OutputVariable.volumestatus -like "FullyEncrypted")
  {
  $EncryptionStatusText = "Success: C: is Fully Encrypted"
  $EncryptionStatus = 1
  }
ElseIf ($OutputVariable.volumestatus -NotLike "FullyEncrypted")
  {
  $EncryptionStatusText = "WARNING: C: is NOT Fully Encrypted"
  $EncryptionStatus = 0
  }

#Output Pass/Fail and More Information to dashboard
If (($BitLockerStatus + $EncryptionStatus) -gt 0)
  {
    Write-Host("SUCCESS")
    Write-Host("-- Bitlocker Status: "+$BitLockerStatusText)
    Write-Host("-- Encryption Status: "+$EncryptionStatusText)
    Write-Host("FULL OUTPUT")
    Write-Host($FullOutput)
    Exit 0
  }
Else
  {
    Write-Host("FAILED")
    Write-Host("-- Bitlocker Status: "+$BitLockerStatusText)
    Write-Host("-- Encryption Status: "+$EncryptionStatusText)
    Write-Host("FULL OUTPUT")
    Write-Host($FullOutput)
    Exit 1001
  }
