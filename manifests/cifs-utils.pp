class samba::cifs-utils inherits samba {
  package { 'cifs-utils':
    ensure => installed,
  }

  if upcase($security) == 'ADS' {
    file { 'cifs.spnego.conf':
      path    => '/etc/request-key.d/cifs.spnego.conf',
      content => template('samba/cifs.spnego.conf.erb'),
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['cifs-utils'],
    }

    file { 'cifs.dns_resolver.conf':
      path    => '/etc/request-key.d/cifs.dns_resolver.conf',
      content => template('samba/cifs.dns_resolver.conf.erb'),
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['cifs-utils'],
    }
  }

  # Bug fix
  if ($::osfamily == "RedHat") and ($::lsbmajdistrelease == 6) {
    exec { 'sed -i -e "s;^\(\s*\)\(\$prog \$OPTIONS --pid-file /var/run/autofs.pid\)$;\1keyctl session \$prog \2;" /etc/init.d/autofs':
      path    => "/usr/bin:/bin",
      onlyif  => [
        "yum list installed | grep '^autofs' >/dev/null 2>&1",
        'grep "^\s\+\$prog\s\+\$OPTIONS\s\+--pid-file\s\+/var/run/autofs.pid" /etc/init.d/autofs >/dev/null 2>&1',
      ],
      require => Package['cifs-utils'],
    }
  }
}
