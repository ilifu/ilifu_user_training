who_am_i <- function() {
  Sys.getenv("USER")
}

get_hostname <- function() {
  Sys.getenv("HOSTNAME")
}

get_slurmjob_information <- function() {
  all_info <- Sys.getenv()
  all_info[grep("SLURM_JOB", names(all_info))]
}


i_am <- who_am_i()
the_host <- get_hostname()
slurm_info <- get_slurmjob_information()

print(paste("Hello", i_am))
print(paste("I am running on", the_host))
print(paste("Slurm Job environment variables:", slurm_info))
