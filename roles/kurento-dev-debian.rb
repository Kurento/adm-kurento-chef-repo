name "kurento-dev-debian"

description "Configuration to build debian packages for kurento media server"

run_list "recipe[kurento::jenkins-base]",
		 "recipe[kurento::kurento-dev-debian]"
