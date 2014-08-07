name "kurento-dev-debian"

description "Configuration to build debian packages for kurento media server"

run_list "recipe[kurento::jenkins-base]",
		 "recipe[kurento::kurento-dev-debian]"

override_attributes     "ssh_keys" => {
      "jenkins" => "jenkins"
    },
    "kurento" => {
      "email" => "jenkins@kurento.org",
      "master-host" => "ci.kurento.org",
      "npm" => {
        "username" => "kurento-maintainer-team",
        "password" => "kur3nt0",
        "email" => "info@kurento.org"
      }
    }
