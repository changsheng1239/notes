#!/bin/bash

BRANCH=master
RELEASE_VER=1.30.0
#DBG=x

APTINSTALL="apt-get install -y --no-install-recommends"
export DEBIAN_FRONTEND=noninteractive

set -e$DBG

TMPDIR="$(mktemp -d /tmp/nextcloudpi.XXXXXX || (echo "Failed to create temp dir. Exiting" >&2 ; exit 1) )"
trap "rm -rf \"${TMPDIR}\" ; exit 0" 0 1 2 3 15

[[ ${EUID} -ne 0 ]] && {
  printf "Must be run as root. Try 'sudo $0'\n"
  exit 1
}

export PATH="/usr/local/sbin:/usr/sbin:/sbin:${PATH}"

# get install code
echo "Getting build code..."
apt-get update
$APTINSTALL --no-install-recommends -y wget ca-certificates sudo lsb-release

pushd "$TMPDIR"
# wget -qO- --content-disposition https://github.com/nextcloud/nextcloudpi/archive/"$BRANCH"/latest.tar.gz \
wget -qO- --content-disposition https://github.com/nextcloud/nextcloudpi/archive/v"$RELEASE_VER".tar.gz \
  | tar -xz \
  || exit 1
# cd - && cd "$TMPDIR"/nextcloudpi-"$BRANCH"
cd - && cd "$TMPDIR"/nextcloudpi-"$RELEASE_VER"

# install NCP
echo -e "\nInstalling NextCloudPi..."
source etc/library.sh

# check distro
check_distro etc/ncp.cfg || {
  echo "ERROR: distro not supported:";
  cat /etc/issue
  exit 1;
}

mkdir -p /usr/local/etc/ncp-config.d/
cp etc/ncp-config.d/nc-nextcloud.cfg /usr/local/etc/ncp-config.d/
cp etc/library.sh /usr/local/etc/
cp etc/ncp.cfg /usr/local/etc/

install_php
set_limits


install_app    lamp.sh # need only php installation
install_app    bin/ncp/CONFIG/nc-nextcloud.sh   
run_app_unsafe bin/ncp/CONFIG/nc-nextcloud.sh
systemctl restart mysqld # TODO this shouldn't be necessary, but somehow it's needed in Debian 9.6. Fixme
install_app    ncp.sh
run_app_unsafe bin/ncp/CONFIG/nc-init.sh
bash /usr/local/bin/ncp-provisioning.sh

popd

IFACE="$( ip r | grep "default via" | awk '{ print $5 }' | head -1 )"
IP="$( ip a show dev "$IFACE" | grep global | grep -oP '\d{1,3}(.\d{1,3}){3}' | head -1 )"

echo "Done.

First: Visit https://$IP/  https://nextcloudpi.local/ (also https://nextcloudpi.lan/ or https://nextcloudpi/ on windows and mac)
to activate your instance of NC, and save the auto generated passwords. You may review or reset them
anytime by using nc-admin and nc-passwd.
Second: Type 'sudo ncp-config' to further configure NCP, or access ncp-web on https://$IP:4443/
Note: You will have to add an exception, to bypass your browser warning when you
first load the activation and :4443 pages. You can run letsencrypt to get rid of
the warning if you have a (sub)domain available.
"

exit 0

install_php() {
  apt-get update
    $APTINSTALL apt-utils cron curl
    $APTINSTALL apache2

    $APTINSTALL -t $RELEASE php${PHPVER} php${PHPVER}-curl php${PHPVER}-gd php${PHPVER}-fpm php${PHPVER}-cli php${PHPVER}-opcache \
                            php${PHPVER}-mbstring php${PHPVER}-xml php${PHPVER}-zip php${PHPVER}-fileinfo php${PHPVER}-ldap \
                            php${PHPVER}-intl php${PHPVER}-bz2 php${PHPVER}-json

    mkdir -p /run/php
        # CONFIGURE PHP7
    ##########################################

    cat > /etc/php/${PHPVER}/mods-available/opcache.ini <<EOF
zend_extension=opcache.so
opcache.enable=1
opcache.enable_cli=1
opcache.fast_shutdown=1
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=10000
opcache.memory_consumption=128
opcache.save_comments=1
opcache.revalidate_freq=1
opcache.file_cache=/tmp;
EOF
}

install_nextcloud() {
  # During build, this step is run before ncp.sh. Avoid executing twice
  [[ -f /usr/lib/systemd/system/nc-provisioning.service ]] && return 0
  apt-get update
  $APTINSTALL lbzip2 iputils-ping jq
  $APTINSTALL -t $RELEASE php-smbclient exfat-fuse exfat-utils                  # for external storage
  $APTINSTALL -t $RELEASE php${PHPVER}-exif                                     # for gallery
  $APTINSTALL -t $RELEASE php${PHPVER}-gmp                                      # for bookmarks
  $APTINSTALL -t $RELEASE php-bcmath                                            # for LDAP
  $APTINSTALL -t imagemagick php${PHPVER}-imagick ghostscript
  $APTINSTALL -t $RELEASE php${PHPVER}-redis

  service php${PHPVER}-fpm restart
}

set_limits() {
  # Set auto memory limit to 75% of the total memory
  local TOTAL_MEM="$( free -b | sed -n 2p | awk '{ print $2 }' )"
  AUTOMEM=$(( TOTAL_MEM * 75 / 100 ))

  # MAX FILESIZE
  local CONF=/etc/php/${PHPVER}/fpm/conf.d/90-ncp.ini
  local CURRENT_FILE_SIZE="$( grep "^upload_max_filesize" "$CONF" | sed 's|.*=||' )"
  [[ "$MAXFILESIZE" == "0" ]] && MAXFILESIZE=10G

  # MAX PHP MEMORY
  local CONF=/etc/php/${PHPVER}/fpm/conf.d/90-ncp.ini
  local CURRENT_PHP_MEM="$( grep "^memory_limit" "$CONF" | sed 's|.*=||' )"
  [[ "$MEMORYLIMIT" == "0" ]] && MEMORYLIMIT=$AUTOMEM && echo "Using ${AUTOMEM}B for PHP"
  sed -i "s/^post_max_size=.*/post_max_size=$MAXFILESIZE/"             "$CONF"
  sed -i "s/^upload_max_filesize=.*/upload_max_filesize=$MAXFILESIZE/" "$CONF"
  sed -i "s/^memory_limit=.*/memory_limit=$MEMORYLIMIT/"               "$CONF"

  # MAX PHP THREADS
  local CONF=/etc/php/${PHPVER}/fpm/pool.d/www.conf
  local CURRENT_THREADS=$( grep "^pm.max_children" "$CONF" | awk '{ print $3 }' )
  [[ $PHPTHREADS -eq 0 ]] && PHPTHREADS=$(nproc)
  [[ $PHPTHREADS -lt 6 ]] && PHPTHREADS=6
  echo "Using $PHPTHREADS PHP threads"
  sed -i "s|^pm =.*|pm = static|"     pi                           "$CONF"
  sed -i "s|^pm.max_children =.*|pm.max_children = $PHPTHREADS|" "$CONF"

  # RESTART PHP
  [[ "$PHPTHREADS"  != "$CURRENT_THREADS"   ]] || \
  [[ "$MEMORYLIMIT" != "$CURRENT_PHP_MEM"   ]] || \
  [[ "$MAXFILESIZE" != "$CURRENT_FILE_SIZE" ]] && \
    bash -c "sleep 3; service php${PHPVER}-fpm restart" &>/dev/null &
}