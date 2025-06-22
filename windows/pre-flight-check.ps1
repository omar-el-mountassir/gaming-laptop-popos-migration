# Pop!_OS Pre-Flight Check Script v2.0
# Run as Administrator: powershell -ExecutionPolicy Bypass -File pre-flight-check.ps1
# This script validates your system readiness for Pop!_OS migration

$ErrorActionPreference = "Continue"
$report = @{
    Timestamp = Get-Date
    System = @{}
    Blockers = @()
    Warnings = @()
    GreenLights = @()
}

Write-Host "=== Pop!_OS Pre-Flight Validation v2.0 ===" -ForegroundColor Cyan
Write-Host "Hardware-Verified Edition" -ForegroundColor Yellow
Write-Host "Generating compatibility report..." -ForegroundColor Yellow

# 1. BitLocker Check (BLOCKER if enabled)
Write-Host "`nChecking BitLocker status..." -NoNewline
$bitlocker = Get-BitLockerVolume -MountPoint C: -ErrorAction SilentlyContinue
if ($bitlocker.ProtectionStatus -eq "On") {
    $report.Blockers += "❌ BitLocker is ACTIVE on C: drive - MUST disable before dual boot"
    Write-Host " BLOCKER!" -ForegroundColor Red
} else {
    $report.GreenLights += "✅ BitLocker is disabled"
    Write-Host " OK" -ForegroundColor Green
}

# 2. Fast Startup Check
Write-Host "Checking Fast Startup..." -NoNewline
$fastStartup = powercfg /a | Select-String "Fast startup"
if ($fastStartup -match "available") {
    $report.Warnings += "⚠️ Fast Startup is enabled - must disable for dual boot"
    Write-Host " WARNING" -ForegroundColor Yellow
} else {
    $report.GreenLights += "✅ Fast Startup already disabled"
    Write-Host " OK" -ForegroundColor Green
}

# 3. System Integrity
Write-Host "Checking Windows system integrity..." -NoNewline
$sfcResult = sfc /verifyonly 2>&1 | Select-String "found integrity violations"
if ($sfcResult) {
    $report.Warnings += "⚠️ Windows system files need repair - run 'sfc /scannow'"
    Write-Host " ISSUES FOUND" -ForegroundColor Yellow
} else {
    $report.GreenLights += "✅ Windows system files intact"
    Write-Host " OK" -ForegroundColor Green
}

# 4. Disk Space Analysis
Write-Host "Analyzing disk space..." -NoNewline
$drives = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Used -ne $null}
$targetDrive = $null

foreach ($drive in $drives) {
    $freeGB = [math]::Round($drive.Free/1GB, 2)
    if ($freeGB -gt 400) {
        $targetDrive = $drive
        $report.GreenLights += "✅ Drive $($drive.Name): has $freeGB GB free (suitable for Linux)"
        Write-Host " OK" -ForegroundColor Green
        break
    }
}

if (-not $targetDrive) {
    $report.Blockers += "❌ No drive has 400GB+ free space for Pop!_OS installation"
    Write-Host " INSUFFICIENT" -ForegroundColor Red
}

# 5. NVMe Health Check (Modern Approach)
Write-Host "Checking NVMe drive health..." -NoNewline
$driveHealth = Get-PhysicalDisk | Where-Object {$_.MediaType -eq "SSD"}
$allHealthy = $true
$nvmeWarnings = @()

foreach ($disk in $driveHealth) {
    if ($disk.HealthStatus -ne "Healthy") {
        $allHealthy = $false
        $report.Blockers += "❌ Drive health issue detected: $($disk.FriendlyName) - $($disk.HealthStatus)"
    }
    
    # Check NVMe specific metrics
    $smartData = Get-StorageReliabilityCounter -PhysicalDisk $disk -ErrorAction SilentlyContinue
    
    if ($smartData) {
        # Check wear level
        if ($smartData.Wear -gt 10) {
            $nvmeWarnings += "NVMe wear level: $($smartData.Wear)%"
        }
        # Check temperature
        if ($smartData.Temperature -gt 70) {
            $nvmeWarnings += "NVMe temperature high: $($smartData.Temperature)°C"
        }
    }
}

