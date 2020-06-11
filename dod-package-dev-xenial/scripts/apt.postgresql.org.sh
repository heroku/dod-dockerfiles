#!/bin/sh

# script to add apt.postgresql.org to sources.list

# from command line
CODENAME="$1"
# lsb_release is the best interface, but not always available
if [ -z "$CODENAME" ]; then
    CODENAME=$(lsb_release -cs 2>/dev/null)
fi
# parse os-release (unreliable, does not work on Ubuntu)
if [ -z "$CODENAME" -a -f /etc/os-release ]; then
    . /etc/os-release
    # Debian: VERSION="7.0 (wheezy)"
    # Ubuntu: VERSION="13.04, Raring Ringtail"
    CODENAME=$(echo $VERSION | sed -ne 's/.*(\(.*\)).*/\1/')
fi
# guess from sources.list
if [ -z "$CODENAME" ]; then
    CODENAME=$(grep '^deb ' /etc/apt/sources.list | head -n1 | awk '{ print $3 }')
fi
# complain if no result yet
if [ -z "$CODENAME" ]; then
    cat <<EOF
Could not determine the distribution codename. Please report this as a bug to
pgsql-pkg-debian@postgresql.org. As a workaround, you can call this script with
the proper codename as parameter, e.g. "$0 squeeze".
EOF
    exit 1
fi

# errors are non-fatal above
set -e

cat <<EOF
This script will enable the PostgreSQL APT repository on apt.postgresql.org on
your system. The distribution codename used will be $CODENAME-pgdg.

EOF

case $CODENAME in
    # known distributions
    sid|jessie|wheezy|squeeze|lenny|etch) ;;
    precise|lucid) ;;
    *) # unknown distribution, verify on the web
	DISTURL="https://apt.postgresql.org/pub/repos/apt/dists/"
	if [ -x /usr/bin/curl ]; then
	    DISTHTML=$(curl -s $DISTURL)
	elif [ -x /usr/bin/wget ]; then
	    DISTHTML=$(wget --quiet -O - $DISTURL)
	fi
	if [ "$DISTHTML" ]; then
	    if ! echo "$DISTHTML" | grep -q "$CODENAME-pgdg"; then
		cat <<EOF
Your system is using the distribution codename $CODENAME, but $CODENAME-pgdg
does not seem to be a valid distribution on
$DISTURL

We abort the installation here. If you want to use a distribution different
from your system, you can call this script with an explicit codename, e.g.
"$0 precise".

Specifically, if you are using a non-LTS Ubuntu release, refer to
https://wiki.postgresql.org/wiki/Apt/FAQ#I_am_using_a_non-LTS_release_of_Ubuntu

For more information, refer to https://wiki.postgresql.org/wiki/Apt
or ask on the mailing list for assistance: pgsql-pkg-debian@postgresql.org
EOF
		exit 1
	    fi
	fi
	;;
esac

echo "Writing /etc/apt/sources.list.d/pgdg.list ..."
cat > /etc/apt/sources.list.d/pgdg.list <<EOF
deb http://apt.postgresql.org/pub/repos/apt/ $CODENAME-pgdg main
deb-src http://apt.postgresql.org/pub/repos/apt/ $CODENAME-pgdg main
EOF

echo "Importing repository signing key ..."
KEYRING="/etc/apt/trusted.gpg.d/apt.postgresql.org.gpg"
test -e $KEYRING || touch $KEYRING
test -e $KEYRING || touch $KEYRING
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key --keyring $KEYRING add -

echo "Running apt-get update ..."
apt-get update

cat <<EOF

You can now start installing packages from apt.postgresql.org.

Have a look at https://wiki.postgresql.org/wiki/Apt for more information;
most notably the FAQ at https://wiki.postgresql.org/wiki/Apt/FAQ
EOF
