# CPU Optimizer v2.0
# by pequato

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Get-ProcessStatus {
    param($name)
    $proc = Get-Process -Name $name -ErrorAction SilentlyContinue
    if ($proc) {
        try {
            $affinity = $proc.ProcessorAffinity
            if ($affinity -band 1) {
                return "ENABLED"
            } else {
                return "DISABLED"
            }
        } catch {
            return "UNKNOWN"
        }
    }
    return "NOT RUNNING"
}

function Toggle-Roblox {
    $proc = Get-Process -Name RobloxPlayerBeta -ErrorAction SilentlyContinue
    if (-not $proc) {
        Write-Host "[ERROR] Roblox is NOT running!" -ForegroundColor Red
        return
    }
    
    try {
        $current = $proc.ProcessorAffinity
        if ($current -band 1) {
            $proc.ProcessorAffinity = 0x3E
            $proc.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::High
            Write-Host "[OK] CPU 0 DISABLED | Priority: HIGH | Cores: 1,2,3,4,5" -ForegroundColor Green
        } else {
            $proc.ProcessorAffinity = 0x3F
            $proc.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::Normal
            Write-Host "[OK] CPU 0 ENABLED | Priority: NORMAL | Cores: 0,1,2,3,4,5" -ForegroundColor Green
        }
    } catch {
        Write-Host "[ERROR] Run as Administrator!" -ForegroundColor Red
    }
}

function Toggle-CS2 {
    $proc = Get-Process -Name cs2 -ErrorAction SilentlyContinue
    if (-not $proc) {
        Write-Host "[ERROR] CS2 is NOT running!" -ForegroundColor Red
        Write-Host ""
        Write-Host "Or add to Steam Launch Options:" -ForegroundColor Yellow
        Write-Host "+thread_pool_option 2" -ForegroundColor Green
        return
    }
    
    try {
        $current = $proc.ProcessorAffinity
        if ($current -band 1) {
            $proc.ProcessorAffinity = 0x3E
            Write-Host "[OK] CPU 0 DISABLED | Cores: 1,2,3,4,5" -ForegroundColor Green
        } else {
            $proc.ProcessorAffinity = 0x3F
            Write-Host "[OK] CPU 0 ENABLED | Cores: 0,1,2,3,4,5" -ForegroundColor Green
        }
    } catch {
        Write-Host "[ERROR] Run as Administrator!" -ForegroundColor Red
    }
}

function Show-Status {
    Clear-Host
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "         STATUS: ROBLOX + CS2" -ForegroundColor White
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Roblox
    $r_status = Get-ProcessStatus "RobloxPlayerBeta"
    if ($r_status -eq "NOT RUNNING") {
        Write-Host "  Roblox (OFF)" -ForegroundColor Red
    } elseif ($r_status -eq "ENABLED") {
        Write-Host "  Roblox (ON)  - CPU 0: ENABLED [all cores] | Priority: NORMAL" -ForegroundColor Green
    } elseif ($r_status -eq "DISABLED") {
        Write-Host "  Roblox (ON)  - CPU 0: DISABLED [cores: 1,2,3,4,5] | Priority: HIGH" -ForegroundColor Green
    } else {
        Write-Host "  Roblox (?) - $r_status" -ForegroundColor Yellow
    }
    
    Write-Host ""
    
    # CS2
    $c_status = Get-ProcessStatus "cs2"
    if ($c_status -eq "NOT RUNNING") {
        Write-Host "  CS2 (OFF)" -ForegroundColor Red
    } elseif ($c_status -eq "ENABLED") {
        Write-Host "  CS2 (ON)  - CPU 0: ENABLED [all cores]" -ForegroundColor Green
    } elseif ($c_status -eq "DISABLED") {
        Write-Host "  CS2 (ON)  - CPU 0: DISABLED [cores: 1,2,3,4,5]" -ForegroundColor Green
    } else {
        Write-Host "  CS2 (?) - $c_status" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "  by pequato" -ForegroundColor Gray
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""
}

function Show-Menu {
    Clear-Host
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "           CPU OPTIMIZER v2.0" -ForegroundColor White
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [1] Roblox  - Toggle ON/OFF" -ForegroundColor Yellow
    Write-Host "  [2] CS2     - Toggle ON/OFF" -ForegroundColor Yellow
    Write-Host "  [3] Status  - Check games" -ForegroundColor Yellow
    Write-Host "  [0] Exit" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "  by pequato" -ForegroundColor Gray
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""
}

# Главный цикл
do {
    Show-Menu
    $choice = Read-Host "Select (0-3)"
    
    switch ($choice) {
        "1" { 
            Clear-Host
            Write-Host ""
            Write-Host "============================================" -ForegroundColor Cyan
            Write-Host "           ROBLOX TOGGLE" -ForegroundColor White
            Write-Host "============================================" -ForegroundColor Cyan
            Write-Host ""
            Toggle-Roblox
            Write-Host ""
            Read-Host "Press Enter"
        }
        "2" {
            Clear-Host
            Write-Host ""
            Write-Host "============================================" -ForegroundColor Cyan
            Write-Host "           CS2 TOGGLE" -ForegroundColor White
            Write-Host "============================================" -ForegroundColor Cyan
            Write-Host ""
            Toggle-CS2
            Write-Host ""
            Read-Host "Press Enter"
        }
        "3" {
            Show-Status
            Read-Host "Press Enter"
        }
        "0" {
            Write-Host "Exiting..." -ForegroundColor Green
            exit
        }
        default {
            Write-Host "Invalid choice!" -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
} while ($true)
