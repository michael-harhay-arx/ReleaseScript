# Author: Michael Harhay
# Copyright: Arxtron Technologies Inc.. All Rights Reserved.
# Date: 2025/10/17 
# Description: This script automates release creation and DLL
#              generation for Arxtron CVI projects.


# ----------------------- Setup ----------------------- #
$glbCurrentBranch = git branch --show-current
$glbLibName = Split-Path -Path (Get-Location) -Leaf


# ------------------ Main Execution ------------------- #

# 1. Checkout master and merge from release
Write-Host "`n==> Checking out master branch..." -ForegroundColor Cyan
git checkout master

if ($LASTEXITCODE -ne 0)
{
    Write-Host "Error: was not able to checkout master" -ForegroundColor Red
    exit 1
}

Write-Host "`n==> Merging latest changes from release..." -ForegroundColor Cyan
git fetch origin
git merge release --no-ff

if ($LASTEXITCODE -ne 0)
{
    Write-Host "Error: unsuccessful merge." -ForegroundColor Red
    exit 1
}



# 2. Tag release, commit and push
Write-Host "`n==> Committing & pushing to master branch..." -ForegroundColor Cyan

$tagNum = "v" + "1.0.0.0"
git tag $tagNum
git commit -m "$releaseNotes"
git push origin master



# 3. Change directory to SourceLibraries, commit changes
cd ..
$currentDir = Split-Path -Path (Get-Location) -Leaf
while ($currentDir -ne "SourceLibraries")
{
    $srcLibPath = Read-Host "Could not find SourceLibraries. Please enter path:" -ForegroundColor Yellow
}
cd srcLibPath

git add $glbLibName
git commit -m "New release for ${glbLibName}: $tagNum"
git push origin master



# 4. End script

git checkout $currentBranch
Write-Host "`nScript execution complete." -ForegroundColor Green
