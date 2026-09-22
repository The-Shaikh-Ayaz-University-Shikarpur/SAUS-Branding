# Open a generated .docx/.dotx in Word, update the table of contents, the
# lists of figures and tables and every field (captions, running heads), and
# save it -- what "Update Field" does by hand. The brand fonts are loaded for
# this Windows session only, so the page numbers come out right.
#   powershell -File finalize.ps1 <file.docx> [<file2.dotx> ...]
param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Files)

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

# Saving stamps the signed-in Windows user into docProps/core.xml as the last
# author. These files are shared, so put the university back in its place.
Add-Type -AssemblyName System.IO.Compression.FileSystem
function Set-LastAuthor([string]$path) {
  $who = "The Shaikh Ayaz University, Shikarpur"
  $zip = [System.IO.Compression.ZipFile]::Open($path, "Update")
  try {
    $entry = $zip.Entries | Where-Object { $_.FullName -eq "docProps/core.xml" }
    if (-not $entry) { return }
    $reader = New-Object System.IO.StreamReader($entry.Open())
    $xml = $reader.ReadToEnd(); $reader.Close()
    if ($xml -match "<cp:lastModifiedBy>.*?</cp:lastModifiedBy>") {
      $xml = [regex]::Replace($xml, "<cp:lastModifiedBy>.*?</cp:lastModifiedBy>",
                              "<cp:lastModifiedBy>$who</cp:lastModifiedBy>")
    } else {
      $xml = $xml -replace "</cp:coreProperties>",
                           "<cp:lastModifiedBy>$who</cp:lastModifiedBy></cp:coreProperties>"
    }
    $stream = $entry.Open()
    $stream.SetLength(0)
    $writer = New-Object System.IO.StreamWriter($stream, (New-Object System.Text.UTF8Encoding($false)))
    $writer.Write($xml); $writer.Flush(); $writer.Close()
  } finally { $zip.Dispose() }
}

# note which Word process this script starts, to end only that one if it hangs
$before = @(Get-Process WINWORD -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Id)
$word = New-Object -ComObject Word.Application
$mine = @(Get-Process WINWORD -ErrorAction SilentlyContinue | Where-Object { $before -notcontains $_.Id } |
  Select-Object -ExpandProperty Id)
$word.Visible = $false
$word.DisplayAlerts = 0
try {
  foreach ($file in $Files) {
    $path = (Resolve-Path $file).Path
    $doc = $word.Documents.Open($path, $false, $false)
    try {
      # twice: page numbers in the contents settle once the lists have their final length
      for ($pass = 0; $pass -lt 2; $pass++) {
        [void]$doc.Fields.Update()
        foreach ($t in $doc.TablesOfContents) { [void]$t.Update() }
        foreach ($t in $doc.TablesOfFigures) { [void]$t.Update() }
        foreach ($s in $doc.Sections) {
          foreach ($h in $s.Headers) { [void]$h.Range.Fields.Update() }
          foreach ($h in $s.Footers) { [void]$h.Range.Fields.Update() }
        }
      }
      $doc.Save()
      "Updated " + [System.IO.Path]::GetFileName($path) + " (" + $doc.ComputeStatistics(2) + " pages)"
    } finally {
      try { $doc.Close(0) } catch { }
    }
    Set-LastAuthor $path
  }
} finally {
  try { $word.Quit() } catch { }
  [void][Runtime.InteropServices.Marshal]::ReleaseComObject($word)
  [GC]::Collect(); [GC]::WaitForPendingFinalizers()
  foreach ($id in $mine) {
    $proc = Get-Process -Id $id -ErrorAction SilentlyContinue
    if ($proc -and -not $proc.WaitForExit(5000)) { Stop-Process -Id $id -Confirm:$false }
  }
  foreach ($f in $fonts) { [void][SausFonts]::RemoveFontResourceW($f) }
  [SausFonts]::Broadcast()
}
