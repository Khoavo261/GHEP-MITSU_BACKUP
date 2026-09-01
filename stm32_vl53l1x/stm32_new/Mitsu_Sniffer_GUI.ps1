Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "Multi-Protocol Serial Sniffer (Mitsubishi MC / Modbus RTU / ASCII)"
$form.Size = New-Object System.Drawing.Size(1000, 720)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 35)
$form.ForeColor = [System.Drawing.Color]::White
$form.Font = New-Object System.Drawing.Font("Segoe UI", 9.5)

# --- Top Control Panel ---
$panel = New-Object System.Windows.Forms.Panel
$panel.Dock = "Top"
$panel.Height = 135
$panel.BackColor = [System.Drawing.Color]::FromArgb(40, 42, 54)
$form.Controls.Add($panel)

# Status Label
$lblScan = New-Object System.Windows.Forms.Label
$lblScan.Text = "Scanning COM ports..."
$lblScan.Location = New-Object System.Drawing.Point(15, 10)
$lblScan.AutoSize = $true
$lblScan.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
$panel.Controls.Add($lblScan)

# Port 1
$lblPort1 = New-Object System.Windows.Forms.Label
$lblPort1.Text = "Port 1 (TX):"
$lblPort1.Location = New-Object System.Drawing.Point(15, 38)
$lblPort1.AutoSize = $true
$panel.Controls.Add($lblPort1)

$cbPort1 = New-Object System.Windows.Forms.ComboBox
$cbPort1.Location = New-Object System.Drawing.Point(95, 35)
$cbPort1.Width = 120
$cbPort1.DropDownStyle = "DropDown"
$panel.Controls.Add($cbPort1)

# Port 2
$lblPort2 = New-Object System.Windows.Forms.Label
$lblPort2.Text = "Port 2 (RX):"
$lblPort2.Location = New-Object System.Drawing.Point(15, 72)
$lblPort2.AutoSize = $true
$panel.Controls.Add($lblPort2)

$cbPort2 = New-Object System.Windows.Forms.ComboBox
$cbPort2.Location = New-Object System.Drawing.Point(95, 69)
$cbPort2.Width = 120
$cbPort2.DropDownStyle = "DropDown"
$panel.Controls.Add($cbPort2)

# Sniff All Checkbox
$chkSniffAll = New-Object System.Windows.Forms.CheckBox
$chkSniffAll.Text = "SNIFF ALL COM PORTS"
$chkSniffAll.Location = New-Object System.Drawing.Point(15, 104)
$chkSniffAll.AutoSize = $true
$chkSniffAll.ForeColor = [System.Drawing.Color]::Gold
$chkSniffAll.Font = New-Object System.Drawing.Font("Segoe UI", 9.0, [System.Drawing.FontStyle]::Bold)
$panel.Controls.Add($chkSniffAll)

# Baudrate
$lblBaud = New-Object System.Windows.Forms.Label
$lblBaud.Text = "Baud:"
$lblBaud.Location = New-Object System.Drawing.Point(230, 38)
$lblBaud.AutoSize = $true
$panel.Controls.Add($lblBaud)

$cbBaud = New-Object System.Windows.Forms.ComboBox
$cbBaud.Location = New-Object System.Drawing.Point(275, 35)
$cbBaud.Width = 85
$cbBaud.DropDownStyle = "DropDownList"
[void]$cbBaud.Items.AddRange(@("9600", "19200", "38400", "57600", "115200"))
$cbBaud.SelectedItem = "9600"
$panel.Controls.Add($cbBaud)

# Parity
$lblParity = New-Object System.Windows.Forms.Label
$lblParity.Text = "Parity:"
$lblParity.Location = New-Object System.Drawing.Point(230, 72)
$lblParity.AutoSize = $true
$panel.Controls.Add($lblParity)

$cbParity = New-Object System.Windows.Forms.ComboBox
$cbParity.Location = New-Object System.Drawing.Point(275, 69)
$cbParity.Width = 85
$cbParity.DropDownStyle = "DropDownList"
[void]$cbParity.Items.AddRange(@("Even", "Odd", "None"))
$cbParity.SelectedItem = "Even"
$panel.Controls.Add($cbParity)

# Data Bits
$lblData = New-Object System.Windows.Forms.Label
$lblData.Text = "Data:"
$lblData.Location = New-Object System.Drawing.Point(375, 38)
$lblData.AutoSize = $true
$panel.Controls.Add($lblData)

