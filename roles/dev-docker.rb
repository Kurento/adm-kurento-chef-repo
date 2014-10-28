name "dev-docker"

description "Builds a jenkins-base with docker"

run_list "recipe[kurento::kurento-dev-docker]"

override_attributes "java" => {
      "install_flavor" => "openjdk",
      "jdk_version" => "7"
    },
    "maven" => {
      "setup_bin" => "true"
    },
    "ssh_keys" => {
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
