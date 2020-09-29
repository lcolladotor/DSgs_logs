library("googlesheets4")
library("glue")

googlesheets4::gs4_auth()

logs_data <-
    read_sheet(
        "https://docs.google.com/spreadsheets/d/1FrOKBI_lTYLNRAfzNi8nTMAXNH3DtL9bUwpVzDjFp9Q/edit?usp=sharing",
        sheet = "logs"
    )

## Make the names anonymous
set.seed(20200928)
logs_data$person <- paste0("Person_", sample(as.numeric(as.factor(logs_data$person))))

dir.create("website_files", showWarnings = FALSE)

by_guide <- split(logs_data, logs_data$guide_name)

xx <- lapply(seq_along(by_guide), function(i) {
    guide <- names(by_guide)[i]

    by_person <- split(by_guide[[i]], by_guide[[i]]$person)
    entries <- do.call(rbind, lapply(by_person, function(x) {
        data.frame(
            entry = glue_data(
                x,
                "
### {date}

#### Help request

{help_request}

#### Public Notes

{public_notes}

"
            )
        )
    }))
    entries$person <- rownames(entries)

    content_rmd <- paste(glue_data(entries, "
## {person}

{entry}

"), collapse = "")
    chapter_rmd <- glue("
# {guide}

{content_rmd}

")
    writeLines(chapter_rmd, here::here("website_files", paste0(guide, ".Rmd")))
})
