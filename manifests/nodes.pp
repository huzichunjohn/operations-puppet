
node analytics_basenode {
	include analytics_temp

	# analytics nodes don't have access to internet.  
	# set this proxy as default for testing.
	Exec { environment => 'http_proxy=http://brewster.wikimedia.org:8080' }
}

# cassandra nodes
node /^analytics10(0[1-9]|10)/ inherits analytics_basenode {
	include analytics::datastax::apt_source
	
	# Make sure Datastax Enterprise is installed
	# with Hadoop (CFS) enabled.
	class { "dse": 
		hadoop_enabled => true,
		require        => Class["analytics::datastax::apt_source"]
	}


	$cassandra_cluster_name = "KrakenAnalytics"

	$cassandra_seeds = [
		"208.80.154.154", # an01
		"10.64.21.106",   # an06
	]

	$cassandra_data_file_directories = [
		"/var/lib/cassandra/data/f",
		"/var/lib/cassandra/data/g",
		"/var/lib/cassandra/data/h",
		"/var/lib/cassandra/data/i",
		"/var/lib/cassandra/data/j"
	]

	# configure cassandra.
	class { "dse::cassandra::server":
		cluster_name          => $cassandra_cluster_name,
		seeds                 => $cassandra_seeds,
		data_file_directories => $cassandra_data_file_directories,
	}
}

# # analytics1001 is master node (namenode & jobtracker)
# node analytics1001 inherits analytics_basenode {
# 	class { "analytics::master": require => Class["analytics_temp"] }
# }
# 
# # all other nodes are slave nodes (datanode & tasktracker)
# node /^analytics10(0[2-9]|10)/ inherits analytics_basenode {
# 	class { "analytics::slave": require => Class["analytics_temp"] }
# 
# 	# analytics nodes don't have access to internet.  
# 	# set this proxy as default for testing.
# 	Exec { environment => 'http_proxy=http://brewster.wikimedia.org:8080' }
# }