$cbData = New-Object System.Windows.Forms.ComboBox
$cbData.Location = New-Object System.Drawing.Point(415, 35)
$cbData.Width = 45
$cbData.DropDownStyle = "DropDownList"
[void]$cbData.Items.AddRange(@("8", "7"))
$cbData.SelectedItem = "8"
$panel.Controls.Add($cbData)

# Stop Bits
$lblStop = New-Object System.Windows.Forms.Label
$lblStop.Text = "Stop:"
$lblStop.Location = New-Object System.Drawing.Point(470, 38)
$lblStop.AutoSize = $true
$panel.Controls.Add($lblStop)

$cbStop = New-Object System.Windows.Forms.ComboBox
$cbStop.Location = New-Object System.Drawing.Point(510, 35)
$cbStop.Width = 45
$cbStop.DropDownStyle = "DropDownList"
[void]$cbStop.Items.AddRange(@("1", "2"))
$cbStop.SelectedItem = "1"
$panel.Controls.Add($cbStop)

# --- Frame End (Kết thúc chuỗi / ngắt gói) ---
$lblFrameEnd = New-Object System.Windows.Forms.Label
$lblFrameEnd.Text = "Kết thúc chuỗi:"
$lblFrameEnd.Location = New-Object System.Drawing.Point(375, 72)
$lblFrameEnd.AutoSize = $true
$lblFrameEnd.ForeColor = [System.Drawing.Color]::Cyan
$lblFrameEnd.Font = New-Object System.Drawing.Font("Segoe UI", 9.0, [System.Drawing.FontStyle]::Bold)
$panel.Controls.Add($lblFrameEnd)

$cbFrameEnd = New-Object System.Windows.Forms.ComboBox
$cbFrameEnd.Location = New-Object System.Drawing.Point(475, 69)
$cbFrameEnd.Width = 200
$cbFrameEnd.DropDownStyle = "DropDownList"
[void]$cbFrameEnd.Items.AddRange(@(
    "Timeout 20ms (Modbus/Binary)",
    "Timeout 50ms (Modbus/Binary)",
    "CRLF (\r\n - ASCII/Text)",
    "CR (\r / 0x0D)",
    "LF (\n / 0x0A)",
    "ETX (0x03 - MC Protocol)",
    "Raw Immediate (Không đệm)"
))
$cbFrameEnd.SelectedItem = "Timeout 20ms (Modbus/Binary)"
$panel.Controls.Add($cbFrameEnd)

# Refresh Button
$btnRefresh = New-Object System.Windows.Forms.Button
$btnRefresh.Text = "Rescan Ports"
$btnRefresh.Location = New-Object System.Drawing.Point(690, 10)
$btnRefresh.Size = New-Object System.Drawing.Size(130, 32)
$btnRefresh.BackColor = [System.Drawing.Color]::FromArgb(68, 71, 90)
$btnRefresh.FlatStyle = "Flat"
$panel.Controls.Add($btnRefresh)

# Start / Stop Button
$btnStart = New-Object System.Windows.Forms.Button
$btnStart.Text = "START SNIFF"
$btnStart.Location = New-Object System.Drawing.Point(690, 48)
$btnStart.Size = New-Object System.Drawing.Size(130, 42)
$btnStart.BackColor = [System.Drawing.Color]::FromArgb(80, 250, 123)
$btnStart.ForeColor = [System.Drawing.Color]::Black
$btnStart.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$btnStart.FlatStyle = "Flat"
$panel.Controls.Add($btnStart)

# Clear Button
$btnClear = New-Object System.Windows.Forms.Button
$btnClear.Text = "Clear Log"
$btnClear.Location = New-Object System.Drawing.Point(690, 96)
$btnClear.Size = New-Object System.Drawing.Size(130, 28)
$btnClear.BackColor = [System.Drawing.Color]::FromArgb(98, 114, 164)
$btnClear.FlatStyle = "Flat"
$panel.Controls.Add($btnClear)

# Save Button
$btnSave = New-Object System.Windows.Forms.Button
$btnSave.Text = "SAVE LOG FILE"
$btnSave.Location = New-Object System.Drawing.Point(830, 10)
$btnSave.Size = New-Object System.Drawing.Size(145, 114)
$btnSave.BackColor = [System.Drawing.Color]::FromArgb(189, 147, 249)
$btnSave.ForeColor = [System.Drawing.Color]::Black
$btnSave.Font = New-Object System.Drawing.Font("Segoe UI", 10.5, [System.Drawing.FontStyle]::Bold)
$btnSave.FlatStyle = "Flat"
$panel.Controls.Add($btnSave)

