
if {[namespace exists TestCenter::Tree] == 1} {
	namespace delete ::Avalanche::Tree
}

namespace eval Avalanche::Tree {
	
}

proc ::Avalanche::Tree::BuildAvlView {} {
	global fileTypes
	set fileTypes {{"TestCenter Configuration" ".spf"}}
	::TrafficGenerator::Tree::BuildView
}

proc ::TrafficGenerator::Tree::OpenConfiguration {spf_file} {
	if {$spf_file != {}} {
		set project [::av::perform import system1 -file $spf_file]
		::Avalanche::BuildDefaultNameSpace $project test1
		::TrafficGenerator::Tree::OpenTree $project [av::get $project -name]
		}
}

proc ::TrafficGenerator::Tree::GetChildrenCount {object} {
	return [llength [split [::TrafficGenerator::Tree::GetChildren $object] \n]]
}

proc ::TrafficGenerator::Tree::GetChildren {parent} {
	variable ::TrafficGenerator::Tree::fullTree
	set children {}
	if {$fullTree} {
		set childrenL {}
		foreach child [::av::get $parent -children] {
			lappend childrenL [list $child [::av::get $child -name]]
		}
		foreach child [lsort -index 1 $childrenL] {
			append children [join $child \t]\n
		}
	} else {
		set children [::TrafficGenerator::Tree::GetInterestingChildren $parent]
	}
	return [string trim $children]
}

proc ::TrafficGenerator::Tree::GetInterestingChildren {parent} {
	set interestingChildren {}
	foreach child  [split [::TrafficGenerator::GetObjectChildren $parent] \n] {
		append interestingChildren [lindex [split $child \t] 1]\t[lindex [split $child \t] 0]\n
	}
	return $interestingChildren
}

proc ::TrafficGenerator::Tree::GetAttributes {object} {	
	global objectDescription
	set objectDescription [::Avalanche::GetDescriptionClass $object]
	set attributes {}
	foreach attr [split [string trim [lindex [::textutil::split::splitx [::Avalanche::GetDescription $object] ListDelimiter] 2]] \n] {
		set key [lindex [split $attr \t] 0]
		set value [lindex [split $attr \t] 1]
		lappend attributes [::TrafficGenerator::Tree::AddAttributeRecord $object $key $value]
	}
	return $attributes
}

proc ::TrafficGenerator::Tree::GetAttribute {object attribute} {
	global objectDescription
	set attributesDescription {}
	foreach line [split $objectDescription \n] {
		if {[string trim [lindex [split $line \t] 0]] == $attribute} {
			append attributesDescription Description\t[string trim [lindex [split $line \t] 1]]\n
			append attributesDescription Type\t[string trim [lindex [split $line \t] 2]]\n
			append attributesDescription Values\t[string trim [lindex [split $line \t] 3]]\n
			append attributesDescription Default\t[string trim [lindex [split $line \t] 4]]\n
			append attributesDescription ReadOnly\t[string trim [lindex [split $line \t] 5]]
		}
	}
	return $attributesDescription
}

puts "[file tail [info script]] loaded"