#!/usr/bin/env python3

import os


def who_am_i():
    return os.environ['USER']


def get_hostname():
    return os.uname().nodename


def get_slurm_job_information():
    keys = [env_var for env_var in os.environ if env_var.startswith('SLURM_JOB')]
    return [f'{key}={os.environ[key]}' for key in keys]


def main():
    print(f'Hello {who_am_i()}!')
    print(f'This snippet of code is running on "{get_hostname()}"')
    print()
    print('The following SLURM environment variables are set:')
    print('\n'.join(get_slurm_job_information()))


if __name__ == '__main__':
    main()
