# Ilifu user training - Advance session 1 - Tutorial 1

An introduction into Python virtual environments and using Python virtual environments as custom kernels in Jupyter.

Resources:
- [virtualenv](https://virtualenv.pypa.io/en/latest/)


## Choose a Python version

Currently, Ubuntu 20.04 is used on the compute nodes in the ilifu Slurm environment. Ubuntu 20.04 provides Python 3.8 by default. If this Python version is sufficient you do not need to load a module. If you are looking for a specific Python distribution, you can view the distributions that are available as modules using the following:

```bash
$ module avail
```

You can then load the module of the Python version that you wish to use in your virtual environment:

```bash
$ module load python/3.9.4
```

## Virtual environment creation

Allocate a job on the Devel partition:

```bash
$ sinteractive
```

Create a virtual environment at the desired path:

```bash
$ virtualenv .venv/tutenv
```

## Activating the virtual environment

In order to make use of the virtual environment and included packages as well as install new packages, the virtual environment must be activated:

```bash
$ source .venv/tutenv/bin/activate
```

The activated environment will be indicated by a change in the command line prompt:

```bash
(.tutenv) jeremy@compute-001:~$
```

By activating the virtual environment, several PATH environment variables will be updated to point to binary specific to the virtual environment, such as `pip`, for install new packages.

## Installing new packages in the virtual environment

Once the virtual environment is activated, you can install new packages using `pip`:

```bash
$ pip install scikit-learn
```

These packages will only be available within the virtual environment, that is to say, when it is activated or when the python binary specific to the virtual environment is used.

## Adding a virtual environment as a custom kernel in Jupyter

You can use your virtual environment as a custom kernel in Jupyter, allowing you to use any packages installed in the virtual environment. You must first install an `ipykernel` package required by Jupyter

```bash
$ pip install ipykernel
```

You can then create the kernel using:

```bash
$ ipython kernel install --name "tutenv_py3.9.4" --user
```

This will create the kernel directory and kernel file at `~/.local/share/jupyter/kernels/tutenv_py3.9.4/kernel.json` which will include the kernel configuration.

You can select your new virtual environment as a kernel in an existing notebook or when launching a new notebook.
