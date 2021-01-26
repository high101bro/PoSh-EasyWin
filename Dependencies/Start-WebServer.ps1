<#PSScriptInfo
    .VERSION 1.1

    .GUID 9c74d64a-774d-4f5a-a8c4-485fd079e7bd

    .AUTHOR Oliver Lipkau <oliver@lipkau.net>

    .COMPANYNAME

    .COPYRIGHT Lipkau.net

    .TAGS localhost php start-WebServer host server

    .LICENSEURI https://opensource.org/licenses/MIT

    .PROJECTURI

    .ICONURI

    .EXTERNALMODULEDEPENDENCIES

    .REQUIREDSCRIPTS

    .EXTERNALSCRIPTDEPENDENCIES

    .RELEASENOTES
#>

<#
    .SYNOPSIS
        Start a local http server

    .DESCRIPTION
        Start a local http server on a specific port.

        REQUIRES: php to be installed and available in $env:path

    .NOTES
        Author : Oliver Lipkau <oliver@lipkau.net>
        Source : https://gist.github.com/lipkau/105f07f8dacd3800dcd62d4dbad5539c

    .INPUTS
        System.String
        System.Integer

    .EXAMPLE
        Start-WebServer -Path "C:\www\myProject\public" -Port 8080
        -----------
        Description
        Makes the specified Path availble at http://localhost:8080
#>

Param()

function Start-WebServer
{
    [CmdletBinding()]
    param(
        # Specifies the path which should be made available in http server.
        [ValidateScript({(Test-Path $_ -IsValid)})]
        [Parameter(Position = 0, Mandatory = $false)]
        [string]$Path = $pwd.Path,

        # Specifies the port of the http server.
        [Parameter(Position = 1, Mandatory = $false)]
        [int]$Port = 80
    )

    Begin {
        function Test-PHPinPath
        {
            $env:path -split ";" | ForEach-Object -Begin {$containsPHP = @()} -Process {$containsPHP += Test-Path "$_\php.exe"} -End {$containsPHP -contains $true}
        }

        if (Test-PHPinPath) {
            Throw "Could not find php.exe in PATH"
        }

        Start-Process -WorkingDirectory $Path -FilePath php -ArgumentList @("-S localhost:$Port")
    }
}

