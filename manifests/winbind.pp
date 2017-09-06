define samba::winbind::idmap_config (
  $domain      = $name,	# <WORKGROUP>|*
  $backend     = undef,	# tdb|tdb2|ldap|rid|hash|autorid|ad|nss
  $default     = false,
  $range,
  $read_only   = false,
  $schema_mode = undef,
) {
  validate_re($domain,'^[A-Z]+|\*$')
  if $backend { validate_re($backend,'^tdb|tdb2|ldap|rid|hash|autorid|ad|nss$') }
  if $default { validate_bool($default) }
  validate_re($range,'^\d+-\d+$')
  if $schema_mode { validate_string($schema_mode) }	# requires review

  include samba::winbind

  concat::fragment { "smb.conf_global_idmap_config_${domain}":
    target  => '/etc/samba/smb.conf',
    content => template('samba/smb.conf/global_idmap_config.erb'),
    order   => '03',
  }
}

class samba::winbind (
  $idmap_configs      = {},
  $nss_info           = 'template',	# template|sfu|sfu20|rfc2307
  $offline_logon      = false,
  $refresh_tickets    = false,
  $template_homedir   = '/home/%D/%U',
  $template_shell     = '/bin/false',
  $use_default_domain = false,
  $winbind_package    = $samba::params::winbind_package,
) inherits samba::params {
  validate_hash($idmap_configs)
  validate_bool($use_default_domain,$refresh_tickets,$offline_logon)
  validate_re($nss_info,'^template|sfu|sfu20|rfc2307$')
  validate_string($winbind_package)

  include samba

  package { $winbind_package:
    ensure => present,
  }

  service { 'winbind':
    ensure => running,
    enable => true,
    hasrestart => true,
    hasstatus => true,
    subscribe => Concat[$samba::params::smb_conf],
  }

  concat::fragment { "${samba::params::smb_conf}_global_winbind":
    target  => $samba::params::smb_conf,
    content => template('samba/smb.conf/global_winbind.erb'),
    order => '02',
  }

  if $idmap_configs { create_resources(samba::winbind::idmap_config,$idmap_configs) }
}
