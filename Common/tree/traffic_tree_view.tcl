# E - Entry
# F - Frame
# L - Label
# M - Menu
# P - Pane
# S - Scroll bar
# T - Tree or Table

#
# Sometimes we use tile (ttk) and sometimes standard widgets, depends on what's quicker to learn and implement.
# TODO: use only tile widgets with proper style.
#

set versionMessage "Traffic Generator Tree 0.9.1\n\nTerra Software Ltd. All rights reverved."

set currentConfiguration {}

namespace eval TrafficGenerator::Tree {

	global commonDir

	variable inProc 0
	variable attributesTableKeys {Name Value Type ReadOnly Description}

	variable bgColor white

	wm title . "Traffic Objects Tree"

	image create photo applicationIcon -file [file join $commonDir tree IgnisIcon.png]
	image create photo classIcon -file [file join $commonDir tree Class16.png]

	wm iconphoto . -default applicationIcon

}

proc ::TrafficGenerator::Tree::ClearTree {} {
	global curObjRef
	set curObjRef {}
	destroy .main_P
	foreach instance [::struct::record show instance ::TrafficGenerator::attribute_Record] {
		::struct::record delete instance $instance
	}
}

proc ::TrafficGenerator::Tree::BuildView {} {

	global curObjRef

	variable ::TrafficGenerator::Tree::bgColor

	::TrafficGenerator::Tree::ClearTree

	# Main paned window for the application.
	::ttk::panedwindow .main_P -orient horizontal
	pack .main_P -side top -fill both -expand 1

	# Menu bar.
	addMenuBar

	# Objects tree
	addObjectsTree

	#
	# Selected object attributes frame - label, entry and paned window.
	#

	frame .main_P.data_F -bd 2 -relief ridge
	.main_P add .main_P.data_F

	label .main_P.data_F.objRef_L -relief ridge -text "Object reference"
	entry .main_P.data_F.objRef_E -textvariable curObjRef -state readonly -readonlybackground $bgColor
	::ttk::panedwindow .main_P.data_F.data_P -orient vertical

	grid .main_P.data_F.objRef_L .main_P.data_F.objRef_E -sticky nsew
	grid .main_P.data_F.data_P -sticky nsew -columnspan 2
	grid columnconfigure .main_P.data_F 1 -weight 1
	grid rowconfigure .main_P.data_F 1 -weight 1

	#
	# Attributes table - frame with table and x/y scrollbars.
	#

	# Frame.
	frame .main_P.data_F.data_P.attributes_F -relief ridge
	.main_P.data_F.data_P add .main_P.data_F.data_P.attributes_F

	# Table
	tablelist::tablelist .main_P.data_F.data_P.attributes_F.attributes_T -columntitles "Name Value" -stretch all -background $bgColor -labelcommand tablelist::sortByColumn

	# Menue
	menu .main_P.data_F.data_P.attributes_F.copy_M -tearoff 0
	.main_P.data_F.data_P.attributes_F.copy_M add command -label "Copy Attribute name" -command {::TrafficGenerator::Tree::CopyAttrToClipboard $curAttrName}
	.main_P.data_F.data_P.attributes_F.copy_M add command -label "Copy Attribute value" -command {::TrafficGenerator::Tree::CopyAttrToClipboard $curAttrValue}

	# Scroll bars.
	ttk::scrollbar .main_P.data_F.data_P.attributes_F.x_S -orient horizontal -command ".main_P.data_F.data_P.attributes_F.attributes_T xview"
	ttk::scrollbar .main_P.data_F.data_P.attributes_F.y_S -orient vertical -command ".main_P.data_F.data_P.attributes_F.attributes_T yview"
	.main_P.data_F.data_P.attributes_F.attributes_T config -xscroll ".main_P.data_F.data_P.attributes_F.x_S set" -yscrollcommand ".main_P.data_F.data_P.attributes_F.y_S set"

	autoscroll::autoscroll .main_P.data_F.data_P.attributes_F.x_S
	autoscroll::autoscroll .main_P.data_F.data_P.attributes_F.y_S

	# Pack it all together in the frame.
	grid .main_P.data_F.data_P.attributes_F.attributes_T .main_P.data_F.data_P.attributes_F.y_S -sticky nsew
	grid .main_P.data_F.data_P.attributes_F.x_S -sticky nsew
	grid columnconfigure .main_P.data_F.data_P.attributes_F 0 -weight 1
	grid rowconfigure .main_P.data_F.data_P.attributes_F 0 -weight 1

	# Bind attributes operations.

	bind [.main_P.data_F.data_P.attributes_F.attributes_T bodytag] <Button-1> {
		::TrafficGenerator::Tree::AttributeTableSelect %W %x %y
	}

	bind [.main_P.data_F.data_P.attributes_F.attributes_T bodytag] <Button-3> {
		::TrafficGenerator::Tree::ShowPopUpMenu .main_P.data_F.data_P.attributes_F.attributes_T .main_P.data_F.data_P.attributes_F.copy_M %x %y
	}

	#
	# Selected attribute info table - frame with table and x scroll bar.
	#

	# Frame.
	frame .main_P.data_F.data_P.attribute_F -relief ridge
	.main_P.data_F.data_P add .main_P.data_F.data_P.attribute_F

	tablelist::tablelist .main_P.data_F.data_P.attribute_F.attribute_T -columntitles {{ } { }} -stretch all -background $bgColor

	ttk::scrollbar .main_P.data_F.data_P.attribute_F.x_S -orient horizontal -command ".main_P.data_F.data_P.attribute_F.attribute_T xview"
	ttk::scrollbar .main_P.data_F.data_P.attribute_F.y_S -orient vertical -command ".main_P.data_F.data_P.attribute_F.attribute_T yview"
	.main_P.data_F.data_P.attribute_F.attribute_T config -xscroll ".main_P.data_F.data_P.attribute_F.x_S set" -yscrollcommand ".main_P.data_F.data_P.attribute_F.y_S set"

	autoscroll::autoscroll .main_P.data_F.data_P.attribute_F.x_S
	autoscroll::autoscroll .main_P.data_F.data_P.attribute_F.y_S

	# Pack it all together in the frame.
	grid .main_P.data_F.data_P.attribute_F.attribute_T .main_P.data_F.data_P.attribute_F.y_S -sticky nsew
	grid .main_P.data_F.data_P.attribute_F.x_S -sticky nsew
	grid columnconfigure .main_P.data_F.data_P.attribute_F 0 -weight 1
	grid rowconfigure .main_P.data_F.data_P.attribute_F 0 -weight 1

}