if ($allHealthy -and $nvmeWarnings.Count -eq 0) {
    $report.GreenLights += "✅ All NVMe drives report excellent health"
    Write-Host " EXCELLENT" -ForegroundColor Green
} elseif ($allHealthy) {
    $report.Warnings += "⚠️ NVMe health notes: $($nvmeWarnings -join ', ')"
    Write-Host " OK (with notes)" -ForegroundColor Yellow
} else {
    Write-Host " ISSUES DETECTED!" -ForegroundColor Red
}

# 6. TRIM Support Check
Write-Host "Checking TRIM support..." -NoNewline
$trimEnabled = fsutil behavior query DisableDeleteNotify
if ($trimEnabled -match "= 0") {
    $report.GreenLights += "✅ TRIM is enabled for SSDs"
    Write-Host " OK" -ForegroundColor Green
} else {
    $report.Warnings += "⚠️ TRIM not enabled - run: fsutil behavior set DisableDeleteNotify 0"
    Write-Host " NOT ENABLED" -ForegroundColor Yellow
}

# 7. Display Configuration Check
Write-Host "Checking display configuration..." -NoNewline
$displays = Get-WmiObject -Namespace root\wmi -Class WmiMonitorID -ErrorAction SilentlyContinue | ForEach-Object {
    $name = ($_.UserFriendlyName | ForEach-Object {[char]$_}) -join ''
    $serial = ($_.SerialNumberID | ForEach-Object {[char]$_}) -join ''
    "$name ($serial)"
}
$report.System.Displays = $displays
if ($displays.Count -ge 1) {
    $report.GreenLights += "✅ Detected $($displays.Count) display(s)"
    Write-Host " OK" -ForegroundColor Green
}

# 8. Audio Devices Check
Write-Host "Checking audio devices..." -NoNewline
$audioDevices = Get-WmiObject Win32_SoundDevice | Select-Object Name, Status
$report.System.AudioDevices = $audioDevices
if ($audioDevices.Count -gt 4) {
    $report.Warnings += "⚠️ Complex audio setup detected ($($audioDevices.Count) devices) - will need configuration"
    Write-Host " COMPLEX ($($audioDevices.Count) devices)" -ForegroundColor Yellow
} else {
    Write-Host " OK" -ForegroundColor Green
}

# 9. Network Adapters Verification
Write-Host "Checking network adapters..." -NoNewline
$netAdapters = Get-NetAdapter | Where-Object {$_.Status -eq 'Up'}
$report.System.NetworkAdapters = $netAdapters | Select-Object Name, InterfaceDescription, MacAddress
Write-Host " OK" -ForegroundColor Green

# 10. USB & Thunderbolt Devices Check
Write-Host "Checking USB and Thunderbolt devices..." -NoNewline
$usbDevices = Get-PnpDevice -Class USB -PresentOnly | 
    Where-Object {$_.Status -eq 'OK'} |
    Select-Object FriendlyName, DeviceID

$thunderboltDevices = Get-PnpDevice | 
    Where-Object {$_.FriendlyName -match "Thunderbolt"} |
    Select-Object FriendlyName, DeviceID, Status

$report.System.USBDevices = $usbDevices
$report.System.ThunderboltDevices = $thunderboltDevices

if ($thunderboltDevices.Count -gt 0) {
    $report.GreenLights += "✅ Thunderbolt controller detected"
}
Write-Host " OK" -ForegroundColor Green

# 11. BIOS/UEFI Information
Write-Host "Checking BIOS information..." -NoNewline
$bios = Get-WmiObject Win32_BIOS
$report.System.BIOS = @{
    Version = $bios.SMBIOSBIOSVersion
    ReleaseDate = $bios.ReleaseDate
    Manufacturer = $bios.Manufacturer
}
Write-Host " OK" -ForegroundColor Green

# 12. Critical Drivers Backup
Write-Host "Documenting critical drivers..."
$report.System.Drivers = Get-WmiObject Win32_PnPSignedDriver | 
    Where-Object {$_.DeviceName -match "Network|Display|Storage|Audio|Thunderbolt"} |
    Select-Object DeviceName, DriverVersion, DriverDate |
    Sort-Object DeviceName

