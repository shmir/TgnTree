
package req inifile

set auxToolsRoot [file dirname [file dirname [info script]]]
set iniFilePath [file join $auxToolsRoot TclAuxTools.ini]

set commonDir		$auxToolsRoot/Common
set testCenterDir	$auxToolsRoot/TestCenter

set ini [::ini::open $iniFilePath]
set stc_install_dir [::ini::value $ini STC install_dir]
set initialdir		[::ini::value $ini STC initial_dir $testCenterDir]

set stc_tcl_dir [file join $stc_install_dir Tcl/lib/]
if {[file exists $stc_tcl_dir]} {
	if {[lsearch $auto_path $stc_tcl_dir] == -1} {
		lappend auto_path $stc_tcl_dir
	}
} else {
	set dir [file join $stc_install_dir "Spirent TestCenter Application"]
	source [file join $dir pkgIndex.tcl]	
}
package require SpirentTestCenter

source "$commonDir/trafficgenerator.tcl"
source "$commonDir/tree/autoscroll.tcl"
source "$commonDir/tree/traffic_tree_main.tcl"
source "$commonDir/tree/traffic_tree_view.tcl"

source "$testCenterDir/stc_main.tcl"
source "$testCenterDir/stc_stats.tcl"
source "$testCenterDir/stc_namespace.tcl"
source "$testCenterDir/stc_tree.tcl"

::TrafficGenerator::Tree::Init
::TestCenter::Tree::BuildStcView
