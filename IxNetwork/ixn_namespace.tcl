
proc ::IxNetwork::BuildDefaultNameSpace {} {
	
	variable ::IxNetwork::availableHardware_Array

	set legacyObjectTypes {Port ProtocolRange L23TrafficItem L23QuickFlowGroup L47TrafficItem}
	set validObjectTypes {PhysicalPort Topology DeviceGroup NetworkGroup ProtocolNgpf ProtocolEndpoint Interface Protocol L23FlowGroup L47AppLibraryTraffic QuickTest}
	
	::TrafficGenerator::clearObjectRecord
	
	foreach port [array names availableHardware_Array] {
		::TrafficGenerator::addToNameSpace $port $availableHardware_Array($port) PhysicalPort {} [ixNet getRoot]
	}

	set topologyPorts [::IxNetwork::BuildTopologyNameSpace]
	
	::IxNetwork::BuildPortNameSpace $topologyPorts
	
	::IxNetwork::BuildTrafficNameSpace

	::IxNetwork::BuildQuickTestsNameSpace

	::TrafficGenerator::setAllObjectTypes [concat $legacyObjectTypes $validObjectTypes]
	
	return [::TrafficGenerator::getObjects_Array]

}

#
# BuildAvailableHardware is called after start session, before loading the configuration file.
# This allows the test to get all ports and check for port status before loading the configuration.
# It can also be used by lab management type of functions that want to auto load the HW configuration.
# In this sense it is "stand alone" so it resets all structures before it starts and rebuilds them at the end.
# Just like BuildDefaultNameSpace.
# It should be called once and only once per session, after connect.
#
# BuildDefaultNameSpace resets all SW structures so we need to re-read the available hardware as part of BuildDefaultNameSpace.
# In case of multiple chassis, with dozens and hundreds of ports, this operation is time consuming.
# To save time, we save the information in another array, not cleared by BuildDefaultNameSpace, and we use it to refill name2Object_Array.
#
proc ::IxNetwork::BuildAvailableHardware {} {
	
	variable ::IxNetwork::availableHardware_Array
	
	if {[array size availableHardware_Array] > 0} {
		return
	}
	
	::TrafficGenerator::clearObjectRecord
	
	foreach chassis [ixNet getList [ixNet getRoot]/availableHardware chassis] {
		set hostname [ixNet getAttribute $chassis -hostname]
		foreach card [ixNet getList $chassis card] {
			set cardId [ixNet getAttribute $card -cardId]	
			foreach port [ixNet getList $card port] {
				set portId [ixNet getAttribute $port -portId]
				::TrafficGenerator::addToNameSpace $hostname/$cardId/$portId $port PhysicalPort {} [ixNet getRoot]
				set availableHardware_Array($hostname/$cardId/$portId) $port
			}
		}	
	}

	::TrafficGenerator::setAllObjectTypes
	return [::TrafficGenerator::getObjects_Array]
	
}

proc ::IxNetwork::BuildTopologyNameSpace {} {
	
	# Verify that the IxNetwork version supports topology (version 7.0 and up).
	if {[lsearch -glob [::IxNetwork::GetChildListClean [ixNet getRoot]] *topology*] < 0} {
		return {}
	}
	
	set topologyPorts {}
	foreach topology [ixNet getList [ixNet getRoot] topology] {
		set name [ixNet getAttribute $topology -name]
		::TrafficGenerator::addToNameSpace $name $topology Topology {} [ixNet getRoot]
		set topologyPorts [concat $topologyPorts [ixNet getAttribute $topology -vports]]
		foreach deviceGroup [ixNet getList $topology deviceGroup] {
			set name [ixNet getAttribute $deviceGroup -name]
			::TrafficGenerator::addToNameSpace $name $deviceGroup DeviceGroup {} $topology
			::IxNetwork::BuildDeviceGroupNameSpace $deviceGroup
		}	
	}
	return [lsort -unique $topologyPorts]

}

proc ::IxNetwork::BuildDeviceGroupNameSpace {parent} {

	foreach child [join [::IxNetwork::GetChildListClean $parent]] {
		set name [ixNet getAttr $child -name]
		if {$name != "::ixNet::OK"} {
			set type [lindex [split [file tail $child] :] 0]
			switch -exact -- $type {
				deviceGroup {
					::TrafficGenerator::addToNameSpace $name $child DeviceGroup {} $parent
				}
				networkGroup {
					::TrafficGenerator::addToNameSpace $name $child NetworkGroup {} $parent
				}
				default {
					if {[ixNet getAttr $child -sessionStatus] != "::ixNet::OK"} {
						::TrafficGenerator::addToNameSpace $name $child ProtocolNgpf $type {} $parent
					}
				}
			}
		}
		::IxNetwork::BuildDeviceGroupNameSpace $child
	}

}