# --- Log View ---
$rtb = New-Object System.Windows.Forms.RichTextBox
$rtb.Dock = "Fill"
$rtb.BackColor = [System.Drawing.Color]::FromArgb(15, 15, 20)
$rtb.ForeColor = [System.Drawing.Color]::LimeGreen
$rtb.Font = New-Object System.Drawing.Font("Consolas", 10.5)
$rtb.ReadOnly = $true
$form.Controls.Add($rtb)

# --- Function: Get All COM Ports ---
function Get-AllComPorts {
    $portList = @()
    try {
        $pnp = Get-CimInstance Win32_PnPEntity | Where-Object { $_.Name -match '\((COM\d+)\)' }
        foreach ($item in $pnp) {
            if ($item.Name -match '\((COM\d+)\)') {
                $p = $matches[1]
                if ($portList -notcontains $p) { $portList += $p }
            }
        }
    } catch {}

    try {
        $regPorts = Get-ItemProperty -Path 'HKLM:\HARDWARE\DEVICEMAP\SERIALCOMM' -ErrorAction SilentlyContinue
        if ($regPorts) {
            $regPorts.PSObject.Properties | Where-Object { $_.Name -notmatch '^\_' } | ForEach-Object {
                if ($portList -notcontains $_.Value) { $portList += $_.Value }
            }
        }
    } catch {}

    $netPorts = [System.IO.Ports.SerialPort]::GetPortNames()
    foreach ($p in $netPorts) {
        if ($portList -notcontains $p) { $portList += $p }
    }

    foreach ($def in @("COM2", "COM3", "COM7", "COM8", "COM9")) {
        if ($portList -notcontains $def) { $portList += $def }
    }

    return ($portList | Sort-Object -Unique)
}

function Refresh-Ports {
    $ports = Get-AllComPorts
    $cbPort1.Items.Clear()
    $cbPort2.Items.Clear()
    [void]$cbPort1.Items.Add("None (Disabled)")
    [void]$cbPort2.Items.Add("None (Disabled)")
    
    foreach ($p in $ports) {
        [void]$cbPort1.Items.Add($p)
        [void]$cbPort2.Items.Add($p)
    }

    $lblScan.Text = "Available Ports: " + ($ports -join ", ")
    $lblScan.ForeColor = [System.Drawing.Color]::LightGreen
    
    if ($ports -contains "COM8") { $cbPort1.SelectedItem = "COM8" }
    elseif ($ports -contains "COM2") { $cbPort1.SelectedItem = "COM2" }
    elseif ($ports.Count -ge 1) { $cbPort1.SelectedItem = $ports[0] }

    if ($ports -contains "COM7") { $cbPort2.SelectedItem = "COM7" }
    elseif ($ports -contains "COM9") { $cbPort2.SelectedItem = "COM9" }
    elseif ($ports.Count -ge 2) { $cbPort2.SelectedItem = $ports[1] }
}
Refresh-Ports

$btnRefresh.Add_Click({ Refresh-Ports })

# --- Serial Sniffer Manager & Per-Port Buffer ---
$script:activePorts = @{}
$script:portBuffers = @{}
$script:portLastRx = @{}
$script:running = $false

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 10

function Append-Log([string]$text, [System.Drawing.Color]$color) {
    $rtb.SelectionStart = $rtb.TextLength
    $rtb.SelectionLength = 0
    $rtb.SelectionColor = $color
    $rtb.AppendText($text)
    $rtb.ScrollToCaret()
}

