class { 'docker': }
package { 'unzip': }
class { 'nginx': }
class { '::letsencrypt':
  configure_epel => true,
  email          => 'noreply@example.com',
}
letsencrypt::certonly { "${domain}":
  manage_cron          => true,
  cron_before_command  => '/sbin/service nginx stop',
  cron_success_command => '/sbin/service nginx restart',
}
# wont work on AWS Public DNS because of
# https://community.letsencrypt.org/t/policy-forbids-issuing-for-name-on-amazon-ec2-domain/12692/5
nginx::resource::server { 'owncloud.ssl-proxy':
  listen_port  => 80,
  ssl_redirect => true,
  server_name  => ["${domain}"],
  ssl_port     => 443,
  proxy        => 'http://localhost:443',
  ssl          => true,
  ssl_cert     => "/etc/letsencrypt/live/${domain}/fullchain.pem",
  ssl_key      => "/etc/letsencrypt/live/${domain}/privkey.pem",
}

class {'docker::compose':
  ensure       => present,
  install_path => '/bin',
}
docker_compose { "/opt/${project_path}/docker-compose.yml":
  ensure  => present,
}
