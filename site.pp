if versioncmp($::puppetversion,'3.6.1') >= 0 {

  $allow_virtual_packages = hiera('allow_virtual_packages',false)

  Package {
    allow_virtual => $allow_virtual_packages,
  }
}

class yum {
  exec { "yum-update":
    command => "/bin/yum -y -q update"
  }
}

node 'default' {

  # define stages
  stage {
    'pre' : ;
    'post': ;
  }

  # specify stage that each class belongs to;
  # if not specified, they belong to Stage[main]
  class {
    'yum':         stage => 'pre';
  }

  # stage order
  Stage['pre'] -> Stage[main] -> Stage['post']

  # modules
  include redis

}

# set user/group in global scope so that it can be inherited
$user = 'redis'
$group = 'redis'
