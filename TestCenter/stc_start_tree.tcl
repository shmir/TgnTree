
set tgnTreeRoot 	[file dirname [file dirname [info script]]]
set commonDir		$tgnTreeRoot/Common
set testCenterDir	$tgnTreeRoot/TestCenter

# TO BE DEFINED BY THE USER
#
# Avalanche client install path.
set stcInstallDir "C:/Program Files (x86)/Spirent Communications/Spirent TestCenter 4.71"
# Initial directory to Browse for Avalanche configuration files (spf). 
set initialdir		$testCenterDir
#
# EDO NOT CHANGE AFTER THIS POINT

set stcTclDir [file join $stcInstallDir Tcl/lib/]
if {[file exists $stcTclDir]} {
	if {[lsearch $auto_path $stcTclDir] == -1} {
		lappend auto_path $stcTclDir
	}
} else {
	set dir [file join $stcInstallDir "Spirent TestCenter Application"]
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
