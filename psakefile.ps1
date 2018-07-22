Properties {
    $Name = 'PSBuilder'
    $PublishRepository = "PSGallery"
    $CodeCoverageMin = 60
}

Include "$PSScriptRoot/src/files/build.tasks.ps1"