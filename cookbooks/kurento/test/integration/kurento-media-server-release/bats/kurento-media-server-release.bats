#!/usr/bin/env bats

@test "kurento-media-server is installed" {
	run dpkg -l kurento-media-server
	[ "$status" -eq 0 ]
}

@test "kurento-module-creator is installed" {
	run dpkg -l kurento-module-creator
	[ "$status" -eq 0 ]
}