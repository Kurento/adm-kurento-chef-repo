#!/usr/bin/env bats

@test "ffmpeg is correctly installed" {
	run sudo -u jenkins -H ffmpeg -version
	[ "$status" -eq 0 ]
}