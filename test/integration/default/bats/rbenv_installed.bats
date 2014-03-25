#!/usr/bin/env bats

@test "executable rbenv command is found" {
  run test -x /usr/local/rbenv/bin/rbenv
  [ "$status" -eq 0 ]
}
