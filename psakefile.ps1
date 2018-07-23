Properties {
    $Name = 'PSBuilder'
    $PublishRepository = "PSGalleryPreview"
    $CodeCoverageMin = 60
}

Include "$PSScriptRoot/src/files/build.tasks.ps1"