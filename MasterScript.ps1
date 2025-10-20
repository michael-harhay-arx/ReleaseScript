# Author: Michael Harhay
# Copyright: Arxtron Technologies Inc.. All Rights Reserved.
# Date: 2025/10/17 
# Description: This script automates updating the master
#              branch after a new release is made. Should
#              be run after ReleaseScript.ps1


# ----------------------- Setup ----------------------- #
$glbCurrentBranch = git branch --show-current
$glbLibName = Split-Path -Path (Get-Location) -Leaf
$glbLibPathName = "LabWindows\" + $glbLibName

$glbPrjFilePath = Get-ChildItem -Path $Root -Filter *.prj -File | Select-Object -First 1 -ExpandProperty FullName


# ------------------ Main Execution ------------------- #

# 1. Get version number and release notes from release branch
git checkout release

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



# 2. Pull master branch
Write-Host "`n==> Fetching remote master branch..." -ForegroundColor Cyan
git checkout master
git pull origin master



# 3. Tag release, commit and push
Write-Host "`n==> Tagging release & pushing to remote..." -ForegroundColor Cyan
$tagNum = "v" + $versionNum
git tag $tagNum
git push origin --tags



# 4. Change directory to SourceLibraries, commit changes
Write-Host "`n==> Committing change to SourceLibraries..." -ForegroundColor Cyan

cd ..
cd ..
$currentDir = Split-Path -Path (Get-Location) -Leaf
while ($currentDir -ne "SourceLibraries")
{
    Write-Host "Could not find SourceLibraries." -ForegroundColor Yellow
    $srcLibPath = Read-Host "Please enter path:"
}
cd $srcLibPath

git add $glbLibPathName
git commit -m "New release for ${glbLibName}: $tagNum"
git push origin master



# 5. End script
git checkout $currentBranch
Write-Host "`nScript execution complete." -ForegroundColor Green
Read-Host "Press Enter to exit..."