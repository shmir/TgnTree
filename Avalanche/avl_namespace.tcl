proc ::Avalanche::BuildDefaultNameSpace {project test} {
	
	::TrafficGenerator::clearObjectRecord
		
	foreach item [av::get $project -tests] {
		set name [av::get $item -name]
		::TrafficGenerator::addToNameSpace $name $item Test {} $project
	}
		
	foreach item [av::get $project -actionlist] {
		set name ClientActions_[av::get $item -name]
		::TrafficGenerator::addToNameSpace $name $item ClientAction {} $project
	}

	foreach item [av::get $project -authentications] {
		set name ServerAuthentications_[av::get $item -name]
		::TrafficGenerator::addToNameSpace $name $item ServerAuthentication {} $project
	}
		
	foreach item [av::get $project -clientsubnets] {
		set name ClientSubnets_[av::get $item -name]
		::TrafficGenerator::addToNameSpace $name $item ClientSubnet {} $project
	}

	# The interface is not available before calling to test1,testspece1
	# The interface of client and server are listed together - interface1 to interface16. 
	# interfac1 to interface10 are client interfaces and interface11 to interface16 are server interfaces.
	
	set testSpec [av::get $test -configuration]

	foreach item [av::get [av::get $testSpec -topology] -interface] {
		set name Ports_[av::get $item -port]
		# To support offline configurations
		if {$name != "Ports_"} {
			::TrafficGenerator::addToNameSpace $name $item Port {} $test	
		}
	}

	# The associations of client and server are listed together - association1 to association13. 
	# ssocation1 to association7 are server associations and association8 to association13 are client associations

	set innerTest [av::get $testSpec -test]

	set server [av::get $innerTest -server]
	::TrafficGenerator::addToNameSpace $server $server Server {} $test

	set client [av::get $innerTest -client]
	::TrafficGenerator::addToNameSpace $client $client Client {} $test

	foreach association [av::get $server -association] {
		set name Server_association[expr [av::get $association -id] + 1]
		::TrafficGenerator::addToNameSpace $name $association Association {} $server
	}
								
	set globalAssociations [av::get [av::get $client -globalassociations] -association]
	set userAssociations [av::get [av::get $client -userbasedassociations] -association]
	foreach association [concat $globalAssociations $userAssociations] {
		set name Client_association[expr [av::get $association -id] + 1]
		::TrafficGenerator::addToNameSpace $name $association Association {} $client
	}
				
	foreach item [av::get $project -loads] {
		set name ClientLoads_[av::get $item -name]
		::TrafficGenerator::addToNameSpace $name $item ClientLoad {} $project
	}

	foreach item [av::get $project -serverprofiles] {
		set name ServerProfiles_[av::get $item -name]
		::TrafficGenerator::addToNameSpace $name $item ServerProfile {} $project
	}
		
	foreach item [av::get $project -serversubnets] {
		set name ServerSubnets_[av::get $item -name]
		::TrafficGenerator::addToNameSpace $name $item ServerSubnet {} $project
	}

	foreach item [av::get $project -transactions] {
		set name ServerTransactions_[av::get $item -name]
		::TrafficGenerator::addToNameSpace $name $item ServerTransaction {} $project
	}
		
	foreach item [av::get $project -userprofiles] {
		set name ClientProfiles_[av::get $item -name]
		::TrafficGenerator::addToNameSpace $name $item ClientProfile {} $project
	}
	
	::TrafficGenerator::setAllObjectTypes

}
