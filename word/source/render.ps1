# Export a .docx/.dotx to PDF with Word, with the brand fonts loaded for this
# Windows session only (nothing is installed).
#   powershell -File render.ps1 <file.docx> <output.pdf>
param([string]$File, [string]$Pdf)

Add-Type @"
using System; using System.Runtime.InteropServices;
public static class SausFonts {
  [DllImport("gdi32.dll", CharSet=CharSet.Unicode)] public static extern int AddFontResourceW(string f);
  [DllImport("gdi32.dll", CharSet=CharSet.Unicode)] public static extern bool RemoveFontResourceW(string f);
  [DllImport("user32.dll")] public static extern IntPtr SendMessageTimeout(IntPtr h, uint m, IntPtr w, IntPtr l, uint f, uint t, out IntPtr r);
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
$Pdf = [System.IO.Path]::GetFullPath($Pdf)
# note which Word process this script starts, to end only that one if it hangs
$before = @(Get-Process WINWORD -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Id)
$word = New-Object -ComObject Word.Application
$mine = @(Get-Process WINWORD -ErrorAction SilentlyContinue | Where-Object { $before -notcontains $_.Id } |
  Select-Object -ExpandProperty Id)
$word.Visible = $false
$word.DisplayAlerts = 0
try {
  $doc = $word.Documents.Open($File, $false, $true)          # read-only
  $doc.Fields.Update() | Out-Null
  foreach ($s in $doc.Sections) { foreach ($h in $s.Headers) { $h.Range.Fields.Update() | Out-Null } }
  $doc.ExportAsFixedFormat($Pdf, 17)                          # 17 = PDF
  try { "Pages: " + $doc.ComputeStatistics(2) } catch { }
} finally {
  try { $doc.Close(0) } catch { }
  try { $word.Quit() } catch { }                               # this hidden instance only
  [void][Runtime.InteropServices.Marshal]::ReleaseComObject($word)
  [GC]::Collect(); [GC]::WaitForPendingFinalizers()
  foreach ($id in $mine) {
    $proc = Get-Process -Id $id -ErrorAction SilentlyContinue
    if ($proc -and -not $proc.WaitForExit(5000)) { Stop-Process -Id $id -Confirm:$false }
  }
  foreach ($f in $fonts) { [void][SausFonts]::RemoveFontResourceW($f) }
  [SausFonts]::Broadcast()
}
