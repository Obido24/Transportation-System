Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourcePath = Join-Path $root 'New_logo.jpeg'
$masterPath = Join-Path $root 'i_metro\app\assets\brand\launcher_bus_master.png'

if (-not (Test-Path $sourcePath)) {
    throw "Missing source image: $sourcePath"
}

function New-CanvasImage {
    param(
        [int]$Size,
        [System.Drawing.Image]$Source,
        [System.Drawing.Rectangle]$Crop,
        [string]$OutFile,
        [double]$ScalePadding = 0.90
    )

    $bmp = New-Object System.Drawing.Bitmap $Size, $Size
    $gfx = [System.Drawing.Graphics]::FromImage($bmp)
    try {
        $gfx.Clear([System.Drawing.Color]::White)
        $gfx.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $gfx.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $gfx.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $gfx.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality

        $target = [int]($Size * $ScalePadding)
        $scale = [Math]::Min($target / $Crop.Width, $target / $Crop.Height)
        $w = [int]([Math]::Round($Crop.Width * $scale))
        $h = [int]([Math]::Round($Crop.Height * $scale))
        $x = [int](($Size - $w) / 2)
        $y = [int](($Size - $h) / 2)

        $dest = New-Object System.Drawing.Rectangle $x, $y, $w, $h
        $gfx.DrawImage($Source, $dest, $Crop, [System.Drawing.GraphicsUnit]::Pixel)
        $bmp.Save($OutFile, [System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
        $gfx.Dispose()
        $bmp.Dispose()
    }
}

$src = [System.Drawing.Image]::FromFile($sourcePath)
try {
    # Tight crop so the launcher icon reads like a bus mark on the phone instead of the full poster.
    $crop = New-Object System.Drawing.Rectangle 120, 220, 1010, 470

    New-CanvasImage -Size 1024 -Source $src -Crop $crop -OutFile $masterPath -ScalePadding 0.90

    $androidSizes = @{
        'mipmap-mdpi'    = 48
        'mipmap-hdpi'    = 72
        'mipmap-xhdpi'   = 96
        'mipmap-xxhdpi'  = 144
        'mipmap-xxxhdpi' = 192
    }

    foreach ($entry in $androidSizes.GetEnumerator()) {
        $dir = Join-Path $root ('i_metro\app\android\app\src\main\res\' + $entry.Key)
        $out = Join-Path $dir 'ic_launcher.png'
        New-CanvasImage -Size $entry.Value -Source $src -Crop $crop -OutFile $out -ScalePadding 0.90
    }

    $iosDir = Join-Path $root 'i_metro\app\ios\Runner\Assets.xcassets\AppIcon.appiconset'
    $iosSizes = @(
        @{ File='Icon-App-20x20@1x.png'; Size=20 },
        @{ File='Icon-App-20x20@2x.png'; Size=40 },
        @{ File='Icon-App-20x20@3x.png'; Size=60 },
        @{ File='Icon-App-29x29@1x.png'; Size=29 },
        @{ File='Icon-App-29x29@2x.png'; Size=58 },
        @{ File='Icon-App-29x29@3x.png'; Size=87 },
        @{ File='Icon-App-40x40@1x.png'; Size=40 },
        @{ File='Icon-App-40x40@2x.png'; Size=80 },
        @{ File='Icon-App-40x40@3x.png'; Size=120 },
        @{ File='Icon-App-60x60@2x.png'; Size=120 },
        @{ File='Icon-App-60x60@3x.png'; Size=180 },
        @{ File='Icon-App-76x76@1x.png'; Size=76 },
        @{ File='Icon-App-76x76@2x.png'; Size=152 },
        @{ File='Icon-App-83.5x83.5@2x.png'; Size=167 },
        @{ File='Icon-App-1024x1024@1x.png'; Size=1024 }
    )

    foreach ($icon in $iosSizes) {
        $out = Join-Path $iosDir $icon.File
        New-CanvasImage -Size $icon.Size -Source $src -Crop $crop -OutFile $out -ScalePadding 0.90
    }

    Write-Host "Launcher icons generated."
}
finally {
    $src.Dispose()
}