proc ::TrafficGenerator::Tree::InsertRoot {id text} {
	if {[.main_P.tree_F.objects_T exists $id]} {
		.main_P.tree_F.objects_T delete $id
	}
	.main_P.tree_F.objects_T insert {} end -id $id -text $text -image classIcon
}

# There are object references with spaces so children is LINE\TAB seperated list..
proc ::TrafficGenerator::Tree::InsertChildren {parent children} {
	.main_P.tree_F.objects_T delete [.main_P.tree_F.objects_T children [string map {\\ {}} $parent]]
	foreach child [split $children \n] {
		set id [lindex [split $child \t] 0]
		set name [lindex [split $child \t] 1]
		if {$name == {}} {
			set name $id
		}
		.main_P.tree_F.objects_T insert [string map {\\ {}} $parent] end -id $id -text $name -image classIcon
	}
}

# An open is always followed by Select.
proc ::TrafficGenerator::Tree::TreeviewOpen {node} {
	variable ::TrafficGenerator::Tree::inProc
	# Can be in the middle of another Select (?)
	if {$inProc} {
		return
	}
	::TrafficGenerator::Tree::freezeTree
	::TrafficGenerator::Tree::InsertChildren [join $node] [::TrafficGenerator::Tree::GetChildren [join $node]]
	foreach child [.main_P.tree_F.objects_T children [string map {\\ {}} [join $node]]] {
		if {[::TrafficGenerator::Tree::GetChildrenCount $child] > 0} {
			::TrafficGenerator::Tree::InsertChildren $child ${child}-dummy
		}
	}
	# Automatic call to Select ignored because it was in the middle of Open, call it manually.
	::TrafficGenerator::Tree::selectObject $node
	::TrafficGenerator::Tree::unfreezeTree
}