proc ::IxNetwork::BuildPortNameSpace {topologyPorts} {

	foreach vPort [ixNet getList [ixNet getRoot] vport] {
		
		set portName [ixNet getAttribute $vPort -name]
		::TrafficGenerator::addToNameSpace $portName $vPort Port {} [ixNet getRoot]
		
		foreach ethernet [ixNet getList $vPort/protocolStack ethernet] {
			
			set ethernetChildLists [GetChilds [ixNet help $ethernet]]
			foreach ethernetEndpointChildLists [lsearch -all -inline $ethernetChildLists *Endpoint*] {
				foreach endpoint [ixNet getList $ethernet [lindex $ethernetEndpointChildLists 0]] {

					# Save endpoint object, to be used by Start/Stop ProtocolType
					set name [ixNet getAttribute $endpoint -name]
					::TrafficGenerator::addToNameSpace $name $endpoint ProtocolEndpoint [lindex [regexp -inline -- {.*/(.*)Endpoint.*} $endpoint] 1]
					
					set endpointChildLists [GetChilds [ixNet help $endpoint]]
					foreach endpointRangeChildLists [lsearch -all -inline -regexp $endpointChildLists \\srange*] {
						foreach range [ixNet getList $endpoint [lindex $endpointRangeChildLists 0]] {
							set rangeChildLists [GetChilds [ixNet help $range]]
							foreach rangeHeaderChildLists [lsearch -all -inline $rangeChildLists *Range*] {
								foreach headerRange [ixNet getList $range [lindex $rangeHeaderChildLists 0]] {
									
									set name [ixNet getAttribute $headerRange -name]
									::TrafficGenerator::addToNameSpace $name $headerRange ProtocolRange [string map {Range {}} [file tail $headerRange]]
								
								}
							}
						}
					}
				}
			}
			
		}

		# For static MACs
		foreach ethernetEndpoint [ixNet getList $vPort/protocolStack ethernetEndpoint] {
			
			set name [ixNet getAttribute $ethernetEndpoint -name]
			# Used to be EthernetEndpoint
			::TrafficGenerator::addToNameSpace $name $ethernetEndpoint ProtocolEndpoint mac
			
			set ethernetEndpointChildLists [GetChilds [ixNet help $ethernetEndpoint]]
			foreach range [ixNet getList $ethernetEndpoint range] {
				set rangeChildLists [GetChilds [ixNet help $range]]
				foreach rangeHeaderChildLists [lsearch -all -inline $rangeChildLists *Range*] {
					foreach headerRange [ixNet getList $range [lindex $rangeHeaderChildLists 0]] {
						set name [ixNet getAttribute $headerRange -name]
						::TrafficGenerator::addToNameSpace $name $headerRange ProtocolRange [string map {Range {}} [file tail $headerRange]]
					}
				}
			}
			
		}
		
		foreach interface [ixNet getList $vPort interface] {
			
			set name [ixNet getAttribute $interface -description]
			::TrafficGenerator::addToNameSpace $name $interface Interface {} $vPort
		
		}
		
		# If the port has a topology, it has no classical protocols.
		# However, instead of empty lists, IxNetwork returns error, so we test before read. 
		if {[lsearch $topologyPorts $vPort] >= 0} {
			continue
		}
		
		foreach protocol [GetChildListClean $vPort/protocols] {
			if {![regexp arp|ping|static $protocol] && [ixNet getAttribute $protocol -enabled]} {
				set name "[file tail $protocol] $portName"
				::TrafficGenerator::addToNameSpace $name $protocol Protocol [file tail $protocol] $vPort/protocols
			}
		}
	}

}

