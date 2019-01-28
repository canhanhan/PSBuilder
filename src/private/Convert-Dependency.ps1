function Convert-Dependency
{
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [object]$InputObject,

        [string]$Repository
    )

    if ($InputObject -is [string])
    {
        $dependency = @{ Name = $InputObject }
    }
    elseif ($InputObject -is [hashtable])
    {
        $dependency = $InputObject
    }
    else
    {
        throw "Unknown dependency type $($InputObject.GetType()). Dependency must be either string or hashtable."
    }

    if (-not $dependency.ContainsKey("External"))
    {
        $dependency.External = $false
    }

    if (-not [string]::IsNullOrEmpty($Repository) -and -not $dependency.ContainsKey("Repository"))
    {
        $dependency.Repository = $Repository
    }

    $dependency
}
