library("usethis")
create_package("DSgs_logs")
dir.create("dev", showWarnings = FALSE)
edit_file("dev/01_setup.R")

use_git()
