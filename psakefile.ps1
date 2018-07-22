Properties {
    $Name = 'PSBuilder'
    $PublishRepository = "Test"
    $CodeCoverageMin = 60
}

Include "$PSScriptRoot/src/files/build.tasks.ps1"