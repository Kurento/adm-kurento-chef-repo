#!/usr/bin/env bats

@test "kurento-media-server is installed" {
	run sudo -E -u $SUDO_USER bash -l -c '/usr/bin/kurento-media-server --version'
	[ "$status" -eq 0 ]
}