$currentDirectory = split-path $MyInvocation.MyCommand.Definition

# See if we have the ClientSecret available
if ([string]::IsNullOrEmpty($env:SignClientSecret)) {
    Write-Host "Client Secret not found, not signing packages"
    return;
}

dotnet tool install --tool-path . SignClient

# Setup Variables we need to pass into the sign client tool
$appSettings = "$currentDirectory\SignClient.json"

$nupgks = Get-ChildItem -Recurse $Env:ArtifactDirectory\*.nupkg | Select-Object -ExpandProperty FullName

foreach ($nupkg in $nupgks) {

    $fileList = "";

    if($nupkg.Contains("Uno.SourceGenerationTasks")) {
        Write-Host "Submitting $nupkg for signing"
        .\SignClient 'sign' -c $appSettings -i $nupkg -r $env:SignClientUser -s $env:SignClientSecret -n "$env:SignPackageName" -d "$env:SignPackageDescription" -u "$env:build_repository_uri" -f $currentDirectory\NugetSignedFiles.txt
        Write-Host "Finished signing $nupkg"
    }
    else {
        Write-Host "Submitting $nupkg for signing"
        .\SignClient 'sign' -c $appSettings -i $nupkg -r $env:SignClientUser -s $env:SignClientSecret -n "$env:SignPackageName" -d "$env:SignPackageDescription" -u "$env:build_repository_uri"
        Write-Host "Finished signing $nupkg"
    }
}

Write-Host "Sign-package complete"
