library("googlesheets4")
library("glue")
library("gargle")
library("here")

googlesheets4::gs4_auth(token = gargle::secret_read_rds(
    here::here(".secrets/gs4-token.rds"),
    key = "GOOGLESHEETS4_KEY"
))

logs_data <-
    read_sheet(
        "https://docs.google.com/spreadsheets/d/1FrOKBI_lTYLNRAfzNi8nTMAXNH3DtL9bUwpVzDjFp9Q/edit?usp=sharing",
        sheet = "logs"
    )

## Avoid accents
logs_data$guide_name[logs_data$guide_name == "Hédia"] <- "Hedia"

## Sort by date
logs_data <- logs_data[order(logs_data$date, decreasing = TRUE), ]

## Make the names anonymous
set.seed(20200928)
logs_data$person <- paste0("Person_", sample(as.numeric(as.factor(logs_data$person))))

## Remove the private info
logs_data$private_team_notes <- NULL

dir.create("old_format_website_files", showWarnings = FALSE)

by_guide <- split(logs_data, logs_data$guide_name)

xx <- lapply(seq_along(by_guide), function(i) {
    guide <- names(by_guide)[i]
    message("Processing guide: ", guide)

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
    writeLines(chapter_rmd, here::here("old_format_website_files", paste0(guide, ".Rmd")))
})


## Save for later use
save(logs_data, file = here::here("logs_data.Rdata"))
