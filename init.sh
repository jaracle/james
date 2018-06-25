#!/usr/bin/expect

set timeout 20
set ip [lindex $argv 0]
set port [lindex $argv 1]
set account [lindex $argv 2]
set password [lindex $argv 3]
spawn telnet $ip $port
expect "Login*"
send "root\r"
expect "Password:*"
send "$password\r"
expect "Welcome*"
send "adduser $account $password\r"
expect "User $account added"
send "quit\r"
interact
