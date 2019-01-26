function ReplaceString($str)
{
    return "'" + ($str -Replace "'","''") + "'"
}

function ProcessValue($InputObject)
{
  if ($InputObject -is [string])
  {
        return ReplaceString $InputObject
  }
  elseif ($InputObject -is [object[]])
  {
      if ($InputObject.Count -eq 0)
      {
            return '@()'
      }
      elseif ($InputObject.Count -eq 1)
      {
            return "@($((ProcessValue $InputObject) -replace "`r`n", "`r`n`t"))"
      }
      else
      {
          $arrayBuilder = [System.Text.StringBuilder]::new()
          [void]$arrayBuilder.AppendLine("(")
          for ($i=0; $i -lt $InputObject.Count; $i++)
          {
              $suffix = if ($i+1 -eq $InputObject.Count) { "" } else { "," }
              $value = (ProcessValue $InputObject[$i]) -replace "`r`n", "`r`n`t"
              $value = $value -replace "`r`n`t$", ""
              [void]$arrayBuilder.AppendLine("`t$value$suffix")
          }
          [void]$arrayBuilder.AppendLine(")")
          return $arrayBuilder.ToString()
      }
  }
  elseif ($InputObject -is [hashtable] -or $InputObject -is [System.Collections.Specialized.OrderedDictionary])
  {
        $hashtableBuilder = [System.Text.StringBuilder]::new()
        [void]$hashtableBuilder.AppendLine("@{")
        foreach ($key in @($InputObject.Keys))
        {
            [void]$hashtableBuilder.AppendLine("`t$key = $((ProcessValue $InputObject[$key]) -replace "`r`n", "`r`n`t")")
        }
        [void]$hashtableBuilder.AppendLine("}")
        return $hashtableBuilder.ToString()
  }
  elseif ($InputObject -is [bool])
  {
        if ($InputObject)
        {
            return '$true'
        }
        else
        {
            return '$false'
        }
  }
  else
  {
        throw "Unknown type: $($InputObject.GetType())"
  }
}

function New-DataFile
{
  param (
    [Parameter(Mandatory=$true)]
    [string]$Path,

    [Parameter(Mandatory=$true)]
    [object]$Data
  )

  $value = ProcessValue $Data
  [IO.File]::WriteAllText($Path, $value)
}