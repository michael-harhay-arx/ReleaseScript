# Author: Michael Harhay
# Copyright: Arxtron Technologies Inc.. All Rights Reserved.
# Date: 2025/10/17 
# Description: This script automates release creation and DLL
#              generation for Arxtron CVI projects.


# ----------------------- Setup ----------------------- #
$glbCurrentBranch = git branch --show-current
$glbLibName = Split-Path -Path (Get-Location) -Leaf

$glbPrjFilePath = Get-ChildItem -Path $Root -Filter *.prj -File | Select-Object -First 1 -ExpandProperty FullName


# ------------------ Main Execution ------------------- #

# 1. Checkout master and merge from release
Write-Host "`n==> Checking out master branch..." -ForegroundColor Cyan
git checkout master

if ($LASTEXITCODE -ne 0)
{
    Write-Host "Error: was not able to checkout master" -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    exit 1
}

Write-Host "`n==> Merging latest changes from release..." -ForegroundColor Cyan
git fetch origin
git merge release --no-ff -m "$releaseNotes"

if ($LASTEXITCODE -ne 0)
{
    Write-Host "Error: unsuccessful merge." -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    exit 1
}



# 2. Tag release, commit and push
Write-Host "`n==> Committing & pushing to master branch..." -ForegroundColor Cyan

$prjFileContent = Get-Content $glbPrjFilePath -Raw
if ($prjFileContent -match 'Numeric File Version\s*=\s*"([\d,]+)"') 
{
    $versionNum = $Matches[1]
    Write-Host "Current version: $versionNum"
} 
else 
{
    Write-Host "Error: no project version number found." -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    exit 1
}

$tagNum = "v" + $versionNum
$releaseNotes = git log -1 --pretty=%B

git tag $tagNum
git push origin master



# 3. Change directory to SourceLibraries, commit changes
Write-Host "`n==> Committing change to SourceLibraries..." -ForegroundColor Cyan

cd ..
cd ..
$currentDir = Split-Path -Path (Get-Location) -Leaf
while ($currentDir -ne "SourceLibraries")
{
    Write-Host "Could not find SourceLibraries." -ForegroundColor Yellow
    $srcLibPath = Read-Host "Please enter path:"
}
cd srcLibPath

git add $glbLibName
git commit -m "New release for ${glbLibName}: $tagNum"
git push origin master



# 4. End script

git checkout $currentBranch
Write-Host "`nScript execution complete." -ForegroundColor Green
Read-Host "Press Enter to exit..."