#!/usr/bin/env bats

@test "npm user is valid" {
	run sudo -H npm whoami
	[ "$output" = "kurento-maintainer-team" ]
}