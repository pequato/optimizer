# optimizer v1 - by pequato

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Runtime.InteropServices

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
$form.Size = New-Object System.Drawing.Size(500, 400)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "None"
$form.BackColor = [System.Drawing.Color]::FromArgb(18, 18, 20)
$form.Opacity = 1.0  # Убрал прозрачность

# ===== ЗАКРУГЛЕНИЕ УГЛОВ (радиус 20) =====
$form.Add_Shown({
    $handle = $form.Handle
    $rgn = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
    # Использование CreateRoundRectRgn через Add-Type
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
    $rgn = [RoundRect]::CreateRoundRectRgn(0, 0, $form.Width, $form.Height, 20, 20)
    [RoundRect]::SetWindowRgn($handle, $rgn, $true)
})

# ===== ПАНЕЛЬ ЗАГОЛОВКА =====
$titleBar = New-Object System.Windows.Forms.Panel
$titleBar.Size = New-Object System.Drawing.Size(500, 40)
$titleBar.Location = New-Object System.Drawing.Point(0, 0)
$titleBar.BackColor = [System.Drawing.Color]::FromArgb(28, 28, 32)
$titleBar.Cursor = [System.Windows.Forms.Cursors]::SizeAll
$form.Controls.Add($titleBar)

# ===== КНОПКА ЗАКРЫТИЯ =====
$btnClose = New-Object System.Windows.Forms.Button
$btnClose.Text = "✕"
$btnClose.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$btnClose.Size = New-Object System.Drawing.Size(32, 28)
$btnClose.Location = New-Object System.Drawing.Point(456, 6)
$btnClose.FlatStyle = "Flat"
$btnClose.FlatAppearance.BorderSize = 0
$btnClose.ForeColor = [System.Drawing.Color]::FromArgb(180, 180, 180)
$btnClose.BackColor = [System.Drawing.Color]::FromArgb(28, 28, 32)
$btnClose.Cursor = [System.Windows.Forms.Cursors]::Hand
$btnClose.Add_Click({ $form.Close() })
$btnClose.Add_MouseEnter({
    $btnClose.BackColor = [System.Drawing.Color]::FromArgb(220, 50, 50)
    $btnClose.ForeColor = [System.Drawing.Color]::White
})
$btnClose.Add_MouseLeave({
    $btnClose.BackColor = [System.Drawing.Color]::FromArgb(28, 28, 32)
    $btnClose.ForeColor = [System.Drawing.Color]::FromArgb(180, 180, 180)
})
$form.Controls.Add($btnClose)

# ===== ЗАГОЛОВОК =====
$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text = "optimizer v1"
$lblTitle.Font = New-Object System.Drawing.Font("Inter", 16, [System.Drawing.FontStyle]::Bold)
$lblTitle.ForeColor = [System.Drawing.Color]::FromArgb(0, 200, 255)
$lblTitle.Size = New-Object System.Drawing.Size(400, 35)
$lblTitle.Location = New-Object System.Drawing.Point(15, 5)
$lblTitle.TextAlign = "MiddleLeft"
$form.Controls.Add($lblTitle)

# ===== ПОДЗАГОЛОВОК =====
$lblSub = New-Object System.Windows.Forms.Label
$lblSub.Text = "CPU affinity manager"
$lblSub.Font = New-Object System.Drawing.Font("Inter", 9)
$lblSub.ForeColor = [System.Drawing.Color]::FromArgb(120, 120, 130)
$lblSub.Size = New-Object System.Drawing.Size(200, 20)
$lblSub.Location = New-Object System.Drawing.Point(18, 24)
$form.Controls.Add($lblSub)

# ===== КАРТОЧКА ROBLOX =====
$cardRoblox = New-Object System.Windows.Forms.Panel
$cardRoblox.Size = New-Object System.Drawing.Size(440, 80)
$cardRoblox.Location = New-Object System.Drawing.Point(30, 70)
$cardRoblox.BackColor = [System.Drawing.Color]::FromArgb(28, 28, 32)
$cardRoblox.BorderStyle = "FixedSingle"
$form.Controls.Add($cardRoblox)

$lblRobloxTitle = New-Object System.Windows.Forms.Label
$lblRobloxTitle.Text = "Roblox"
$lblRobloxTitle.Font = New-Object System.Drawing.Font("Inter", 11, [System.Drawing.FontStyle]::Bold)
$lblRobloxTitle.ForeColor = [System.Drawing.Color]::FromArgb(220, 220, 230)
$lblRobloxTitle.Size = New-Object System.Drawing.Size(150, 25)
$lblRobloxTitle.Location = New-Object System.Drawing.Point(15, 8)
$cardRoblox.Controls.Add($lblRobloxTitle)

$lblRobloxStatus = New-Object System.Windows.Forms.Label
$lblRobloxStatus.Text = "● NOT RUNNING"
$lblRobloxStatus.Font = New-Object System.Drawing.Font("Inter", 9)
$lblRobloxStatus.ForeColor = [System.Drawing.Color]::FromArgb(255, 80, 80)
$lblRobloxStatus.Size = New-Object System.Drawing.Size(280, 20)
$lblRobloxStatus.Location = New-Object System.Drawing.Point(15, 35)
$cardRoblox.Controls.Add($lblRobloxStatus)