#
# TBD: Consider creating two new types - L23Traffic and L47Traffic and make all current types subtypes of these two types.
# For backward compatibility we will need to change GetObjectsBype (and maybe other procs) so it will accept these subtype as types.  
#
proc ::IxNetwork::BuildTrafficNameSpace {} {

	foreach trafficItem [ixNet getList [ixNet getRoot]/traffic trafficItem] {
		set name [ixNet getAttribute $trafficItem -name]
		set type [ixNet getAttribute $trafficItem -trafficItemType]
		switch -exact -- $type {
			l2L3 {
				::TrafficGenerator::addToNameSpace $name $trafficItem L23TrafficItem {} [ixNet getRoot]
				foreach highLevelStream [ixNet getList $trafficItem highLevelStream] {	
					set name [ixNet getAttribute $highLevelStream -name]
					::TrafficGenerator::addToNameSpace $name $highLevelStream L23FlowGroup {} $trafficItem
				}
			}
			quick {
				foreach highLevelStream [ixNet getList $trafficItem highLevelStream] {	
					set name [ixNet getAttribute $highLevelStream -name]
					::TrafficGenerator::addToNameSpace $name $highLevelStream L23QuickFlowGroup {} $trafficItem
				}
			}
			application {
				::TrafficGenerator::addToNameSpace $name $trafficItem L47TrafficItem {} [ixNet getRoot]/traffic
			}
			applicationLibrary {
				::TrafficGenerator::addToNameSpace $name $trafficItem L47AppLibraryTraffic {} [ixNet getRoot]/traffic								
			}
			default {
				# If Ixia adds new type, we simply ignore it
			}
		}
	}

}

proc ::IxNetwork::BuildQuickTestsNameSpace {} {

	set quickTests [ixNet getRoot]/quickTest

	foreach subtype [::IxNetwork::GetChildList $quickTests] {
		if {$subtype != "globals"} {
			foreach quickTest [ixNet getList $quickTests [lindex $subtype 0]] {
				set name [ixNet getAttribute $quickTest -name]
				::TrafficGenerator::addToNameSpace $name $quickTest QuickTest [string toupper [lindex $subtype 0] 0 1] {} $quickTests
			}
		}
	}
	
}

# Retrieves the list of all child types of a given object.
proc ::IxNetwork::GetChildList {object} {
		
	if {$object == {}} {
		return {}
	}
	set childList {}
	foreach child [GetChilds [ixNet help $object]] {
		lappend childList [lindex $child 0]
	}
	return $childList

}
	
proc ::IxNetwork::GetChildListClean {object} {
	set childListClean {}
	foreach child [GetChildList $object] {
		lappend childListClean [ixNet getList $object $child]
	}
	return [struct::list flatten $childListClean]
}

proc ::IxNetwork::GetHelp {object} {
	if {[catch {ixNet exists $object} exists] > 0} {
		error "TSTclError - object '$object' does not exist"
	}
	if {$object != [ixNet getRoot] && !$exists} {
		error "TSTclError - object '$object' does not exist"			
	}
	set help [ixNet help $object]
	# Search for all lists between "Child Lists:" and "Attributes:"
	set childLists [GetChilds $help]
	set childsL {}
	set childsS {}
	foreach childList $childLists {
		set childs [ixNet getList $object [lindex $childList 0]]
		foreach child $childs {
			lappend childsL [lindex $childList 0]\t$child\n
		}
		set childsS [join $childsL ""]
	}
	# Search for all lists between "Child Lists:" and "Execs:"
	set attributes [GetAttributes $help]
	set attributesL {}
	foreach attribute [split [string trim $attributes] "\n\r"] {
		lappend attributesL [string trim $attribute]\t[ixNet getAttribute $object [lindex $attribute 0]]\n
	}
	set attributesS [join $attributesL ""]
	# Search for all lists between "Child Lists:" and end of the output.        
	set execs [string trim [GetExecs $help]]
	set execsL {}
	foreach exec [string trim $execs] {
		lappend execsL [string trim $exec]\n
	}
	set execsS [join $execsL ""]
	return "${childsS}List\n${attributesS}List\n${execsS}List"
}

proc ::IxNetwork::GetExecs {help} {
	return [lindex [regexp -inline -expanded -- {\mExecs:(.*)} $help] 1]
}

proc ::IxNetwork::GetAttribueHelp {object attribute} {
	set details {}
	foreach line [lrange [split [ixNet help $object -$attribute] \n] 1 end] {
		set key [lindex [regexp -inline {(.*):} [lindex [string trim $line] 0]] 1]
		set value [lrange [string trim $line] 1 end]
		append details $key\t$value\n
	}
	return [string trim $details]
}

proc ::IxNetwork::GetNodeChildren {object} {
	foreach child [::IxNetwork::GetChildListClean $object] {
		::TrafficGenerator::addToNameSpace $child $child NA {} $object
	}
}
