#!/usr/bin/env bats

@test "kurento-media-server is installed" {
	run dpkg -l kurento-media-server-6.0
	[ "$status" -eq 0 ]
}

@test "kurento-module-creator is installed" {
	run dpkg -l kurento-module-creator-4.0
	[ "$status" -eq 0 ]
}