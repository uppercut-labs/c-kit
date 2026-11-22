# The kit's full check on Windows (PowerShell 5.1 or 7): for every package under packages/, configure, build and run its
# tests, then build the example consumer project against the package's own source. Needs CMake, Ninja, a C compiler,
# SDL3 and Python 3. On a machine with MSYS2 that is C:\msys64\ucrt64\bin first on PATH.
#
#   .\tools\check.ps1 [-Compiler clang] [-SdlPrefix <SDL3 install prefix>]
#
# Build output goes to build\<package>\ in this checkout.
param(
    [string]$Compiler = "clang",
    [string]$SdlPrefix = ""
)
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$common = @("-G", "Ninja", "-DCMAKE_BUILD_TYPE=Release", "-DCMAKE_C_COMPILER=$Compiler")
if ($SdlPrefix) { $common += "-DCMAKE_PREFIX_PATH=$SdlPrefix" }

function Invoke-Native {
    param([string]$Exe, [string[]]$Arguments)
    & $Exe @Arguments
    if ($LASTEXITCODE) { throw "$Exe failed with exit code $LASTEXITCODE" }
}

foreach ($pkg in Get-ChildItem -Path (Join-Path $root "packages") -Directory) {
    $name = $pkg.Name
    $build = Join-Path $root "build\$name"
    Write-Host "== $name"
    Invoke-Native cmake (@("-S", $pkg.FullName, "-B", $build) + $common)
    Invoke-Native cmake @("--build", $build)
    Invoke-Native ctest @("--test-dir", $build, "--output-on-failure")
    $consumer = Join-Path $pkg.FullName "examples\consumer"
    if (Test-Path (Join-Path $consumer "CMakeLists.txt")) {
        Write-Host "== ${name}: the example consumer"
        $cbuild = Join-Path $root "build\$name-consumer"
        Invoke-Native cmake (@("-S", $consumer, "-B", $cbuild, "-DFETCHCONTENT_SOURCE_DIR_PORT_INPUT_HARNESS=$root") + $common)
        Invoke-Native cmake @("--build", $cbuild)
        Invoke-Native ctest @("--test-dir", $cbuild, "--output-on-failure")
    }
}
Write-Host "check: all packages passed"
