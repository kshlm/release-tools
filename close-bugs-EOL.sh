#!/bin/sh
## To generate the BUGSLIST the following command can be used ## `bugzilla query -p GlusterFS -t NEW,OPEN,ON_QA,VERIFIED,ASSIGNED,POST,MODIFIED,RELEASE_PENDING -v <VERSION>[,<VERSION>,...]`

declare BUGSLIST VERSION

if [ "x$DRY_RUN" != "x" ]; then
  DR="echo"
fi

check_for_command()
{
  env bugzilla --version >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "`bugzilla` command is missing"
    echo "Install `python-bugzilla` before running this script again"
    exit 1
  fi
}

close_bugs()
{
  COMMENT="This bug is getting closed because GlusterFS-${VERSION} has reached its end-of-life [1].

Note: This bug is being closed using a script. No verification has been performed to check if it still exists on newer releases of GlusterFS.
If this bug still exists in newer GlusterFS releases, please open a new bug against the newer release.

[1]: https://www.gluster.org/community/release-schedule/
"

	xargs -n 8 ${DR} bugzilla modify \
		--status=CLOSED \
		--close=EOL \
		--comment="${COMMENT}" ${@}
}

check_for_command

if [ $# -ne 2 ]; then
  echo "Usage: $0 <file-with-bugs-to-be-closed> <version-string-for-EOLed-release>"
  exit 1
fi

BUGSLIST=$1
VERSION=$2

cat $BUGSLIST | close_bugs