$timer.Add_Tick({
    $now = [DateTime]::Now
    $frameMode = $cbFrameEnd.SelectedItem
    $readTemp = New-Object byte[] 4096

    foreach ($portName in $script:activePorts.Keys) {
        $sp = $script:activePorts[$portName]
        if (-not $sp -or -not $sp.IsOpen) { continue }

        try {
            $avail = $sp.BytesToRead
            if ($avail -gt 0) {
                $n = $sp.Read($readTemp, 0, [Math]::Min($avail, 4096))
                if ($n -gt 0) {
                    if (-not $script:portBuffers.ContainsKey($portName)) {
                        $script:portBuffers[$portName] = New-Object 'System.Collections.Generic.List[byte]'
                    }
                    for ($i = 0; $i -lt $n; $i++) {
                        $script:portBuffers[$portName].Add($readTemp[$i])
                    }
                    $script:portLastRx[$portName] = $now
                }
            }
        } catch {}

        if ($script:portBuffers.ContainsKey($portName) -and $script:portBuffers[$portName].Count -gt 0) {
            $buf = $script:portBuffers[$portName]
            $lastRx = $script:portLastRx[$portName]
            $idleMs = ($now - $lastRx).TotalMilliseconds
            $framesToEmit = @()

            if ($frameMode -match "Raw Immediate") {
                $framesToEmit += ,($buf.ToArray())
                $buf.Clear()
            }
            elseif ($frameMode -match "CRLF") {
                while ($true) {
                    $idx = -1
                    for ($i = 0; $i -lt ($buf.Count - 1); $i++) {
                        if ($buf[$i] -eq 0x0D -and $buf[$i+1] -eq 0x0A) {
                            $idx = $i + 1
                            break
                        }
                    }
                    if ($idx -ge 0) {
                        $frame = $buf.GetRange(0, $idx + 1).ToArray()
                        $buf.RemoveRange(0, $idx + 1)
                        $framesToEmit += ,$frame
                    } else {
                        if ($idleMs -ge 400 -and $buf.Count -gt 0) {
                            $framesToEmit += ,($buf.ToArray())
                            $buf.Clear()
                        }
                        break
                    }
                }
            }
            elseif ($frameMode -match "CR \(\\r") {
                while ($true) {
                    $idx = $buf.IndexOf(0x0D)
                    if ($idx -ge 0) {
                        $frame = $buf.GetRange(0, $idx + 1).ToArray()
                        $buf.RemoveRange(0, $idx + 1)
                        $framesToEmit += ,$frame
                    } else {
                        if ($idleMs -ge 400 -and $buf.Count -gt 0) {
                            $framesToEmit += ,($buf.ToArray())
                            $buf.Clear()
                        }
                        break
                    }
                }
            }
            elseif ($frameMode -match "LF \(\\n") {
                while ($true) {
                    $idx = $buf.IndexOf(0x0A)
                    if ($idx -ge 0) {
                        $frame = $buf.GetRange(0, $idx + 1).ToArray()
                        $buf.RemoveRange(0, $idx + 1)
                        $framesToEmit += ,$frame
                    } else {
                        if ($idleMs -ge 400 -and $buf.Count -gt 0) {
                            $framesToEmit += ,($buf.ToArray())
                            $buf.Clear()
                        }
                        break
                    }
                }
            }
            elseif ($frameMode -match "ETX") {
                while ($true) {
                    $idx = $buf.IndexOf(0x03)
                    if ($idx -ge 0) {
                        $takeLen = $idx + 1
                        if ($buf.Count -ge ($idx + 3)) { $takeLen = $idx + 3 }
                        $frame = $buf.GetRange(0, $takeLen).ToArray()
                        $buf.RemoveRange(0, $takeLen)
                        $framesToEmit += ,$frame
                    } else {
                        if ($idleMs -ge 400 -and $buf.Count -gt 0) {
                            $framesToEmit += ,($buf.ToArray())
                            $buf.Clear()
                        }
                        break
                    }
                }
            }
            else {
                $timeoutThreshold = 20
                if ($frameMode -match "50ms") { $timeoutThreshold = 50 }
                elseif ($frameMode -match "20ms") { $timeoutThreshold = 20 }
                
                if ($idleMs -ge $timeoutThreshold) {
                    $framesToEmit += ,($buf.ToArray())
                    $buf.Clear()
                }
            }

            foreach ($frameBytes in $framesToEmit) {
                $len = $frameBytes.Length
                if ($len -eq 0) { continue }
                $hex = ($frameBytes | ForEach-Object { "{0:X2}" -f $_ }) -join " "
                $txt = ($frameBytes | ForEach-Object { if ($_ -ge 32 -and $_ -le 126) { [char]$_ } else { "." } }) -join ""
                $time = (Get-Date).ToString("HH:mm:ss.fff")
                
                $col = [System.Drawing.Color]::Cyan
                if ($portName -eq $cbPort2.Text) { $col = [System.Drawing.Color]::Yellow }
                elseif ($script:activePorts.Count -gt 2) { $col = [System.Drawing.Color]::Orange }

                Append-Log "[$time] [$portName] ($len bytes)`r`n  HEX : $hex`r`n  TEXT: $txt`r`n`r`n" $col
            }
        }
    }
})

