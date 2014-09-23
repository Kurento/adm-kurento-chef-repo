#!/usr/bin/env bats

@test "npm user is valid" {
	run sudo -u jenkins -H npm whoami
	[ "$output" = "kurento-maintainer-team-test" ]
}

@test "bower is installed and functional" {
	run bower --version
	[ "$status" -eq 0 ]
}