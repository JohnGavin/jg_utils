##' .. content for \description{} (no empty lines) ..
##'
##' .. content for \details{} ..
##'
##' @title Read csv but fix warning and look at lots of rows.
##' @param fn
##' @param fp
##' @param chg_cols - mutate raw cols - too specific so separate out?
##' @return
##' @author jg
##' @export
get_local_csv <- function(fn = 'merged_football-data_fbref_probs_xg.csv.gz',
    fp = "../../data/01_merged_data", chg_cols = TRUE)
{    # RDS: Load _manually_ adjusted team mapping
    file.path(here::here(), fp, fn) %>% 
    # Now read from local _csv.gz_ and NOT from rds in ESBetHorizon repo
    # i.e. we download csv.gz from private (ESBetHorizon?) repo.
    read_csv(col_types = cols(), guess_max = 1e5) ->
    ans 
    
    # Transform the raw data?
    # FIXME: strip out the transformation cos it is too specific?
    if (chg_cols) (ans %>% .transform_raw_data()) else ans
}

fread_tar <- # memoise limit_rate safely ----
memoise::memoise(
  ratelimitr::limit_rate(
    safely(
      # readr::read_csv # function (file, col_names = TRUE
      # TODO: to speed up read.
      data.table::fread # function (input = "", file = NULL,
    ),
    ratelimitr::rate(1, 1)))

.transform_raw_data <- 
  . %>% 
  # Transform the raw data
  # FIXME: move the transformations to earlier
  # assing ldn time to ldn_time col
  mutate(ldn_time = lubridate::force_tz(ldn_time, "Europe/London")) %>% 
  mutate(
    tg = score_h + score_a,
    gd = score_h - score_a,
    wdl = case_when(
      score_h >  score_a ~ 'h',
      score_h == score_a ~ 'd',
      score_h <  score_a ~ 'a',
      TRUE ~ NA_character_
    ), .after = team_a) %>% 
  mutate( # round off attendance figures and apply max/min
    home_crowd_000 = 2e4 * (Attendance %/% 2e4)/ 1e3,
    home_crowd_000 = home_crowd_000 %>% pmin(100) %>% pmax(20)) %>% 
  relocate(home_crowd_000, .after = Attendance) 