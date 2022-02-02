#####################################################
# redis class
#####################################################

class redis {

  $redis_data_dir = "/data/redis"

  #####################################################
  # refresh ld cache
  #####################################################

  if ! defined(Exec['ldconfig']) {
    exec { 'ldconfig':
      command     => '/sbin/ldconfig',
      refreshonly => true,
    }
  }
  

  #####################################################
  # install packages
  #####################################################

  package {
    'tuned': ensure => present;
  }


  #####################################################
  # disable transparent hugepages for redis
  #####################################################

  file { "/etc/tuned":
    ensure  => directory,
    mode    => "0755",
    require => Package["tuned"],
  }


  file { "/etc/tuned/no-thp":
    ensure  => directory,
    mode    => "0755",
    require => File["/etc/tuned"],
  }


  file { "/etc/tuned/no-thp/tuned.conf":
    ensure  => present,
    content => template('redis/tuned.conf'),
    mode    => "0644",
    require => File["/etc/tuned/no-thp"],
  }

  
  exec { "no-thp":
    unless  => "grep -q -e '^no-thp$' /etc/tuned/active_profile",
    path    => ["/sbin", "/bin", "/usr/bin"],
    command => "tuned-adm profile no-thp",
    require => File["/etc/tuned/no-thp/tuned.conf"],
  }


  #####################################################
  # install redis
  #####################################################

  package { "redis":
    ensure   => present,
    notify   => Exec['ldconfig'],
    require => Exec["no-thp"],
  }


  file { "/usr/local/etc/redis.conf":
    ensure  => present,
    content => template('redis/redis.conf'),
    mode    => "0644",
    require => Package["redis"],
  }

  
  #####################################################
  # create data area
  #####################################################

  file { "/data":
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => "0755",
    require => Package["redis"],
  }


  file { "$redis_data_dir":
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => "0755",
    require => File["/data"],
  }


}
