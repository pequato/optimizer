# optimizer v1 - by pequato

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Runtime.InteropServices

# ===== ИМПОРТ ДЛЯ СКРУГЛЕНИЙ =====
$code = @'
using System;
using System.Runtime.InteropServices;
public class RoundRect {
    [DllImport("user32.dll")]
    public static extern int SetWindowRgn(IntPtr hWnd, IntPtr hRgn, bool bRedraw);
    [DllImport("gdi32.dll")]
    public static extern IntPtr CreateRoundRectRgn(int nLeftRect, int nTopRect, int nRightRect, int nBottomRect, int nWidthEllipse, int nHeightEllipse);
}
'@
Add-Type -TypeDefinition $code

# ===== ФУНКЦИИ =====
function Get-ProcessAffinity {
    param($name)
    $proc = Get-Process -Name $name -ErrorAction SilentlyContinue
    if ($proc) {
        try { return $proc.ProcessorAffinity } catch { return $null }
    }
    return $null
}

function Set-ProcessAffinity {
    param($name, $cores)
    $proc = Get-Process -Name $name -ErrorAction SilentlyContinue
    if ($proc) {
        try { $proc.ProcessorAffinity = $cores; return $true } catch { return $false }
    }
    return $false
}

# ===== СОЗДАЁМ ФОРМУ =====
$form = New-Object System.Windows.Forms.Form
$form.Text = "optimizer v1"
$form.Size = New-Object System.Drawing.Size(520, 420)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "None"
$form.BackColor = [System.Drawing.Color]::FromArgb(18, 18, 20)
$form.Opacity = 0.95

# ===== ЗАКРУГЛЕНИЕ УГЛОВ =====
$form.Add_Shown({
    $handle = $form.Handle
    $rgn = [RoundRect]::CreateRoundRectRgn(0, 0, $form.Width, $form.Height, 25, 25)
    [RoundRect]::SetWindowRgn($handle, $rgn, $true)
})

# ===== ПАНЕЛЬ ЗАГОЛОВКА (для перетаскивания) =====
$titleBar = New-Object System.Windows.Forms.Panel
$titleBar.Size = New-Object System.Drawing.Size(520, 45)
$titleBar.Location = New-Object System.Drawing.Point(0, 0)
$titleBar.BackColor = [System.Drawing.Color]::FromArgb(28, 28, 30)
$titleBar.Cursor = [System.Windows.Forms.Cursors]::SizeAll
$form.Controls.Add($titleBar)

# ===== КНОПКА ЗАКРЫТИЯ (стильная) =====
$btnClose = New-Object System.Windows.Forms.Button
$btnClose.Text = "✕"
$btnClose.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$btnClose.Size = New-Object System.Drawing.Size(36, 32)
$btnClose.Location = New-Object System.Drawing.Point(472, 7)
$btnClose.FlatStyle = "Flat"
$btnClose.FlatAppearance.BorderSize = 0
$btnClose.ForeColor = [System.Drawing.Color]::FromArgb(180, 180, 180)
$btnClose.BackColor = [System.Drawing.Color]::FromArgb(28, 28, 30)
$btnClose.Cursor = [System.Windows.Forms.Cursors]::Hand
$btnClose.Add_Click({ $form.Close() })
$btnClose.Add_MouseEnter({
    $btnClose.BackColor = [System.Drawing.Color]::FromArgb(220, 50, 50)
    $btnClose.ForeColor = [System.Drawing.Color]::White
})
$btnClose.Add_MouseLeave({
    $btnClose.BackColor = [System.Drawing.Color]::FromArgb(28, 28, 30)
    $btnClose.ForeColor = [System.Drawing.Color]::FromArgb(180, 180, 180)
})
$form.Controls.Add($btnClose)

# ===== ЗАГОЛОВОК =====
$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text = "optimizer v1"
$lblTitle.Font = New-Object System.Drawing.Font("Segoe UI", 17, [System.Drawing.FontStyle]::Bold)
$lblTitle.ForeColor = [System.Drawing.Color]::FromArgb(0, 200, 255)
$lblTitle.Size = New-Object System.Drawing.Size(400, 40)
$lblTitle.Location = New-Object System.Drawing.Point(20, 5)
$lblTitle.TextAlign = "MiddleLeft"
$form.Controls.Add($lblTitle)

