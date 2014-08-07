name "kurento-docker"

description "Builds a jenkins-base with docker"

run_list "recipe[kurento::jenkins-base]",
         "recipe[kurento::docker]"
