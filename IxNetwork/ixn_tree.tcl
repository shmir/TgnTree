#
# Sometimes IxNetwork native API throws error for perfectly valid objects and attributes requests.
# Those errors are seen in IxNetwork debug tools so it is quite obvious that these are API bugs.
#
# The driver logic code knows exactly which objects and attribute it is dealing with so there is logic to work around the API errors.
# The tree code handles 'abstract' objects and attributes, without knowing the exact object or attribute types so the only way to work
# around the bugs is by catch and ignore.
# Still, catch is used only when necessary.
#

if {[namespace exists IxNetwork::Tree] == 1} {
	namespace delete ::IxNetwork::Tree
}

namespace eval IxNetwork::Tree {
	
}

proc ::IxNetwork::Tree::BuildIxnView {} {
	global fileTypes
	set fileTypes {{"IxNetwork Configuration" ".ixncfg"}}
	::TrafficGenerator::Tree::BuildView
	.main_P.mbar.file_M insert 2 command -label "Connect to configuration" -underline 0 -command {::TrafficGenerator::Tree::ConnectConfiguration}
	.main_P.mbar.file_M insert 2 separator
}

namespace eval IxNetwork {
	variable staticTree_Array
}

proc ::IxNetwork::obj2StaticObj {object} {
	return ::ixNet::OBJ-/[regsub {:.*} [regsub -all {:[^\/]*/} $object /] {}]
}

proc ::IxNetwork::ReadStaticTreeFile {fileName} {
	variable ::IxNetwork::staticTree_Array
	set f [open [file join [file dirname [info script]] $fileName]]
	foreach line [split [read $f] \n] {
		set staticTree_Array([lindex [split $line \t] 0]) [lindex [split $line \t] 1]
	}
	close $f
}

proc ::TrafficGenerator::Tree::OpenConfiguration {ixncfg_file} {
	if {$ixncfg_file != {}} {
		ixNet exec newConfig
		ixNet commit		
		ixNet exec loadConfig [ixNet readFrom $ixncfg_file]
		ixNet commit
		::TrafficGenerator::Tree::ConnectConfiguration
	}
}

proc ::TrafficGenerator::Tree::ConnectConfiguration {} {
	set root [ixNet getRoot]
	::IxNetwork::BuildAvailableHardware
	::IxNetwork::BuildDefaultNameSpace
	::TrafficGenerator::Tree::OpenTree $root root
}

proc ::TrafficGenerator::Tree::GetChildrenCount {object} {
	variable ::TrafficGenerator::Tree::fullTree
	variable ::IxNetwork::staticTree_Array
	if {$fullTree} {
		# If full tree, try to read static tree first.
		set staticObj [::IxNetwork::obj2StaticObj $object]
		if {[info exists staticTree_Array($staticObj)]} {
			return [llength $staticTree_Array($staticObj)]
		}
	}
	# If only interesting tree OR if object not found in static tree (version mismatch or bug or whatever).
	return [llength [split [::TrafficGenerator::Tree::GetChildren $object] \n]]
}

proc ::TrafficGenerator::Tree::GetChildren {parent} {
	variable ::TrafficGenerator::Tree::fullTree
	if {$fullTree} {
		if {[catch {::IxNetwork::GetChildListClean $parent} children] > 0} {
			set children {}
		}
	} else {
		set children [::TrafficGenerator::Tree::GetInterestingChildren $parent]
	}
	# We want short yet distinctive and descriptive text to show in the tree so we remove the parent name from the ID.
	set idTextChildren {}
	foreach child [lsort $children] {
		# There are object references with spaces so we build a LINE\TAB separated list.
		append idTextChildren $child\t[string map "$parent/ {} $parent {}" $child]\n
	}
	return [string trim $idTextChildren]
}

proc ::TrafficGenerator::Tree::GetInterestingChildren {parent} {
	set children [::TrafficGenerator::GetObjectChildren $parent]
	if {$children == {}} {
		::IxNetwork::GetNodeChildren $parent
		set children [::TrafficGenerator::GetObjectChildren $parent]
	}
	set interestingChildren {}
	foreach child  [split $children \n] {
		lappend interestingChildren [lindex [split $child \t] 1]
	}
	return $interestingChildren
}

proc ::TrafficGenerator::Tree::GetAttributes {object} {
	set attributes {}
	if {[catch {ixNet help $object} help] > 0} {
		set help {}
	}
	foreach attribute [split [::IxNetwork::GetAttributes $help] \n] {
		set name [string range [lindex $attribute 0] 1 end]
		set readOnlyAndType [lrange $attribute 1 end]
		if {[catch {ixNet getAttr $object -$name} value] > 0} {
			set value {}
		}
		lappend attributes [::TrafficGenerator::Tree::AddAttributeRecord $object $name $value]
	}
	return $attributes
}

proc ::TrafficGenerator::Tree::GetAttribute {object attribute} {
	return [::IxNetwork::GetAttribueHelp $object $attribute]
}

puts "[file tail [info script]] loaded"