# ===== ПОДЗАГОЛОВОК =====
$lblSub = New-Object System.Windows.Forms.Label
$lblSub.Text = "CPU affinity manager"
$lblSub.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$lblSub.ForeColor = [System.Drawing.Color]::FromArgb(120, 120, 130)
$lblSub.Size = New-Object System.Drawing.Size(200, 20)
$lblSub.Location = New-Object System.Drawing.Point(22, 28)
$form.Controls.Add($lblSub)

# ===== КОНТЕЙНЕР ДЛЯ КАРТОЧЕК =====
$cardRoblox = New-Object System.Windows.Forms.Panel
$cardRoblox.Size = New-Object System.Drawing.Size(460, 80)
$cardRoblox.Location = New-Object System.Drawing.Point(30, 75)
$cardRoblox.BackColor = [System.Drawing.Color]::FromArgb(28, 28, 32)
$cardRoblox.BorderStyle = "FixedSingle"
$form.Controls.Add($cardRoblox)

# ===== LABEL ROBLOX =====
$lblRobloxTitle = New-Object System.Windows.Forms.Label
$lblRobloxTitle.Text = "Roblox"
$lblRobloxTitle.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$lblRobloxTitle.ForeColor = [System.Drawing.Color]::FromArgb(220, 220, 230)
$lblRobloxTitle.Size = New-Object System.Drawing.Size(150, 25)
$lblRobloxTitle.Location = New-Object System.Drawing.Point(20, 10)
$cardRoblox.Controls.Add($lblRobloxTitle)

# ===== СТАТУС ROBLOX =====
$lblRobloxStatus = New-Object System.Windows.Forms.Label
$lblRobloxStatus.Text = "● NOT RUNNING"
$lblRobloxStatus.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$lblRobloxStatus.ForeColor = [System.Drawing.Color]::FromArgb(255, 80, 80)
$lblRobloxStatus.Size = New-Object System.Drawing.Size(300, 20)
$lblRobloxStatus.Location = New-Object System.Drawing.Point(20, 35)
$cardRoblox.Controls.Add($lblRobloxStatus)

# ===== КНОПКА ROBLOX =====
$btnRoblox = New-Object System.Windows.Forms.Button
$btnRoblox.Text = "Toggle"
$btnRoblox.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$btnRoblox.Size = New-Object System.Drawing.Size(100, 50)
$btnRoblox.Location = New-Object System.Drawing.Point(320, 15)
$btnRoblox.FlatStyle = "Flat"
$btnRoblox.FlatAppearance.BorderSize = 0
$btnRoblox.ForeColor = [System.Drawing.Color]::White
$btnRoblox.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 70)
$btnRoblox.Cursor = [System.Windows.Forms.Cursors]::Hand
$btnRoblox.Add_Click({ Toggle-Roblox })
$cardRoblox.Controls.Add($btnRoblox)

# ===== КАРТОЧКА CS2 =====
$cardCS2 = New-Object System.Windows.Forms.Panel
$cardCS2.Size = New-Object System.Drawing.Size(460, 80)
$cardCS2.Location = New-Object System.Drawing.Point(30, 170)
$cardCS2.BackColor = [System.Drawing.Color]::FromArgb(28, 28, 32)
$cardCS2.BorderStyle = "FixedSingle"
$form.Controls.Add($cardCS2)

# ===== LABEL CS2 =====
$lblCS2Title = New-Object System.Windows.Forms.Label
$lblCS2Title.Text = "CS2"
$lblCS2Title.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$lblCS2Title.ForeColor = [System.Drawing.Color]::FromArgb(220, 220, 230)
$lblCS2Title.Size = New-Object System.Drawing.Size(150, 25)
$lblCS2Title.Location = New-Object System.Drawing.Point(20, 10)
$cardCS2.Controls.Add($lblCS2Title)

# ===== СТАТУС CS2 =====
$lblCS2Status = New-Object System.Windows.Forms.Label
$lblCS2Status.Text = "● NOT RUNNING"
$lblCS2Status.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$lblCS2Status.ForeColor = [System.Drawing.Color]::FromArgb(255, 80, 80)
$lblCS2Status.Size = New-Object System.Drawing.Size(300, 20)
$lblCS2Status.Location = New-Object System.Drawing.Point(20, 35)
$cardCS2.Controls.Add($lblCS2Status)

