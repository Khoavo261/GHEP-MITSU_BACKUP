# Script tu dong go Instruction List (IL) vao GX Developer / GX Works2
Add-Type -AssemblyName System.Windows.Forms

$ilFilePath = "D:\UV-tam\fx2n_uv_program.il"
if (-not (Test-Path $ilFilePath)) {
    Write-Host "Khong tim thay file $ilFilePath!" -ForegroundColor Red
    exit
}

$lines = Get-Content $ilFilePath | Where-Object { $_.Trim() -ne "" -and -not $_.StartsWith(";") }

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  TOOL TU DONG GO LENH IL VAO GX DEVELOPER / GX WORKS2   " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Tong so lenh can go: $($lines.Count) lenh." -ForegroundColor Green
Write-Host ""
Write-Host "HUONG DAN CHUAN BI:" -ForegroundColor White
Write-Host "1. Mo GX Developer / GX Works2 len."
Write-Host "2. Chuyen sang Instruction List (Alt+F1) hoac che do nhap lenh (Enter tai Step 0)."
Write-Host "3. Ban co 5 GIAY de click chuot vao dung o nhap lenh tren phan mem!"
Write-Host ""

for ($i = 5; $i -gt 0; $i--) {
    Write-Host "Bat dau sau: $i giay... (CLICK CHUOT VAO GX DEVELOPER NGAY)" -ForegroundColor Magenta
    [System.Console]::Beep(800, 200)
    Start-Sleep -Seconds 1
}

Write-Host ">>> DANG GO LENH TU DONG... (VUI LONG KHONG DUNG CHUOT/BAN PHIM) <<<" -ForegroundColor Yellow
[System.Console]::Beep(1200, 300)

$count = 0
foreach ($line in $lines) {
    $count++
    $cleanLine = $line.Trim()
    Write-Host "[$count/$($lines.Count)] $cleanLine" -ForegroundColor Gray
    
    # Gui chuoi lenh va phim Enter
    [System.Windows.Forms.SendKeys]::SendWait("$cleanLine{ENTER}")
    
    # Nghi ngan 60ms de GX Developer kip ghi nhan tung lenh
    Start-Sleep -Milliseconds 60
}

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  DA GO THANH CONG TOAN BO CHUONG TRINH!                  " -ForegroundColor Green
Write-Host "  -> Hay bam ESC de dong hop thoai nhap (neu co)          " -ForegroundColor White
Write-Host "  -> Bam F4 de Compile/Convert chuong trinh               " -ForegroundColor White
Write-Host "  -> Bam F1 de xem so do Ladder!                          " -ForegroundColor White
Write-Host "==========================================================" -ForegroundColor Cyan
[System.Console]::Beep(1500, 500)
