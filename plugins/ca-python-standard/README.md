# CA Python Devbox Plugin

* Installs [`poetry`](https://python-poetry.org) to manage package installation
* Installs `poetry-codeartifact-auth` as a poetry plugin
* Uses a pre-configured AWS role for authentication
* Installs [`pre-commit`](https://pre-commit.com) hooks, if the `pre-commit` package is present in `pyproject.toml` (or `pre-commit` is installed externally). 


## Usage

This plugin is designed to work for common cases with minimal extra configuration needed.

* Because the plugin assumes use of CodeArtifact, it will add `ca-codeartifact-default` as a package source to `pyproject.toml`. This means you may need to run `poetry lock` after the first `devbox run setup` cycle, and then run setup again.
* Sometimes the Okta authentication flow interrupts AWS authentication. In this case running the "python-install" step again should open a browser window to the expected AWS confirmation page.

If you do not want any private package setup, set your `devbox.json` to contain the following:

    "env": {
      "POETRY_CA_PRIVATE_PYTHON": "false"
    }


The main thing to know is **the package installation step doesn't run by default** (you don't want to always run in an init hook as it's expensive). The package installation can be run using the auto-created `python-install` script using

    devbox run python-install

The best place to run this is in the setup script in your app. If you don't need to do any other setup, this could be as simple as adding the following to your `devbox.json`:

    "shell": {
      "scripts": {
        "setup": "devbox run python-install"
      }
    }

But if you have other more complicated needs which you have wisely put into a standalone `setup` script, you can instead add the line there.