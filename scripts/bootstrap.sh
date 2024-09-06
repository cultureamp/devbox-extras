#!/usr/bin/env bash
logRed() {
	printf >&2 "\033[31m" # red
	echo >&2 "$@"
	printf >&2 "\033[0m" # reset
}

logRed "the bootstrap.sh install method has been deprecated."
echo ""
logRed "Please visit https://cultureamp.atlassian.net/wiki/x/IoA5xw and follow the instructions there for installing hotel."
