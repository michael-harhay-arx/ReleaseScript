# Author: Michael Harhay
# Copyright: Arxtron Technologies Inc.. All Rights Reserved.
# Date: 2025/10/15 
# Description: This script automates release creation and DLL
# generation for Arxtron CVI projects.


# ---------------------- Config ----------------------- #
$glbBuildFilePath = "C:\Arxtron\RD25XXX_CICD\Source\TestLib.dll"
$glbPrjFilePath = "C:\Arxtron\RD25XXX_CICD\Source\TestLib.prj"
$glbLogFilePath = "C:\Arxtron\RD25XXX_CICD\build_log.txt"

$glbCompilerPath = "C:\Program Files (x86)\National Instruments\CVI2019\compile.exe"
$glbDLLTargetFolder = "C:\Arxtron\RD25XXX_CICD\DLLs"


# ----------------------- Code ------------------------ #

# 1. Set up release branch

# Check if release branch exists, if not create it
Write-Host "`n==> Checking for release branch..." -ForegroundColor Cyan

if (git rev-parse --verify --quiet release) 
{
    Write-Host "Release branch exists, checking out."
    #git checkout release
}
else
{
    Write-Host "Release branch does not exist locally, creating it."
    #git checkout -b release
}

if ($LASTEXITCODE -ne 0)
{
    Write-Host "Error - exiting script." -ForegroundColor Red
    exit 1
}


# Merge target branch into release (ask user to input target branch)
$targetBranch = "develop" # 20251015 Michael: TODO ask for user input

Write-Host "`n==> Merging latest changes from $targetBranch into release..." -ForegroundColor Cyan
#git fetch origin
#git merge origin/$targetBranch --no-ff

if ($LASTEXITCODE -ne 0)
{
    Write-Host "Error merging - exiting script." -ForegroundColor Red
    exit 1
}



# 2. Version info / release notes questionnaire

# Get and update version info
Write-Host "`n==> Checking previous DLL version..." -ForegroundColor Cyan

$versionNum = (Get-Item $glbBuildFilePath).VersionInfo.FileVersionRaw
Write-Host "Current version: $versionNum"

[bool]$versionIncremented = $false
$major = $versionNum.Major
$minor = $versionNum.Minor
$build = $versionNum.Build
$revision = $versionNum.Revision

while ($versionIncremented -ne $true)
{
    $incrementType = Read-Host "`nVersion increment type? (major / minor / build / revision)"

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
            Write-Host "Invalid input. No version increment performed." -ForegroundColor Red
        }
    }
}

$newVersionNum = "$major,$minor,$build,$revision"
Write-Host "New version number: $newVersionNum" -ForegroundColor Green


# Get release notes
Write-Host "`n==> Enter release notes in Notepad. Save and close to continue..." -ForegroundColor Cyan

$tempFile = [System.IO.Path]::GetTempFileName()
Set-Content $tempFile "# Enter release notes below. Lines starting with # are ignored.`n"
Start-Process notepad $tempFile -Wait

# Read file contents, ignoring comment lines and blanks
$releaseNotes = Get-Content $tempFile | Where-Object { $_ -and ($_ -notmatch '^\s*#') }

# Clean up temp file, display release notes
Remove-Item $tempFile -ErrorAction SilentlyContinue

$formattedNotes = $releaseNotes -join "`n"
Write-Host "`tRelease notes:`n" -ForegroundColor Green
Write-Host $formattedNotes



# 3. Compile
Write-Host "`n==> Compiling project..." -ForegroundColor Cyan
#"$glbCompilerPath" /build "$glbPrjFilePath" /fileVersion $newVersionNum /out "$glbLogFilePath"
& $glbCompilerPath $glbPrjFilePath -fileVersion $newVersionNum -log $glbLogFilePath
$CompileSuccess = Select-String -Path $glbLogFilePath -Pattern "Build succeeded" -Quiet

#$CompileSuccess = $true # 20251015 Michael: use to simulate compilation results, delete later and uncomment actual compilation

if ($CompileSuccess) 
{
    Write-Host "Compilation successful." -ForegroundColor Green
} 
else 
{
    Write-Host "Compilation failed. Check build_log.txt for details." -ForegroundColor Red
    #exit 1
}



# 4. Successful compilation, copy to DLL folder and commit
Write-Host "`n==> Copying DLL to target folder..." -ForegroundColor Cyan
Copy-Item -Path $glbBuildFilePath -Destination $glbDLLTargetFolder

Write-Host "`n==> Committing to release branch..." -ForegroundColor Cyan
#git add -A
#git commit -m "$formattedNotes" 



# 5. Run CI/CD, recompile if necessary
Write-Host "`n==> Running CI/CD tests..." -ForegroundColor Cyan
[bool]$versionIncremented = $true

# Run checks... set $buildOK
if ($buildOk -eq $true)
{
    Write-Host "CI/CD passed." -ForegroundColor Green
}
else
{
    Write-Host "CI/CD failed." -ForegroundColor Red
}

# 6. Create pull request
Write-Host "`n==> Creating GitHub pull request..." -ForegroundColor Cyan

Write-Host "`nScript execution complete." -ForegroundColor Green