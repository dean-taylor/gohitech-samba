class samba (
  $enable_winbind             = false,
  $allow_trusted_domains      = true,	# Yes/No
  $idmap_config               = undef,	# deprecated
  $kerberos_method            = undef,	# secrets only|system keytab|dedicated keytab|secrets and keytab
  $log_file                   = $samba::params::log_file,
  $max_log_size               = 50,
  $realm                      = undef,
  $security                   = 'auto',	# ads|auto|domain|user ;auto ref. server role
  $smb_conf                   = $samba::params::smb_conf,
  $winbind_use_default_domain = undef,	# depricated
  $winbind_nss_info           = undef,  # depricated
  $winbind_refresh_tickets    = undef,  # depricated
  $winbind_offline_logon      = undef,  # depricated
  $workgroup                  = 'MYGROUP',
) inherits samba::params {
  validate_bool($enable_winbind)
  if $kerberos_method { validate_re($kerberos_method,'^secrets only|(system|dedicated|secrets and) keytab$') }
  validate_absolute_path($log_file)
  validate_integer($max_log_size)
  if $realm { validate_re($realm,'^[A-Z.]+$') }
  validate_re(upcase($security),'^ADS|AUTO|DOMAIN|USER$')
  validate_absolute_path($smb_conf)
  validate_re($workgroup,'^[A-Z]+$')

  concat { $smb_conf:
    ensure => present,
    warn   => true,
  }
  concat::fragment { "${smb_conf}.global":
    target  => $smb_conf,
    content => template('samba/smb.conf_global.erb'),
    order   => '01',
  }

  include samba::cifs-utils
  if $enable_winbind { include samba::winbind }
}

class samba::config {
  file { '/etc/samba':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/etc/samba/smb.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("samba/smb.conf.erb"),
    require => File['/etc/samba'],
  }

  file { 'share_definitions.local':
    path    => '/etc/samba/share_definitions.local',
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("samba/share_definitions.local.erb"),
    require => File['/etc/samba'],
    replace => false,
  }
}
