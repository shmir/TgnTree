
package require tablelist

if {[namespace exists TrafficGenerator::Tree] == 1} {
	namespace delete TrafficGenerator::Tree
}

namespace eval TrafficGenerator::Tree {
	::struct::record define ::TrafficGenerator::Tree::attribute_Record {name value type readOnly description}
	variable fullTree 1
}

proc ::TrafficGenerator::Tree::OpenTree {id text} {
	::TrafficGenerator::Tree::InsertRoot $id $text
	::TrafficGenerator::Tree::InsertChildren $id [::TrafficGenerator::Tree::GetChildren $id]
}

proc ::TrafficGenerator::Tree::GetNode {object} {
	set name N/A
	if {[::struct::record exists instance ::TrafficGenerator::Tree:attribute_Record-${object}-name]} {
		set name [::TrafficGenerator::Tree:attribute_Record-${object}-name cget -value]
	} elseif {[::struct::record exists instance ::TrafficGenerator::Tree:attribute_Record-${object}-Name]} {
		set name [::TrafficGenerator::Tree:attribute_Record-${object}-Name cget -value]
	}
	set reference $object
	return [list [list Name $name] [list Reference $reference]]
}

proc ::TrafficGenerator::Tree::AddAttributeRecord {object name value {type {}} {readOnly {}} {description {}}} {
	set recondId ::TrafficGenerator::Tree:attribute_Record-$object-$name
	if {![::struct::record exists instance [string map {\\ \\\\} $recondId]]} {
		::TrafficGenerator::Tree::attribute_Record $recondId
	}
	$recondId config -name $name -value $value -type $type -readOnly $readOnly -description $description
	return $recondId
}

puts "[file tail [info script]] loaded"