$btnStart.Add_Click({
    if (-not $script:running) {
        $script:activePorts.Clear()
        $script:portBuffers.Clear()
        $script:portLastRx.Clear()

        $baud = [int]$cbBaud.SelectedItem
        $par = [System.IO.Ports.Parity]::$($cbParity.SelectedItem)
        $dataBits = [int]$cbData.SelectedItem
        $stop = if ($cbStop.SelectedItem -eq "2") { [System.IO.Ports.StopBits]::Two } else { [System.IO.Ports.StopBits]::One }
        $frameMode = $cbFrameEnd.SelectedItem

        $targets = @()
        if ($chkSniffAll.Checked) {
            $targets = Get-AllComPorts
        } else {
            $p1 = $cbPort1.Text.Trim()
            $p2 = $cbPort2.Text.Trim()
            if ($p1 -and $p1 -notmatch "None") { $targets += $p1 }
            if ($p2 -and $p2 -notmatch "None" -and $p2 -ne $p1) { $targets += $p2 }
        }

        if ($targets.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("No COM port selected!", "Warning", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }

        $openedCount = 0
        foreach ($p in $targets) {
            try {
                $sp = New-Object System.IO.Ports.SerialPort $p, $baud, $par, $dataBits, $stop
                $sp.ReadTimeout = 40
                $sp.Open()
                $script:activePorts[$p] = $sp
                $script:portBuffers[$p] = New-Object 'System.Collections.Generic.List[byte]'
                $script:portLastRx[$p] = [DateTime]::Now
                $openedCount++
            } catch {
                Append-Log "Error opening $p : $($_.Exception.Message)`r`n" ([System.Drawing.Color]::Red)
            }
        }

        if ($openedCount -gt 0) {
            $timer.Start()
            $script:running = $true
            $btnStart.Text = "STOP SNIFF"
            $btnStart.BackColor = [System.Drawing.Color]::FromArgb(255, 85, 85)
            $activeList = ($script:activePorts.Keys) -join ", "
            Append-Log "========================================================`r`n" ([System.Drawing.Color]::White)
            Append-Log ">>> LISTENING ON ($openedCount PORTS): $activeList`r`n" ([System.Drawing.Color]::LightGreen)
            Append-Log ">>> Config: $baud bps, Parity: $($cbParity.SelectedItem), Data: $dataBits, Stop: $($cbStop.SelectedItem)`r`n" ([System.Drawing.Color]::LightGreen)
            Append-Log ">>> Framing: $frameMode`r`n" ([System.Drawing.Color]::Cyan)
            Append-Log "========================================================`r`n`r`n" ([System.Drawing.Color]::White)
        }
    } else {
        $timer.Stop()
        foreach ($p in $script:activePorts.Keys) {
            $sp = $script:activePorts[$p]
            if ($sp -and $sp.IsOpen) { $sp.Close(); $sp.Dispose() }
        }
        $script:activePorts.Clear()
        $script:portBuffers.Clear()
        $script:portLastRx.Clear()
        $script:running = $false
        $btnStart.Text = "START SNIFF"
        $btnStart.BackColor = [System.Drawing.Color]::FromArgb(80, 250, 123)
        Append-Log "=== STOPPED LISTENING ===`r`n" ([System.Drawing.Color]::Gray)
    }
})

$btnClear.Add_Click({ $rtb.Clear() })

$btnSave.Add_Click({
    $sfd = New-Object System.Windows.Forms.SaveFileDialog
    $sfd.Filter = "Text Log (*.txt)|*.txt|All Files (*.*)|*.*"
    $sfd.FileName = "serial_capture_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
    if ($sfd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        [System.IO.File]::WriteAllText($sfd.FileName, $rtb.Text)
        [System.Windows.Forms.MessageBox]::Show("Log file saved successfully!", "Info", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
})

$form.Add_FormClosing({
    $timer.Stop()
    foreach ($p in $script:activePorts.Keys) {
        $sp = $script:activePorts[$p]
        if ($sp -and $sp.IsOpen) { $sp.Close() }
    }
})

[void]$form.ShowDialog()
