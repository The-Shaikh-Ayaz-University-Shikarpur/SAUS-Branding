# Export every slide of a .pptx/.potx to PNG with PowerPoint, with the brand
# fonts loaded for this Windows session only (nothing is installed).
#   powershell -File render.ps1 <file.pptx> <output-folder> [width]
param([string]$File, [string]$OutDir, [int]$Width = 1600)

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
New-Item -ItemType Directory -Force $OutDir | Out-Null
$OutDir = (Resolve-Path $OutDir).Path
$app = New-Object -ComObject PowerPoint.Application
try {
  $pres = $app.Presentations.Open($File, $true, $false, $false)   # read-only, no window
  $h = [int]($Width * $pres.PageSetup.SlideHeight / $pres.PageSetup.SlideWidth)
  foreach ($s in $pres.Slides) {
    $s.Export((Join-Path $OutDir ("slide-{0:D2}.png" -f $s.SlideIndex)), "PNG", $Width, $h)
  }
  $pres.Close()
} finally {
  if ($app.Presentations.Count -eq 0) { $app.Quit() }
  foreach ($f in $fonts) { [void][SausFonts]::RemoveFontResourceW($f) }
  [SausFonts]::Broadcast()
}
