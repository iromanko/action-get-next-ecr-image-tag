#!/bin/env pwsh
[CmdletBinding()]
param (
    [String]$Registry = $env:INPUT_REGISTRY,
    [String]$RepositoryName = $env:INPUT_REPOSITORY_NAME,
    [String]$MajorMinorVersion = $env:INPUT_MAJOR_MINOR_VERSION,
    [String]$PreReleaseTag = $env:INPUT_PRE_RELEASE_TAG
)

$suffix = if ($PreReleaseTag) { "-$PreReleaseTag" } else { "" }
$tag_pattern = "$($MajorMinorVersion.Replace('.','\.'))$($suffix)\.(\d+)"

$tags = (aws ecr list-images --repository-name $RepositoryName | ConvertFrom-Json).imageIds.imageTag
$greatest_build_number = $tags | Where-Object { $_ -match $tag_pattern } | ForEach-Object { [int]($matches.1) } | Sort-Object -Descending | Select-Object -First 1

$next_build_number = if ($greatest_build_number) { $greatest_build_number + 1 } else { 0 }

$next_tag = "$($MajorMinorVersion)$($suffix).$($next_build_number)"
$next_image_name = "$Registry/$($RepositoryName):$next_tag"

Write-Host "::set-output name=next-tag::$next_tag"
Write-Host "::set-output name=next-image-name::$next_image_name"
