library("googlesheets4")
library("glue")

googlesheets4::gs4_auth()

logs_data <-
    read_sheet(
        "https://docs.google.com/spreadsheets/d/1FrOKBI_lTYLNRAfzNi8nTMAXNH3DtL9bUwpVzDjFp9Q/edit?usp=sharing",
        sheet = "logs"
    )

## Sort by date
logs_data <- logs_data[order(logs_data$date, decreasing = TRUE), ]

## Make the names anonymous
set.seed(20200928)
logs_data$person <- paste0("Person_", sample(as.numeric(as.factor(logs_data$person))))

## Remove the private info
logs_data$private_team_notes <- NULL

dir.create("website_files", showWarnings = FALSE)

by_guide <- split(logs_data, logs_data$guide_name)

xx <- lapply(seq_along(by_guide), function(i) {
    guide <- names(by_guide)[i]

    by_entry <- split(by_guide[[i]], seq_len(nrow(by_guide[[i]])))
    entries <- do.call(rbind, lapply(by_entry, function(x) {
        data.frame(
            entry = paste(glue_data(
                x,
                "| {date} | {help_request} | {public_notes} |"
            ), collapse = "")
        )
    }))

    content_rmd <- paste(glue_data(entries, "{entry}"), collapse = "\n")
    chapter_rmd <- glue("
# {guide}

| Date | Help request | Notes |
| ---- | ------------ | ----- |
{content_rmd}

")
    writeLines(chapter_rmd, here::here("website_files", paste0(guide, ".Rmd")))
})


## Save for later use
logs_data$help_request <- NULL
logs_data$public_notes <- NULL
save(logs_data, file = "logs_data.Rdata")
