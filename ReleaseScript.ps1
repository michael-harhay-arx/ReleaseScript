# Author: Michael Harhay
# Copyright: Arxtron Technologies Inc.. All Rights Reserved.
# Date: 2025/10/15 
# Description: This script automates release creation and DLL
# generation for Arxtron CVI projects.


# ---------------------- Config ----------------------- #
$glbBuildFilePath = "C:\Arxtron\RD25XXX_CICD\Source\TestLib.dll"
$glbCompilerPath = "C:\Program Files (x86)\National Instruments\CVI2019\compile.exe"
$glbDLLTargetFolder = "C:\Arxtron\RD25XXX_CICD\DLLs"

# ----------------------- Code ------------------------ #


# 1. Set up release branch

# Check if release branch exists, if not create it
Write-Host "`n==> Checking for release branch..." -ForegroundColor Cyan

if (git rev-parse --verify --quiet release) 
{
    Write-Host "`tRelease branch exists, checking out."
    #git checkout release
}
else
{
    if ($LASTEXITCODE -ne 0)
    {
        Write-Host "`tError - exiting script." -ForegroundColor Red
        exit 1
    }

    Write-Host "`tRelease branch does not exist locally, creating it."
    #git checkout -b release
}


# Merge target branch into release (ask user to input target branch)
$targetBranch = "develop" # 20251015 Michael: TODO ask for user input

Write-Host "`n==> Merging latest changes from $targetBranch into release..." -ForegroundColor Cyan
#git fetch origin
#git merge origin/$targetBranch --no-ff

if ($LASTEXITCODE -ne 0)
{
    Write-Host "`tError merging - exiting script." -ForegroundColor Red
    exit 1
}



# 2. Version info / release notes questionnaire

# Get and update version info
Write-Host "`n==> Checking previous DLL version..." -ForegroundColor Cyan

$versionNum = (Get-Item $glbBuildFilePath).VersionInfo.FileVersionRaw
Write-Host "`tCurrent version: $version"

[bool]$versionIncremented = $false
$major = $versionNum.Major
$minor = $versionNum.Minor
$build = $versionNum.Build
$revision = $versionNum.Revision

while ($versionIncremented -ne $true)
{
    $incrementType = Read-Host "`n`tVersion increment type? (major / minor / build / revision)"

    switch ($incrementType.ToLower())
    {
        'major' 
        {
            $major++
            $minor = 0
            $build = 0
            $revision = 0
            $versionIncremented = $true
        }
        'minor' 
        {
            $minor++
            $build = 0
            $revision = 0
            $versionIncremented = $true
        }

        'build' {
            $build++
            $revision = 0
            $versionIncremented = $true
        }
        'revision' 
        {
            $revision++
            $versionIncremented = $true
        }
        default 
        {
            Write-Host "`tInvalid input. No version increment performed." -ForegroundColor Red
        }
    }
}

$newVersion = "$major.$minor.$build.$revision"
Write-Host "`tNew version: $newVersion" -ForegroundColor Green


# Get release notes
Write-Host "`n==> Enter release notes. Press Enter twice to finish." -ForegroundColor Cyan
$ReleaseNotes = @()
while ($true) {
    $line = Read-Host ""
    if ([string]::IsNullOrWhiteSpace($line)) 
    { 
        break 
    }
    $ReleaseNotes += $line
}

# 3. Compile



# 4. Run CI/CD, recompile if necessary