# Generate HTML Report
$html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Pop!_OS Pre-Flight Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #333; border-bottom: 3px solid #48B9C7; padding-bottom: 10px; }
        h2 { color: #48B9C7; margin-top: 30px; }
        .blocker { color: red; font-weight: bold; padding: 10px; background: #ffe5e5; border-radius: 5px; margin: 5px 0; }
        .warning { color: #ff6600; padding: 10px; background: #fff5e5; border-radius: 5px; margin: 5px 0; }
        .success { color: green; padding: 10px; background: #e5ffe5; border-radius: 5px; margin: 5px 0; }
        .section { margin: 20px 0; padding: 20px; background: #f9f9f9; border-radius: 8px; }
        .hardware-info { background: #e3f2fd; padding: 15px; border-radius: 5px; margin: 10px 0; }
        table { border-collapse: collapse; width: 100%; margin-top: 10px; }
        td, th { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background: #f0f0f0; font-weight: bold; }
        .highlight { background: #fffacd; padding: 2px 5px; border-radius: 3px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Pop!_OS Migration Pre-Flight Report</h1>
        <p><strong>Generated:</strong> $($report.Timestamp)</p>
        <p><strong>Target:</strong> Pop!_OS 22.04 LTS (Dual Boot)</p>
        
        <div class="hardware-info">
            <h3>🖥️ System Overview</h3>
            <p><strong>BIOS:</strong> $($report.System.BIOS.Version) ($($report.System.BIOS.Manufacturer))</p>
            <p><strong>Displays:</strong> $($report.System.Displays.Count) detected</p>
            <p><strong>Audio Devices:</strong> $($report.System.AudioDevices.Count)</p>
            <p><strong>Network Adapters:</strong> $($report.System.NetworkAdapters.Count)</p>
        </div>
        
        <div class="section">
            <h2>🚫 Blockers (Must Fix)</h2>
            $(($report.Blockers | ForEach-Object {"<p class='blocker'>$_</p>"}) -join "")
            $(if ($report.Blockers.Count -eq 0) {"<p class='success'>✅ No blockers detected!</p>"})
        </div>
        
        <div class="section">
            <h2>⚠️ Warnings (Should Address)</h2>
            $(($report.Warnings | ForEach-Object {"<p class='warning'>$_</p>"}) -join "")
            $(if ($report.Warnings.Count -eq 0) {"<p class='success'>✅ No warnings!</p>"})
        </div>
        
        <div class="section">
            <h2>✅ Green Lights</h2>
            $(($report.GreenLights | ForEach-Object {"<p class='success'>$_</p>"}) -join "")
        </div>
        
        <div class="section">
            <h2>📊 System Information</h2>
            <p>Full hardware details saved to: PopOS-PreFlight-SystemInfo.json</p>
        </div>
        
        <div class="section" style="background: #e8f5e9;">
            <h2>🎯 Next Steps</h2>
            <ol>
                <li>Address any blockers (red items) first</li>
                <li>Consider fixing warnings (orange items)</li>
                <li>Create full disk image backup</li>
                <li>Download Pop!_OS 22.04 LTS NVIDIA ISO</li>
                <li>Create bootable USB with Rufus</li>
                <li>Proceed with installation when ready!</li>
            </ol>
        </div>
    </div>
</body>
</html>
"@

$reportPath = "$env:USERPROFILE\Desktop\PopOS-PreFlight-Report.html"
$html | Out-File -FilePath $reportPath -Encoding UTF8
$report | ConvertTo-Json -Depth 4 | Out-File "$env:USERPROFILE\Desktop\PopOS-PreFlight-SystemInfo.json"

# Final Decision
Write-Host "`n=== FINAL DECISION ===" -ForegroundColor Cyan
if ($report.Blockers.Count -gt 0) {
    Write-Host "❌ BLOCKED: Fix all blockers before proceeding!" -ForegroundColor Red
    Write-Host "Blockers found: $($report.Blockers.Count)" -ForegroundColor Red
} elseif ($report.Warnings.Count -gt 0) {
    Write-Host "⚠️ PROCEED WITH CAUTION: Address warnings first" -ForegroundColor Yellow
    Write-Host "Warnings found: $($report.Warnings.Count)" -ForegroundColor Yellow
} else {
    Write-Host "✅ ALL CLEAR: System ready for Pop!_OS migration!" -ForegroundColor Green
}

Write-Host "`nReport saved to: $reportPath" -ForegroundColor Cyan
Write-Host "Opening report in browser..." -ForegroundColor Yellow
Start-Process $reportPath
