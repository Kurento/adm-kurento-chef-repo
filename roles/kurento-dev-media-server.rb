name "kurento-dev-media-server"

description "Configuration to build kurento media server"

run_list "recipe[kurento::jenkins-base]",
		 "recipe[kurento::kurento-dev-media-server]"

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

