# optimizer.ps1
# by pequato

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Threading

# ===== ФУНКЦИИ =====
function Get-ProcessAffinity {
    param($name)
    $proc = Get-Process -Name $name -ErrorAction SilentlyContinue
    if ($proc) {
        try {
            return $proc.ProcessorAffinity
        } catch {
            return $null
        }
    }
    return $null
}

function Set-ProcessAffinity {
    param($name, $cores)
    $proc = Get-Process -Name $name -ErrorAction SilentlyContinue
    if ($proc) {
        try {
            $proc.ProcessorAffinity = $cores
            return $true
        } catch {
            return $false
        }
    }
    return $false
}

# ===== СОЗДАЁМ ОКНО =====
$form = New-Object System.Windows.Forms.Form
$form.Text = "optimizer v1"
$form.Size = New-Object System.Drawing.Size(480, 320)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)

# ===== ЗАГОЛОВОК =====
$labelTitle = New-Object System.Windows.Forms.Label
$labelTitle.Text = "optimizer v1"
$labelTitle.Font = New-Object System.Drawing.Font("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
$labelTitle.ForeColor = [System.Drawing.Color]::FromArgb(0, 200, 255)
$labelTitle.Size = New-Object System.Drawing.Size(400, 40)
$labelTitle.Location = New-Object System.Drawing.Point(50, 15)
$form.Controls.Add($labelTitle)

# ===== КНОПКА ROBLOX =====
$btnRoblox = New-Object System.Windows.Forms.Button
$btnRoblox.Text = "Toggle Roblox"
$btnRoblox.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$btnRoblox.Size = New-Object System.Drawing.Size(380, 45)
$btnRoblox.Location = New-Object System.Drawing.Point(30, 80)
$btnRoblox.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 50)
$btnRoblox.ForeColor = [System.Drawing.Color]::White
$btnRoblox.FlatStyle = "Flat"
$form.Controls.Add($btnRoblox)

# ===== СТАТУС ROBLOX =====
$lblRoblox = New-Object System.Windows.Forms.Label
$lblRoblox.Text = "Status: OFF"
$lblRoblox.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$lblRoblox.ForeColor = [System.Drawing.Color]::FromArgb(150, 150, 150)
$lblRoblox.Size = New-Object System.Drawing.Size(380, 25)
$lblRoblox.Location = New-Object System.Drawing.Point(30, 130)
$form.Controls.Add($lblRoblox)

# ===== КНОПКА CS2 =====
$btnCS2 = New-Object System.Windows.Forms.Button
$btnCS2.Text = "Toggle CS2"
$btnCS2.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$btnCS2.Size = New-Object System.Drawing.Size(380, 45)
$btnCS2.Location = New-Object System.Drawing.Point(30, 170)
$btnCS2.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 50)
$btnCS2.ForeColor = [System.Drawing.Color]::White
$btnCS2.FlatStyle = "Flat"
$form.Controls.Add($btnCS2)

# ===== СТАТУС CS2 =====
$lblCS2 = New-Object System.Windows.Forms.Label
$lblCS2.Text = "Status: OFF"
$lblCS2.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$lblCS2.ForeColor = [System.Drawing.Color]::FromArgb(150, 150, 150)
$lblCS2.Size = New-Object System.Drawing.Size(380, 25)
$lblCS2.Location = New-Object System.Drawing.Point(30, 220)
$form.Controls.Add($lblCS2)

# ===== КНОПКА ОБНОВИТЬ =====
$btnRefresh = New-Object System.Windows.Forms.Button
$btnRefresh.Text = "Refresh Status"
$btnRefresh.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$btnRefresh.Size = New-Object System.Drawing.Size(120, 30)
$btnRefresh.Location = New-Object System.Drawing.Point(160, 255)
$btnRefresh.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 50)
$btnRefresh.ForeColor = [System.Drawing.Color]::White
$btnRefresh.FlatStyle = "Flat"
$form.Controls.Add($btnRefresh)

# ===== ПОДПИСЬ =====
$lblFooter = New-Object System.Windows.Forms.Label
$lblFooter.Text = "by pequato"
$lblFooter.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Italic)
$lblFooter.ForeColor = [System.Drawing.Color]::FromArgb(80, 80, 80)
$lblFooter.Size = New-Object System.Drawing.Size(400, 20)
$lblFooter.Location = New-Object System.Drawing.Point(190, 290)
$form.Controls.Add($lblFooter)

# ===== ЛОГИКА =====
function Update-Status {
    # Roblox
    $aff = Get-ProcessAffinity "RobloxPlayerBeta"
    if ($aff -eq $null) {
        $lblRoblox.Text = "Status: NOT RUNNING"
        $lblRoblox.ForeColor = [System.Drawing.Color]::FromArgb(255, 80, 80)
    } elseif ($aff -band 1) {
        $lblRoblox.Text = "CPU 0: ON | Priority: NORMAL"
        $lblRoblox.ForeColor = [System.Drawing.Color]::FromArgb(255, 200, 0)
    } else {
        $lblRoblox.Text = "CPU 0: OFF | Priority: HIGH"
        $lblRoblox.ForeColor = [System.Drawing.Color]::FromArgb(0, 255, 150)
    }
    
    # CS2
    $aff = Get-ProcessAffinity "cs2"
    if ($aff -eq $null) {
        $lblCS2.Text = "Status: NOT RUNNING"
        $lblCS2.ForeColor = [System.Drawing.Color]::FromArgb(255, 80, 80)
    } elseif ($aff -band 1) {
        $lblCS2.Text = "CPU 0: ON"
        $lblCS2.ForeColor = [System.Drawing.Color]::FromArgb(255, 200, 0)
    } else {
        $lblCS2.Text = "CPU 0: OFF"
        $lblCS2.ForeColor = [System.Drawing.Color]::FromArgb(0, 255, 150)
    }
}

function Toggle-Roblox {
    $aff = Get-ProcessAffinity "RobloxPlayerBeta"
    if ($aff -eq $null) {
        [System.Windows.Forms.MessageBox]::Show("Roblox is not running!", "Error")
        return
    }
    try {
        if ($aff -band 1) {
            Set-ProcessAffinity "RobloxPlayerBeta" 0x3E
            $proc = Get-Process -Name RobloxPlayerBeta
            $proc.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::High
        } else {
            Set-ProcessAffinity "RobloxPlayerBeta" 0x3F
            $proc = Get-Process -Name RobloxPlayerBeta
            $proc.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::Normal
        }
        Update-Status
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Run as Administrator!", "Error")
    }
}

function Toggle-CS2 {
    $aff = Get-ProcessAffinity "cs2"
    if ($aff -eq $null) {
        [System.Windows.Forms.MessageBox]::Show("CS2 is not running!`n`nAdd to Steam Launch Options:`n+thread_pool_option 2", "Error")
        return
    }
    try {
        if ($aff -band 1) {
            Set-ProcessAffinity "cs2" 0x3E
        } else {
            Set-ProcessAffinity "cs2" 0x3F
        }
        Update-Status
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Run as Administrator!", "Error")
    }
}

# ===== ПРИВЯЗКА КНОПОК =====
$btnRoblox.Add_Click({ Toggle-Roblox })
$btnCS2.Add_Click({ Toggle-CS2 })
$btnRefresh.Add_Click({ Update-Status })

# ===== ЗАПУСК =====
Update-Status
$form.ShowDialog() | Out-Null
