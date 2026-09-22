# Save a PNG of each sheet as Excel draws it on screen (with the brand fonts
# loaded for this session only). Excel does not embed these fonts in PDFs, so
# this is the reliable way to check the look.
#   powershell -File preview.ps1 <file.xlsx> <output-folder> [range]
param([string]$File, [string]$OutDir, [string]$Range = "A1:I40")

Add-Type @"
using System; using System.Runtime.InteropServices;
public static class SausFonts {
  [DllImport("gdi32.dll", CharSet=CharSet.Unicode)] public static extern int AddFontResourceW(string f);
  [DllImport("gdi32.dll", CharSet=CharSet.Unicode)] public static extern bool RemoveFontResourceW(string f);
  [DllImport("user32.dll")] public static extern IntPtr SendMessageTimeout(IntPtr h, uint m, IntPtr w, IntPtr l, uint f, uint t, out IntPtr r);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  public static void Broadcast() { IntPtr r; SendMessageTimeout((IntPtr)0xffff, 0x001D, IntPtr.Zero, IntPtr.Zero, 2, 1000, out r); }
}
"@

# fonts\ is a local drop box, git-ignored (see fonts\README.md); the Sindhi and
# Urdu fonts ship with the repository in latex\assets\fonts.
$fontDirs = "..\..\fonts", "..\..\latex\assets\fonts" | ForEach-Object { Join-Path $PSScriptRoot $_ }
$fonts = Get-ChildItem $fontDirs -Include *.otf, *.ttf -Recurse -ErrorAction SilentlyContinue |
  Select-Object -ExpandProperty FullName
if (-not ($fonts -match "FiraSans")) {
  Write-Warning "No brand fonts in fonts\ -- Office will substitute. See fonts\README.md."
}
foreach ($f in $fonts) { [void][SausFonts]::AddFontResourceW($f) }
[SausFonts]::Broadcast()

$File = (Resolve-Path $File).Path
New-Item -ItemType Directory -Force $OutDir | Out-Null
$OutDir = (Resolve-Path $OutDir).Path
$xl = New-Object -ComObject Excel.Application
$xl.Visible = $false
$xlPid = 0; [void][SausFonts]::GetWindowThreadProcessId([IntPtr]$xl.Hwnd, [ref]$xlPid)
$xl.DisplayAlerts = $false
try {
  $wb = $xl.Workbooks.Open($File, 0, $true)
  $xl.CalculateFull()
  foreach ($ws in $wb.Worksheets) {
    $r = $ws.Range($Range)
    [void]$r.CopyPicture(1, -4147)                            # as on screen, vector picture
    $holder = $ws.ChartObjects().Add(0, 0, $r.Width, $r.Height)
    $holder.Activate()
    [void]$holder.Chart.Paste()
    [void]$holder.Chart.Export((Join-Path $OutDir ($ws.Name + ".png")), "PNG")
    $holder.Delete()
  }
} finally {
  try { $wb.Close($false) } catch { }
  try { $xl.Quit() } catch { }
  # Excel stays alive while PowerShell holds COM references; release them all
  foreach ($o in @($r, $holder, $ws, $wb, $xl)) {
    if ($o) { try { [void][Runtime.InteropServices.Marshal]::ReleaseComObject($o) } catch { } }
  }
  [GC]::Collect(); [GC]::WaitForPendingFinalizers()
  # if the Excel this script started is still running, end that process (only that one)
  if ($xlPid) {
    $proc = Get-Process -Id $xlPid -ErrorAction SilentlyContinue
    if ($proc -and -not $proc.WaitForExit(5000)) { Stop-Process -Id $xlPid -Confirm:$false }
  }
  foreach ($f in $fonts) { [void][SausFonts]::RemoveFontResourceW($f) }
  [SausFonts]::Broadcast()
}
