
if {[namespace exists TestCenter] == 1} {
	namespace delete TestCenter
}

namespace eval TestCenter {

    variable resultDataSet_Array
    variable statViews_Array
	
	variable project ""		
	
}
	
proc ::TestCenter::GetDescription {object} {
	if {[catch {array set attributesA [stc::get $object]}] == 0} {
		set childsL {}
		if {[lsort -dictionary [array names attributesA -children]] != {}} {
			set children $attributesA(-children)
			array unset attributesA "-children"
			foreach child [lsort -dictionary $children] {
				lappend childsL $child\n
			}			
		}
	} else {
		error "TSTclError - Invalid object reference $object"
	}
	return "ListDelimiter\n[join $childsL ""]\n[::TrafficGenerator::array2list attributesA]"
}
	
proc ::TestCenter::GetDescriptionClass {class} {
	if {[catch {set help [stc::help $class]}] == 0} {
		set attributes [lindex [::textutil::split::splitx $help {Writable Attributes:}] 1]
		set writable [string trim [lindex [::textutil::split::splitx $attributes {Read-Only Attributes:}] 0]]
		set readOnly [string trim [lindex [::textutil::split::splitx $attributes {Read-Only Attributes:}] 1]]
		set attributesList {}
		foreach section {writable readOnly} {
			set lines [split $[set $section] \n]
			set i 0
    		while {$i < [llength $lines]} {
    			set name [lindex [split [lindex $lines $i] -] 0]
    			set description [join [lrange [split [lindex $lines $i] -] 1 end]]
    			incr i
    			foreach key {Values Default Type} {
    				if {[string first ${key}: [lindex $lines $i]] >= 0} {
    					set $key [lindex [split [lindex $lines $i] :] 1]
    					incr i
    				} else {
    					set $key {}
    				}
    			}
				if {$section == "readOnly"} {
					set roStatus True 
				} else {
					set roStatus False
				}
    			append attributesList [string trim $name\t$description\t$Type\t$Values\t$Default\t$roStatus]\n
    		}
		}
	} else {
		error "TSTclError - Invalid class $class"
	}
	return [string trim $attributesList]
}
