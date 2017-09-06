class samba::params {
  $smb_conf = '/etc/samba/smb.conf'
  $log_file = '/var/log/samba/log.%m'
  $winbind_package = $::osfamily ? {
    'RedHat' => $::operatingsystemmajrelease ? {
      '7'     => 'samba-winbind',
      default => 'samba-common',
    }
  }
}
