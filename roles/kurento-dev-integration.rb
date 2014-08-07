name "kurento-dev-integration"

description "Configuration to build kurento modules"

run_list "recipe[kurento::jenkins-base]",
		 "recipe[kurento::kurento-dev-integration]"

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
