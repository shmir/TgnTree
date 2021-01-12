#!/bin/sh
# Dummy comment line - part of shebang, do not remove \
exec wish85 "$0" "$@"

puts [info script]
set tgnTreeRoot [file dirname [file dirname [file normalize [info script]]]]
puts $tgnTreeRoot
set commonDir $tgnTreeRoot/Common
set ixLoadDir $tgnTreeRoot/IxLoad

# TO BE DEFINED BY THE USER
#
# IxLoad client install path.
set ixlInstallDir "D:/Program Files (x86)/Ixia/IxLoad/9.00.0.347"
# Initial directory to Browse for IxLoad configuration files (rxf). 
set initialdir $ixLoadDir
#
# EDO NOT CHANGE AFTER THIS POINT

if {[llength $argv] > 0} {
	set ixlInstallDir [lindex $argv 0]
}

source [file join $ixlInstallDir TclScripts/bin/IxiaWish.tcl]
package require IxLoad

source "$commonDir/trafficgenerator.tcl"
source "$commonDir/tree/autoscroll.tcl"
source "$commonDir/tree/traffic_tree_main.tcl"
source "$commonDir/tree/traffic_tree_view.tcl"

source "$ixLoadDir/ixl_tree.tcl"

::TrafficGenerator::Tree::Init
::IxLoad::Tree::BuildIxlView
.main_P.mbar.settings_M delete 1
set ::TrafficGenerator::Tree::fullTree 1
