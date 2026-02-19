#!/usr/bin/env python3
import os
from sys import stderr

def get_slurm_job_information():
    keys = [env_var for env_var in os.environ if env_var.startswith('SLURM_JOB')]
    return [f'{key}={os.environ[key]}' for key in keys]


def main():
    the_host = os.uname().nodename
    the_user = os.environ['USER']
    print(f'Hello {the_user}!')
    print(f'This snippet of code is running on "{the_host}"\n')

    slurm_information = get_slurm_job_information()
    if slurm_information:
        print('The following SLURM environment variables are set:')
        print('\n'.join(slurm_information))
    else:
        print(f'As far as I can tell, this is not a slurm job.')

    stderr.write(f'Here is something written to stderr from node "{the_host}" for user "{the_user}".\n')


if __name__ == '__main__':
    main()