proc ::TrafficGenerator::Tree::TreeviewSelect {node} {
	variable ::TrafficGenerator::Tree::inProc
	# If in the middle of Open - igon.
	if {$inProc} {
		return
	}
	::TrafficGenerator::Tree::freezeTree
	::TrafficGenerator::Tree::selectObject $node
	::TrafficGenerator::Tree::unfreezeTree
}

proc ::TrafficGenerator::Tree::selectObject {node} {
	global curObjRef
	.main_P.data_F.data_P.attributes_F.attributes_T delete 0 end
	.main_P.data_F.data_P.attribute_F.attribute_T delete 0 end
	set curObjRef [join [lindex [lindex [::TrafficGenerator::Tree::GetNode $node] 1] 1]]
	foreach attribute [::TrafficGenerator::Tree::GetAttributes $curObjRef] {
		.main_P.data_F.data_P.attributes_F.attributes_T insert end [list [$attribute cget -name] [$attribute cget -value]]
	}
}

proc ::TrafficGenerator::Tree::freezeTree {} {
	variable ::TrafficGenerator::Tree::inProc
	# Can I set the open operation inactive like the selection == none?
	set inProc 1
	.main_P.tree_F.objects_T config -selectmode none -cursor watch
	.main_P.data_F.data_P.attributes_F.attributes_T config -cursor watch
	.main_P.data_F.data_P.attribute_F config -cursor watch
}

proc ::TrafficGenerator::Tree::unfreezeTree {} {
	variable ::TrafficGenerator::Tree::inProc
	set inProc 0
	.main_P.tree_F.objects_T config -selectmode browse
	.main_P.tree_F.objects_T config -cursor arrow
	.main_P.data_F.data_P.attributes_F.attributes_T config -cursor arrow
	.main_P.data_F.data_P.attribute_F config -cursor arrow
}

proc ::TrafficGenerator::Tree::CopyObjRefToClipboard {} {
	global curObjRef
	set object [.main_P.tree_F.objects_T selection]
	if {$object == {}} {
		return
	}
	clipboard clear
	clipboard append $curObjRef
}

proc ::TrafficGenerator::Tree::ShowPopUpMenu {window menu c_x c_y} {
	set x [expr [winfo rootx $window]+$c_x]
	set y [expr [winfo rooty $window]+$c_y]
	tk_popup $menu $x $y
}

proc ::TrafficGenerator::Tree::AttributeTableSelect {w x y} {

	global curObjRef
	global curAttrName
	global curAttrValue

	variable ::TrafficGenerator::Tree::attributesTableKeys
	variable ::TrafficGenerator::Tree::bgColor

	foreach {tbl row col} [tablelist::convEventFields $w $x $y] {}
	foreach {curAttrName curAttrValue} [$tbl get [$tbl containing $col]] {}

	.main_P.data_F.data_P.attribute_F.attribute_T delete 0 end
	.main_P.data_F.data_P.attribute_F.attribute_T insert end "Name $curAttrName"
	.main_P.data_F.data_P.attribute_F.attribute_T insert end "Value $curAttrValue"
	foreach info [split [::TrafficGenerator::Tree::GetAttribute $curObjRef $curAttrName] \n] {
		foreach {key value} [split $info \t] {}
		.main_P.data_F.data_P.attribute_F.attribute_T insert end [list $key "$value"]
	}

	for {set r 0} {$r < [.main_P.data_F.data_P.attribute_F.attribute_T childcount root]} {incr r} {
		.main_P.data_F.data_P.attribute_F.attribute_T rowconfig $r -selectable False
	}

}

proc ::TrafficGenerator::Tree::CopyAttrToClipboard {stringToCopy} {
	clipboard clear
	clipboard append $stringToCopy
}

