source /etc/lsb-release

stdlib.info "syntax check"
stdlib.enable_apache
stdlib.enable_augeas
stdlib.enable_mysql
stdlib.enable_nginx
stdlib.enable_rabbitmq

stdlib.info "groupadd"
stdlib.groupadd --group memcache --gid 999

stdlib.info "useradd"
stdlib.useradd --user memcache --gid 999 --uid 999 --homedir /var/lib/memcached

stdlib.info "foobar"
stdlib.useradd --user foobar --system true

stdlib.info "packages"
stdlib.apt --package memcached
stdlib.apt --package cron

stdlib.info "apt-key and apt-source"
stdlib.apt_key --name rabbitmq --key 056E8E56 --remote_keyfile https://www.rabbitmq.com/rabbitmq-signing-key-public.asc
stdlib.apt_source --name rabbitmq --uri http://www.rabbitmq.com/debian/ --distribution testing --component main --include_src false

stdlib.apt_key --name percona --keyserver keys.gnupg.net --key 1C4CBDCDCD2EFD2A
stdlib.apt_source --name percona --uri http://repo.percona.com/apt --distribution $DISTRIB_CODENAME --component main --include_src true

stdlib.info "cron"
stdlib.cron --name foobar --cmd ls --minute "*/5" --hour 4

stdlib.info "directory"
stdlib.directory --name /opt/puppetlabs/agent/facts.d --parent true

stdlib.info "file"
stdlib.file --name /opt/puppetlabs/agent/facts.d/role.txt --content "role=memcache"

stdlib.info "file_line"
stdlib.file_line --name memcached.conf/memory --file /etc/memcached.conf --line "-m 128" --match "^-m"

stdlib.info "ini"
stdlib.ini --file /root/test.ini --section foobar --option foo --value bar
stdlib.ini --file /root/test.ini --section foobar --option baz --value __none__

stdlib.info "sysvinit"
stdlib.sysvinit --name memcached

stdlib.info "git"
stdlib.apt --package git
stdlib.git --name /root/.dotfiles --source https://github.com/jtopjian/dotfiles

stdlib.info "symlink"
stdlib.file --name /usr/local/bin/foo
stdlib.symlink --source /usr/local/bin/foo --destination /usr/bin/foo
