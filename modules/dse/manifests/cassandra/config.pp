class dse::cassandra::config {
    group { 'cassandra':
        ensure  => present,
        require => Class['dse::packages'],
    }

    user { 'cassandra':
        ensure  => present,
        require => Group['cassandra'],
    }

	file { $commit_log_directory: 
		ensure => "directory",
		owner  => 'cassandra',
		group  => 'cassandra',
		mode   => 0755,
	}

	file { $data_file_directories: 
		ensure => "directory",
		owner  => 'cassandra',
		group  => 'cassandra',
		mode   => 0755,
	}

    File {
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Class['dse::packages'],
    }

    # file { '/etc/cassandra/cassandra-env.sh':
    #     ensure  => file,
    #     content => template("${module_name}/cassandra-env.sh.erb"),
    # }

    file { '/etc/dse/cassandra/cassandra.yaml':
        ensure  => file,
        content => template("dse/cassandra.yaml.erb"),
    }
}