#
# Internal functions, just breaking the process of building the tree view into more redable pieces.
#

proc addObjectsTree {} {

	#
	# Objects tree - frame with tree and x/y scrollbars.
	# There is a bug in autoscroll and it does not work well with treeview unless you set -stretch no.
	# However, then the treeview is not stretched to fill the window.
	# So I've decided to remove the x scrollbar altogether and rely on the paned window to resize and see all data.
	#

	# Frame
	frame .main_P.tree_F -bd 2 -relief ridge
	.main_P add .main_P.tree_F

	# Tree.
	ttk::treeview .main_P.tree_F.objects_T -selectmode browse -show tree

	# Small menu attached to tree.
	menu .main_P.tree_F.objects_T.info_M -tearoff 0
	.main_P.tree_F.objects_T.info_M add command -label "Copy Object Reference To Clipboard" -command {::TrafficGenerator::Tree::CopyObjRefToClipboard}

	# Scroll bars.
	ttk::scrollbar .main_P.tree_F.y_S -orient vertical -command ".main_P.tree_F.objects_T yview"
	autoscroll::autoscroll .main_P.tree_F.y_S

	# Pack it all together in the frame.
	.main_P.tree_F.objects_T config -yscrollcommand ".main_P.tree_F.y_S set"
	grid .main_P.tree_F.objects_T .main_P.tree_F.y_S -sticky nsew
	grid columnconfigure .main_P.tree_F 0 -weight 1
	grid rowconfigure .main_P.tree_F 0 -weight 1

	#
	# Bind tree operations. Open comes before Select.
	#

	bind .main_P.tree_F.objects_T <<TreeviewOpen>> {
		::TrafficGenerator::Tree::TreeviewOpen [.main_P.tree_F.objects_T selection]
	}

	bind .main_P.tree_F.objects_T <<TreeviewSelect>> {
		::TrafficGenerator::Tree::TreeviewSelect [.main_P.tree_F.objects_T selection]
	}

	bind .main_P.tree_F.objects_T <Button-3> {
		::TrafficGenerator::Tree::ShowPopUpMenu .main_P.tree_F.objects_T .main_P.tree_F.objects_T.info_M %x %y
	}

}

proc addObjectTable {} {

}

proc addMenuBar {} {

	menu .main_P.mbar
	. configure -menu .main_P.mbar

	set ::TrafficGenerator::Tree::fullTree 1

	menu .main_P.mbar.file_M -tearoff 0
	.main_P.mbar add cascade -menu .main_P.mbar.file_M -label File -underline 0
	.main_P.mbar.file_M add command -label "Open configuration" -underline 0 -command {::TrafficGenerator::Tree::OpenConfiguration [set currentConfiguration [tk_getOpenFile -filetypes $fileTypes -initialdir $initialdir]]}
	.main_P.mbar.file_M add command -label "Reload configuration" -underline 0 -command {::TrafficGenerator::Tree::OpenConfiguration $currentConfiguration}
	.main_P.mbar.file_M add separator
	.main_P.mbar.file_M add command -label "Exit" -underline 0 -command {exit}

	menu .main_P.mbar.settings_M -tearoff 0
	.main_P.mbar add cascade -menu .main_P.mbar.settings_M -label Settings -underline 0
	.main_P.mbar.settings_M add radiobutton -label "Full Tree" -underline 0 -variable ::TrafficGenerator::Tree::fullTree -value 1
	.main_P.mbar.settings_M add radiobutton -label "Partial Tree" -underline 0 -variable ::TrafficGenerator::Tree::fullTree -value 0
	.main_P.mbar.settings_M add separator
	.main_P.mbar.settings_M add command -label "Unfreeze" -underline 0 -command {::TrafficGenerator::Tree::unfreezeTree}

	menu .main_P.mbar.help_M -tearoff 0
	.main_P.mbar add cascade -menu .main_P.mbar.help_M -label Help -underline 0
	.main_P.mbar.help_M add command -label "About" -underline 0 -command {tk_messageBox -type ok -message $versionMessage}

}

puts "[file tail [info script]] loaded"