name "kurento-dev-integration"

description "Configuration to build kurento modules"

run_list "recipe[kurento::jenkins-base]",
		 "recipe[kurento::kurento-dev-integration]"
		 