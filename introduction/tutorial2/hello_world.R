who_am_i <- function() {
  Sys.getenv("USER")
}


i_am <- who_am_i()

print(paste("Hello", i_am))
