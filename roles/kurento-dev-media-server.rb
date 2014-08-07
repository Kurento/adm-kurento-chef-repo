name "kurento-dev-media-server"

description "Configuration to build kurento media server"

run_list "recipe[kurento::jenkins-base]",
		 "recipe[kurento::kurento-dev-media-server]"
