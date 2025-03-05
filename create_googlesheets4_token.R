## Adapted from https://gargle.r-lib.org/articles/managing-tokens-securely.html

library("gargle")
key <- secret_make_key()
usethis::edit_r_environ() ## Add the output there manually

dir.create(here::here(".secrets"))

# get a token and DO NOT CACHE IT
googlesheets4::gs4_auth("fellgernon@gmail.com", cache = FALSE)

# encrypt the token and write to file
gargle::secret_write_rds(
    googlesheets4::gs4_token(),
    here::here(".secrets/gs4-token.rds"),
    key = "GOOGLESHEETS4_KEY"
)
