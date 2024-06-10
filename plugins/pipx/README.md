## Pipx Plugin for Python

Installs [pipx](https://pipx.pypa.io) which can be used to bootstrap other system level python tools, and ensure they run in their own dedicated virtual environment. At Culture Amp this is used to install [poetry](https://python-poetry.org).

### How it works

Simply declares that `pipx` should be installed in its devbox Virtenv directory, and adds the `bin` directory under there to the system path, so that packages installed using `pipx` are available to the user (and other packages) in the devbox shell.