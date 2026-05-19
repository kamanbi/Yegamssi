param(
  [string]$SourceImage = "F:\Yegamssi\etc\EGS.png"
)

$targets = @{
  "mipmap-mdpi" = 48
  "mipmap-hdpi" = 72
  "mipmap-xhdpi" = 96
  "mipmap-xxhdpi" = 144
  "mipmap-xxxhdpi" = 192
}

if (-not (Test-Path $SourceImage)) {
  Write-Error "Launcher source image not found: $SourceImage"
  exit 1
}

Add-Type -AssemblyName System.Drawing

$root = "F:\Yegamssi\android\app\src\main\res"
$source = [System.Drawing.Image]::FromFile($SourceImage)

try {
  foreach ($entry in $targets.GetEnumerator()) {
    $dir = Join-Path $root $entry.Key
    $path = Join-Path $dir "ic_launcher.png"
    $size = [int]$entry.Value

    $bitmap = New-Object System.Drawing.Bitmap $size, $size
    try {
      $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
      try {
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $graphics.Clear([System.Drawing.Color]::Transparent)
        $graphics.DrawImage($source, 0, 0, $size, $size)
      } finally {
        $graphics.Dispose()
      }

      $bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
      Write-Output "Updated $path"
    } finally {
      $bitmap.Dispose()
    }
  }
} finally {
  $source.Dispose()
}
