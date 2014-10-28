name "dev-tutorial"

description "Configuration to install & test kurento tutorials"

run_list "recipe[kurento::kurento-dev-tutorial]"

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
