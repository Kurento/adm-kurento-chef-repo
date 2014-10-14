#!/usr/bin/env bats

@test "kitchen is installed and functional" {
	run which kitchen
	[ "$status" -eq 0 ]
}