
if {[namespace exists IxLoad::Tree] == 1} {
	namespace delete ::IxLoad::Tree
}

namespace eval IxLoad::Tree {
	
}

proc ::IxLoad::Tree::BuildIxlView {} {
	global fileTypes
	set fileTypes {{"IxLoad Configuration" ".rxf"}}
	::TrafficGenerator::Tree::BuildView
}

proc ::TrafficGenerator::Tree::OpenConfiguration {rxf_file} {
	if {$rxf_file != {}} {
		::IxLoad connect localhost
		set testController [::IxLoad new ixTestController]
		set repository [::IxLoad new ixRepository -name $rxf_file]
		::TrafficGenerator::Tree::OpenTree $repository repository
	}
}

proc ::TrafficGenerator::Tree::GetChildrenCount {parent} {
	return [llength [split [::TrafficGenerator::Tree::GetChildren $parent] \n]]
}

proc ::TrafficGenerator::Tree::GetChildren {parent} {

	set children {}
	
	if {[regexp .+List|Options$ $parent]} {
		if {[catch {eval $parent.indexCount} indexCount] == 0} {
			for {set i 0} {$i < $indexCount} {incr i} {
				set child [eval $parent.getItem $i]
				append children $child\t[$child cget -name]\n
			}
			return [string trim $children]
		}
	}

	if {[catch {$parent getOptions} options] == 0} {
		foreach option [lsort $options] {
			set option [string range $option 1 end]
			if {[regexp .+List|Options$ $option]} {
				if {[catch {eval $parent $option.indexCount} indexCount] == 0} {
					append children "$parent $option\t$option\n"
					continue
				}
			}
			set value [$parent cget -$option]
			if {[regexp ::tp::_Obj $value]} {
				append children $value\t$option\n
			}
		}
	}

	return [string trim $children]

}

proc ::TrafficGenerator::Tree::GetAttributes {object} {
	if {[llength $object] == 2} {
		return {}
	}
		
	set attributes {}
	if {[catch {$object getOptions} options] == 0} {
		foreach option [lsort $options] {
			set name [string range $option 1 end]
			lappend attributes [::TrafficGenerator::Tree::AddAttributeRecord $object $name [$object cget -$name]]
		}
	}

	return $attributes
}

proc ::TrafficGenerator::Tree::GetNode {object} {
	# Not all objects have name
	set name {}
	if {[::struct::record exists instance ::TrafficGenerator::Tree:attribute_Record_${object}_name]} {
		set name [::TrafficGenerator::Tree:attribute_Record_${object}_name cget -value]
	}
	set reference $object
	return [list "Name $name" "Reference $reference"]
}

proc ::TrafficGenerator::Tree::GetAttribute {object attribute} {
	return {}
}

puts "[file tail [info script]] loaded"