# ===== КНОПКА CS2 =====
$btnCS2 = New-Object System.Windows.Forms.Button
$btnCS2.Text = "Toggle"
$btnCS2.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$btnCS2.Size = New-Object System.Drawing.Size(100, 50)
$btnCS2.Location = New-Object System.Drawing.Point(320, 15)
$btnCS2.FlatStyle = "Flat"
$btnCS2.FlatAppearance.BorderSize = 0
$btnCS2.ForeColor = [System.Drawing.Color]::White
$btnCS2.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 70)
$btnCS2.Cursor = [System.Windows.Forms.Cursors]::Hand
$btnCS2.Add_Click({ Toggle-CS2 })
$cardCS2.Controls.Add($btnCS2)

# ===== КНОПКА ОБНОВИТЬ =====
$btnRefresh = New-Object System.Windows.Forms.Button
$btnRefresh.Text = "↻ Refresh"
$btnRefresh.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$btnRefresh.Size = New-Object System.Drawing.Size(120, 32)
$btnRefresh.Location = New-Object System.Drawing.Point(180, 270)
$btnRefresh.FlatStyle = "Flat"
$btnRefresh.FlatAppearance.BorderSize = 0
$btnRefresh.ForeColor = [System.Drawing.Color]::FromArgb(180, 180, 180)
$btnRefresh.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 45)
$btnRefresh.Cursor = [System.Windows.Forms.Cursors]::Hand
$btnRefresh.Add_Click({ Update-Status })
$form.Controls.Add($btnRefresh)

# ===== ПОДПИСЬ =====
$lblFooter = New-Object System.Windows.Forms.Label
$lblFooter.Text = "by pequato"
$lblFooter.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Italic)
$lblFooter.ForeColor = [System.Drawing.Color]::FromArgb(70, 70, 80)
$lblFooter.Size = New-Object System.Drawing.Size(200, 20)
$lblFooter.Location = New-Object System.Drawing.Point(200, 320)
$lblFooter.TextAlign = "MiddleCenter"
$form.Controls.Add($lblFooter)

# ===== ОБНОВЛЕНИЕ СТАТУСА =====
function Update-Status {
    $aff = Get-ProcessAffinity "RobloxPlayerBeta"
    if ($aff -eq $null) {
        $lblRobloxStatus.Text = "● NOT RUNNING"
        $lblRobloxStatus.ForeColor = [System.Drawing.Color]::FromArgb(255, 80, 80)
    } elseif ($aff -band 1) {
        $lblRobloxStatus.Text = "● CPU 0: ON | Priority: NORMAL"
        $lblRobloxStatus.ForeColor = [System.Drawing.Color]::FromArgb(255, 200, 0)
    } else {
        $lblRobloxStatus.Text = "● CPU 0: OFF | Priority: HIGH"
        $lblRobloxStatus.ForeColor = [System.Drawing.Color]::FromArgb(0, 255, 150)
    }

    $aff = Get-ProcessAffinity "cs2"
    if ($aff -eq $null) {
        $lblCS2Status.Text = "● NOT RUNNING"
        $lblCS2Status.ForeColor = [System.Drawing.Color]::FromArgb(255, 80, 80)
    } elseif ($aff -band 1) {
        $lblCS2Status.Text = "● CPU 0: ON"
        $lblCS2Status.ForeColor = [System.Drawing.Color]::FromArgb(255, 200, 0)
    } else {
        $lblCS2Status.Text = "● CPU 0: OFF"
        $lblCS2Status.ForeColor = [System.Drawing.Color]::FromArgb(0, 255, 150)
    }
}

# ===== ЛОГИКА КНОПОК =====
function Toggle-Roblox {
    $aff = Get-ProcessAffinity "RobloxPlayerBeta"
    if ($aff -eq $null) {
        [System.Windows.Forms.MessageBox]::Show("Roblox is not running!", "optimizer")
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
        [System.Windows.Forms.MessageBox]::Show("Run as Administrator!", "optimizer")
    }
}

function Toggle-CS2 {
    $aff = Get-ProcessAffinity "cs2"
    if ($aff -eq $null) {
        [System.Windows.Forms.MessageBox]::Show("CS2 is not running!", "optimizer")
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
        [System.Windows.Forms.MessageBox]::Show("Run as Administrator!", "optimizer")
    }
}

# ===== ПЕРЕТАСКИВАНИЕ ОКНА =====
$titleBar.Add_MouseDown({
    $form.Capture = $false
    $form.PerformLayout()
    [System.Windows.Forms.Control]::SendKeys("{ESC}")
    Add-Type -AssemblyName System.Windows.Forms
    $pos = [System.Windows.Forms.Cursor]::Position
    $form.Location = $pos
})

# ===== ЗАПУСК =====
Update-Status
$form.ShowDialog() | Out-Null