$btnRoblox = New-Object System.Windows.Forms.Button
$btnRoblox.Text = "Toggle"
$btnRoblox.Font = New-Object System.Drawing.Font("Inter", 10, [System.Drawing.FontStyle]::Bold)
$btnRoblox.Size = New-Object System.Drawing.Size(90, 46)
$btnRoblox.Location = New-Object System.Drawing.Point(325, 17)
$btnRoblox.FlatStyle = "Flat"
$btnRoblox.FlatAppearance.BorderSize = 0
$btnRoblox.ForeColor = [System.Drawing.Color]::White
$btnRoblox.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 70)
$btnRoblox.Cursor = [System.Windows.Forms.Cursors]::Hand
$btnRoblox.Add_Click({ Toggle-Roblox })
$btnRoblox.Add_MouseEnter({
    $btnRoblox.BackColor = [System.Drawing.Color]::FromArgb(80, 80, 90)
})
$btnRoblox.Add_MouseLeave({
    $btnRoblox.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 70)
})
$cardRoblox.Controls.Add($btnRoblox)

# ===== КАРТОЧКА CS2 =====
$cardCS2 = New-Object System.Windows.Forms.Panel
$cardCS2.Size = New-Object System.Drawing.Size(440, 80)
$cardCS2.Location = New-Object System.Drawing.Point(30, 165)
$cardCS2.BackColor = [System.Drawing.Color]::FromArgb(28, 28, 32)
$cardCS2.BorderStyle = "FixedSingle"
$form.Controls.Add($cardCS2)

$lblCS2Title = New-Object System.Windows.Forms.Label
$lblCS2Title.Text = "CS2"
$lblCS2Title.Font = New-Object System.Drawing.Font("Inter", 11, [System.Drawing.FontStyle]::Bold)
$lblCS2Title.ForeColor = [System.Drawing.Color]::FromArgb(220, 220, 230)
$lblCS2Title.Size = New-Object System.Drawing.Size(150, 25)
$lblCS2Title.Location = New-Object System.Drawing.Point(15, 8)
$cardCS2.Controls.Add($lblCS2Title)

$lblCS2Status = New-Object System.Windows.Forms.Label
$lblCS2Status.Text = "● NOT RUNNING"
$lblCS2Status.Font = New-Object System.Drawing.Font("Inter", 9)
$lblCS2Status.ForeColor = [System.Drawing.Color]::FromArgb(255, 80, 80)
$lblCS2Status.Size = New-Object System.Drawing.Size(280, 20)
$lblCS2Status.Location = New-Object System.Drawing.Point(15, 35)
$cardCS2.Controls.Add($lblCS2Status)

$btnCS2 = New-Object System.Windows.Forms.Button
$btnCS2.Text = "Toggle"
$btnCS2.Font = New-Object System.Drawing.Font("Inter", 10, [System.Drawing.FontStyle]::Bold)
$btnCS2.Size = New-Object System.Drawing.Size(90, 46)
$btnCS2.Location = New-Object System.Drawing.Point(325, 17)
$btnCS2.FlatStyle = "Flat"
$btnCS2.FlatAppearance.BorderSize = 0
$btnCS2.ForeColor = [System.Drawing.Color]::White
$btnCS2.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 70)
$btnCS2.Cursor = [System.Windows.Forms.Cursors]::Hand
$btnCS2.Add_Click({ Toggle-CS2 })
$btnCS2.Add_MouseEnter({
    $btnCS2.BackColor = [System.Drawing.Color]::FromArgb(80, 80, 90)
})
$btnCS2.Add_MouseLeave({
    $btnCS2.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 70)
})
$cardCS2.Controls.Add($btnCS2)

# ===== КНОПКА ОБНОВИТЬ =====
$btnRefresh = New-Object System.Windows.Forms.Button
$btnRefresh.Text = "↻ Refresh"
$btnRefresh.Font = New-Object System.Drawing.Font("Inter", 9, [System.Drawing.FontStyle]::Bold)
$btnRefresh.Size = New-Object System.Drawing.Size(120, 32)
$btnRefresh.Location = New-Object System.Drawing.Point(190, 265)
$btnRefresh.FlatStyle = "Flat"
$btnRefresh.FlatAppearance.BorderSize = 0
$btnRefresh.ForeColor = [System.Drawing.Color]::FromArgb(180, 180, 180)
$btnRefresh.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 45)
$btnRefresh.Cursor = [System.Windows.Forms.Cursors]::Hand
$btnRefresh.Add_Click({ Update-Status })
$btnRefresh.Add_MouseEnter({
    $btnRefresh.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 65)
})
$btnRefresh.Add_MouseLeave({
    $btnRefresh.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 45)
})
$form.Controls.Add($btnRefresh)

# ===== ПОДПИСЬ =====
$lblFooter = New-Object System.Windows.Forms.Label
$lblFooter.Text = "by pequato"
$lblFooter.Font = New-Object System.Drawing.Font("Inter", 9, [System.Drawing.FontStyle]::Italic)
$lblFooter.ForeColor = [System.Drawing.Color]::FromArgb(70, 70, 80)
$lblFooter.Size = New-Object System.Drawing.Size(200, 20)
$lblFooter.Location = New-Object System.Drawing.Point(210, 315)
$lblFooter.TextAlign = "MiddleCenter"
$form.Controls.Add($lblFooter)

# ===== ПЕРЕТАСКИВАНИЕ ОКНА (исправлено) =====
$titleBar.Add_MouseDown({
    $form.Capture = $false
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.Cursor]::Position
    $form.Location = $form.PointToScreen([System.Drawing.Point]::Empty)
})

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

# ===== ЗАПУСК =====
Update-Status
$form.ShowDialog() | Out-Null
