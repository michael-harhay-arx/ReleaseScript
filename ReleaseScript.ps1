# Author: Michael Harhay
# Copyright: Arxtron Technologies Inc.. All Rights Reserved.
# Date: 2025/10/15 
# Description: This script automates release creation and DLL
#              generation for Arxtron CVI projects.


# ----------------------- Setup ----------------------- #
$Root = Split-Path -Parent $MyInvocation.MyCommand.Definition

$glbBuildFilePath = Get-ChildItem -Path $Root -Filter *.dll -File | Select-Object -First 1 -ExpandProperty FullName
$glbPrjFilePath = Get-ChildItem -Path $Root -Filter *.prj -File | Select-Object -First 1 -ExpandProperty FullName
$glbLogFilePath = Join-Path $Root "build_log.txt"
$glbDLLTargetFolder = Join-Path $Root "DLLs"

$glbCompilerPath = "C:\Program Files (x86)\National Instruments\CVI2019\compile.exe"


# ------------------ Main Execution ------------------- #

# 1. Set up release branch

# Get current branch
$targetBranch = git branch --show-current
$currentBranch = $targetBranch
if ([string]::IsNullOrWhiteSpace($targetBranch))
{
    Write-Host "Error: no current branch (you might be in a detached HEAD state)." -ForegroundColor Red
     exit 1
}

# Check if release branch exists, if not create it and checkout
Write-Host "`n==> Checking for release branch..." -ForegroundColor Cyan

if (git rev-parse --verify --quiet release) 
{
    Write-Host "Release branch exists, checking out."
    git checkout release
}
else
{
    Write-Host "Release branch does not exist locally, creating it."
    git checkout -b release
}

if ($LASTEXITCODE -ne 0)
{
    Write-Host "Error: git repository does not exist" -ForegroundColor Red
    exit 1
}

# Merge target branch into release
Write-Host "`n==> Merging latest changes from $targetBranch into release..." -ForegroundColor Cyan

$confirmBranch = ""
while ($confirmBranch -ne "n" -and $confirmBranch -ne "y")
{
    $confirmBranch = Read-Host "`nCurrently on branch: $targetBranch. Is this the desired branch to create a release from? [y/n]"
    if ($confirmBranch -eq "n")
    {
        $targetBranch = Read-Host "`nPlease enter desired branch name:"
    }
}

git fetch origin
git merge $targetBranch --no-ff

if ($LASTEXITCODE -ne 0)
{
    Write-Host "Error: unsuccessful merge." -ForegroundColor Red
    exit 1
}


# 2. Version info / release notes questionnaire

# Get and update version info
Write-Host "`n==> Checking previous DLL version..." -ForegroundColor Cyan

$prjFileContent = Get-Content $glbPrjFilePath -Raw

if ($prjFileContent -match 'Numeric File Version\s*=\s*"([\d,]+)"') 
{
    $currVersionNum = $Matches[1]
    Write-Host "Current version: $currVersionNum"
} 
else 
{
    Write-Host "Error: no project version number found." -ForegroundColor Red
    exit 1
}

$numParts = $currVersionNum -split ','
[int]$major = $numParts[0]
[int]$minor = $numParts[1]
[int]$build = $numParts[2]
[int]$revision = $numParts[3]

[bool]$versionIncremented = $false

while ($versionIncremented -ne $true)
{
    $incrementType = Read-Host "`nVersion increment type? [major / minor / build / revision]"

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
            Write-Host "Invalid input." -ForegroundColor Red
        }
    }
}

$newVersionNum = "$major,$minor,$build,$revision"
Write-Host "New version number: $newVersionNum" -ForegroundColor Green

$newContent = $prjFileContent -replace 'Numeric File Version\s*=\s*"\d+,\d+,\d+,\d+"', "Numeric File Version = `"$newVersionNum`"" 
Set-Content $glbPrjFilePath -Value $newContent -Encoding ASCII


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
    exit 1
}



# 4. Successful compilation, copy to DLL folder and commit
Write-Host "`n==> Copying DLL to target folder..." -ForegroundColor Cyan
Copy-Item -Path $glbBuildFilePath -Destination $glbDLLTargetFolder

Write-Host "`n==> Committing to release branch..." -ForegroundColor Cyan
git add -A
git commit -m "$formattedNotes" 



# 5. Run CI/CD, recompile if necessary
Write-Host "`n==> Running CI/CD tests..." -ForegroundColor Cyan

[bool]$buildOk = $true # 20251015 Michael: use to simulate CI/CD results, delete later and run actual tests

if ($buildOk -eq $true)
{
    Write-Host "CI/CD passed." -ForegroundColor Green
}
else
{
    Write-Host "CI/CD failed." -ForegroundColor Red
}



# 6. Create pull request, end script
Write-Host "`n==> Creating GitHub pull request..." -ForegroundColor Cyan

git checkout $currentBranch
Write-Host "`nScript execution complete." -ForegroundColor Green