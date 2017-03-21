#
#	Important notes when building or debugging:
#
#	1.	av::apply test1 0 1 might fail becasue there is no license.
#		it is possible to see it when working in wish/avalanche commander
#		it is possible to run in trial mode (a test that is shorter than 100 seconds)
#	2.	In the ports matrix, the server ports must come before clinet ports
#		for example Ports = ['Server_association1', '192.168.42.202/1/4'; 'Clientassociation1', '192.168.42.202/1/2'; ]
#	3.	After each run, a new object of project is created. The user must clear these objects manually.
#		TODO: create 'clear_history' function in TCL?
#	4.	If there are runtime errors try 'av::get runningtestinfo1 -testerror'
#	5.	sapee / skype tests are not supported in the current release.
#	6.	TODO: License management 

if {[namespace exists Avalanche] == 1} {
	namespace delete Avalanche
}

namespace eval Avalanche {
	variable resultDataObjects_Array
}

proc ::Avalanche::GetDescription {objRef} {
	array set attributes_Array [av::get $objRef]
	set children {}
	set attributes {}
	foreach attribute [array names attributes_Array] {
		# Some of the values are file path. Avalanche returns these values with backslash notation and while evaluating
		# [lindex $attributes_Array($attribute) 0] the backslash are evaluated as control character and the ::av::nodeExists will return 'Malformed Parameter:' error.
		# I.e. c:/temp/results will be evaluated as c{Tab}emp{CarriageReturn}esults
		# To avoid this we add {} around the returned value of the lindex command.
		if {$attribute == {-handle}} {
			continue
		} elseif {$attribute != {-parent} && $attributes_Array($attribute) != {} && [::av::nodeExists \{[lindex $attributes_Array($attribute) 0]\}]} {
			lappend children {*}$attributes_Array($attribute)
		} else {
			append attributes [string range $attribute 1 end]\t$attributes_Array($attribute)\n 
		}
	}
	return ListDelimiter\n[join [lsort $children] \n]\nListDelimiter\n$attributes
}

proc ::Avalanche::GetDescriptionClass {class} {
	if {[catch {set help [av::help $class]}] == 0} {
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
