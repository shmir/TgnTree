
package req inifile

set auxToolsRoot [file dirname [file dirname [info script]]]
set iniFilePath [file join $auxToolsRoot TclAuxTools.ini]

set commonDir $auxToolsRoot/Common
set ixLoadDir $auxToolsRoot/IxLoad

set ini [::ini::open $iniFilePath]
set ixl_install_dir [::ini::value $ini IXL install_dir]
set initialdir [::ini::value $ini IXL initial_dir $ixLoadDir]

source [file join $ixl_install_dir TclScripts/bin/IxiaWish.tcl]
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
