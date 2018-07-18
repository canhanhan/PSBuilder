function Exit-Powershell {
   param ([int]$ExitCode=0)

   exit $ExitCode
}