param(
    [ValidateSet('Setup', 'Generate', 'Build', 'Open')]
    [string]$Action = 'Setup',
    [string]$EngineRoot
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$projectFile = Join-Path $projectRoot 'Anima.uproject'
$project = Get-Content -Raw -LiteralPath $projectFile | ConvertFrom-Json
$engineId = $project.EngineAssociation
$buildsKey = 'HKCU:\Software\Epic Games\Unreal Engine\Builds'

if (-not $EngineRoot) {
    $parentRoot = Split-Path -Parent $projectRoot
    $siblingEngineRoot = Join-Path $parentRoot 'InstalledBuild'
    if (Test-Path -LiteralPath (Join-Path $siblingEngineRoot 'Engine\Build\InstalledBuild.txt')) {
        $EngineRoot = $siblingEngineRoot
    }
    elseif (Test-Path -LiteralPath $buildsKey) {
        $EngineRoot = (Get-Item -LiteralPath $buildsKey).GetValue($engineId)
    }
    if (-not $EngineRoot) {
        throw 'Run SetupProject.cmd -EngineRoot "path to InstalledBuild" to select the engine.'
    }
}
$EngineRoot = (Resolve-Path -LiteralPath $EngineRoot).Path
$buildScript = Join-Path $EngineRoot 'Engine\Build\BatchFiles\Build.bat'
$editor = Join-Path $EngineRoot 'Engine\Binaries\Win64\UnrealEditor.exe'
$installedMarker = Join-Path $EngineRoot 'Engine\Build\InstalledBuild.txt'
foreach ($required in @($buildScript, $editor, $installedMarker)) {
    if (-not (Test-Path -LiteralPath $required)) { throw "Required installed build file is missing: $required" }
}
$version = Get-Content -Raw -LiteralPath (Join-Path $EngineRoot 'Engine\Build\Build.version') | ConvertFrom-Json
if ($version.MajorVersion -ne 5 -or $version.MinorVersion -ne 8 -or $version.PatchVersion -ne 3) {
    throw 'This project uses the Unreal Engine 5.8.3 installed build from Perforce changelist 102.'
}

if ($Action -eq 'Setup') {
    New-Item -Path $buildsKey -Force | Out-Null
    New-ItemProperty -LiteralPath $buildsKey -Name $engineId -Value $EngineRoot -PropertyType String -Force | Out-Null
    Write-Host "Registered Anima engine: $EngineRoot"
}
if ($Action -in @('Setup', 'Generate')) {
    & $buildScript -ProjectFiles "-Project=$projectFile" -Game -Engine -2022
    if ($LASTEXITCODE -ne 0) { throw "Project file generation failed (exit $LASTEXITCODE)." }
}
if ($Action -in @('Setup', 'Build')) {
    & $buildScript AnimaEditor Win64 Development "-Project=$projectFile" -WaitMutex -NoHotReloadFromIDE -NoEngineChanges
    if ($LASTEXITCODE -ne 0) { throw "Editor build failed (exit $LASTEXITCODE)." }
}
if ($Action -eq 'Open') {
    if (-not (Test-Path -LiteralPath (Join-Path $projectRoot 'Binaries\Win64\UnrealEditor-Anima.dll'))) {
        throw 'Build the project first with SetupProject.cmd or BuildEditor.cmd.'
    }
    Start-Process -FilePath $editor -ArgumentList ('"' + $projectFile + '"') -WindowStyle Normal
}
