import "nodes.pp"

# this class does things that ops production
# usually does, or that we will not need
# in production when we are finished with testing.
class analytics_temp {
	# Make sure puppet runs apt-get update!
	exec { "/usr/bin/apt-get update":
		timeout => 240,
		returns => [ 0, 100 ],
	}

	package { ["curl", "dstat"]: ensure => "installed" }

	file { "/etc/profile.d/analytics.sh":
		content => 'export http_proxy="http://brewster.wikimedia.org:8080"

alias pupup="pushd .; cd /etc/puppet.analytics && sudo git pull; popd"
alias puptest="sudo puppetd --test --verbose --server analytics1001.wikimedia.org --vardir /var/lib/puppet.analytics --ssldir /var/lib/puppet.analytics/ssl --confdir=/etc/puppet.analytics"
alias pupsign="sudo puppetca --vardir /var/lib/puppet.analytics --ssldir /var/lib/puppet.analytics/ssl --confdir=/etc/puppet.analytics sign "',
		mode => 755,
	}
	 
	include declerambaul
	include olivneh
}



class declerambaul inherits baseaccount {
	$username = "declerambaul"
	$realname = "Fabian Kaelin"
	$uid = 566

	unixaccount { $realname: username => $username, uid => $uid }

	ssh_authorized_key { "declerambaul_wiki":
		ensure	=> present,
		user	=> $username,
		type	=> "ssh-rsa",
		key    	=> "AAAAB3NzaC1yc2EAAAABIwAAAQEA3aScUQs0HeQEp/pnMuJ6JKWTwEa8IPVKa7Gkrx2DJ3z1qUtA5wzxSG6m//MJBokIntwBAGuqRazAqs5cB3m4GVqViA1fabxZy55l1/GB+962/d8goVEbtkj/MO47vuUBosVSy5GGjGOs3hWtKId9q6+AU0OCNZwC3j12tXGIX3ztcf4Ef2pdBoCfJMgrvlnIpdFDBftrua9kVvYRQj6tVr5rTbFlEioNgNcdQXhvDP0sU81i1NG/nAeOZMDYOzUscDHa6JcCts3nRyqrqgaMixxGjF7WG42tqS+AEqKi9IOqFnaiHtwipZrnJJ8IxtDOve3HHA3VctBsh03qB4RZ6w==",
		require => Unixaccount[$realname],
	}
}

class olivneh inherits baseaccount {
	$username = "olivneh"
	$realname = "Ori Livneh"
	$uid = 604
	unixaccount { $realname: username => $username, uid => $uid, gid => $gid }
	ssh_authorized_key {
		"Olivneh@WMF":
			ensure	=> present,
			user	=> $username,
			type	=> "ssh-rsa",
			key	=> "AAAAB3NzaC1yc2EAAAADAQABAAABAQC5sz9Sq9+vAas4hY9HdVV0/xukFFRJj0NMDuWY4cRf/MKXkGwQB2CVEa6/owW3G1dbC3t5viimS347DoQh9SHy9ltpnrjga5sd/8RLV/7FSs2QjG+WtMwEupAfO1YRUzWEYCbs/sYJ/dYjY6hdJJfByxH8XOQHXI6hiddjqZ7XrQUq9IVYb6rm/Td7OmwD5/T2l1YXVa/w4DHqVMEnXxtSo4Njww2BwmEYPIa9HusE8TblpAs1B78ixVLCSAg7/VLXDj2mzeX75bID3To9CvxRxPbLKJpSy/yRHM8p5XJ55ZZjp+pmkdOj/kcdvqiEe2KhfdVgXS4Ywk1/R4ZGlA+9",
			require => Unixaccount[$realname],
	}
}


class baseaccount {
	$enabled = "true"

	Ssh_authorized_key {
		ensure => $enabled ? {
			"false" => 'absent',
			 default => 'present',
			}
	}
}


define account_ssh_key($user, $type, $key, $enabled="true") {
	ssh_authorized_key { $title:
		user => $user,
		type => $type,
		key => $key,
	}
}


define unixaccount($username, $uid, $gid = 500, $enabled="true") {


	if ($myshell) {
		$shell = $myshell
	} else {
		$shell = "/bin/bash"
	}

	user { "${username}":
		name		=> $username,
		uid		=> $uid,
		gid		=> $gid,
		comment		=> $title,
		shell		=> $shell,
		ensure		=> $enabled ? {
					"false" => 'absent',
					default => 'present',
				},
		managehome	=> true,
		allowdupe	=> false,
		# require		=> Group[$gid],
	}
}