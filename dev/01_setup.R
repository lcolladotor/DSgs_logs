library("usethis")
create_package("DSgs_logs")
dir.create("dev", showWarnings = FALSE)
edit_file("dev/01_setup.R")

use_git()
dir.create(".github/workflows", recursive = TRUE)
file.copy("../bioc_team_ds/.github/workflows/build_book_bioc_docker.yml", ".github/workflows/")

use_github()
