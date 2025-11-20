# CA Python Devbox Plugin

> [!WARNING]
> **DEPRECATED:** This plugin is deprecated and will be removed in future. 
> Please use [ca-py-proxy](https://github.com/cultureamp/ca-py-proxy) instead and remove this plugin from your config.
> Examples of using the ca-py-proxy can be found in the python templates, [python-library-tml](https://github.com/cultureamp/python-library-tmpl) and [python-fargate-tmpl](https://github.com/cultureamp/python-fargate-tmpl).

- Installs `pipx` (via `pipx` [plugin](https://github.com/cultureamp/devbox-extras/tree/main/plugins/pipx))
- Installs [`poetry`](https://python-poetry.org) to manage package installation
- Decides whether you need private python packages
  - This is determined by the presence of extra repos in `pyproject.toml`
  - It can be overridden by setting the environment variable `POETRY_CA_PRIVATE_PYTHON` to the string `false`, probably in the `env` section of your `devbox.json`)
- If you need private python packages
  - Installs `poetry-codeartifact-auth` as a poetry plugin
  - Checks that you have an appropriate environment variable set to point to an AWS role which can access CodeArtifact
- Installs [`pre-commit`](https://pre-commit.com) hooks, if the `pre-commit` package is present in `pyproject.toml` (or `pre-commit` is installed externally).
- Automatically activates virtual env in `$VENV_DIR` unless `$DEVBOX_PYTHON_AUTO_VENV` environment variable is `false`
  - Culture Amp convention is to set `VENV_DIR` to `"$PWD/.venv` in your `devbox.json` but this is only a loose convention and subject to change

## Usage

This plugin is designed to work for common cases with minimal extra configuration needed. See notes above about environment variables you may wish to set in some cases, eg `POETRY_CA_PRIVATE_PYTHON`.

The main thing to know is **the package installation step doesn't run by default** (you don't want to always run in an init hook as it's expensive). The package installation can be run using the auto-created `python-install` script using

    devbox run python-install

The best place to run this is in the setup script in your app. If you don't need to do any other setup, this could be as simple as adding the following to your `devbox.json`:

    "shell": {
      "scripts": {
        "setup": "devbox run python-install"
      }
    }

But if you have other more complicated needs which you have wisely put into a standalone `setup` script, you can instead add the line there.
