#!/usr/bin/env python3
import os
from sys import stderr

def who_am_i():
    return os.environ['USER']


def get_hostname():
    return os.uname().nodename


def get_slurm_job_information():
    keys = [env_var for env_var in os.environ if env_var.startswith('SLURM_JOB')]
    return [f'{key}={os.environ[key]}' for key in keys]


def main():
    the_host = get_hostname()
    the_user = who_am_i()
    print(f'Hello {the_user}!')
    print(f'This snippet of code is running on "{the_host}"')
    print()
    slurm_information = get_slurm_job_information()
    if slurm_information:
        print('The following SLURM environment variables are set:')
        print('\n'.join(get_slurm_job_information()))
    else:
        print(f'As far as I can tell, this is not a slurm job.')

    stderr.write(f'Here is something written to stderr from node "{the_host}" for user "{the_user}".\n')


if __name__ == '__main__':
    main()
