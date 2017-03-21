
package req inifile

set auxToolsRoot [file dirname [file dirname [info script]]]
set iniFilePath [file join $auxToolsRoot TclAuxTools.ini]

set ini [::ini::open $iniFilePath]

set initialdir [::ini::value $ini IXL install_dir]

set commonDir $auxToolsRoot/Common
set ixLoadDir $auxToolsRoot/IxLoad

source [file join $initialdir TclScripts/bin/IxiaWish.tcl]

package require IxLoad

source "$commonDir/trafficgenerator.tcl"
source "$commonDir/tree/autoscroll.tcl"
source "$commonDir/tree/traffic_tree_main.tcl"
source "$commonDir/tree/traffic_tree_view.tcl"

source "$ixLoadDir/ixl_tree.tcl"

::IxLoad::Tree::BuildIxlView
.main_P.mbar.settings_M delete 1
set ::TrafficGenerator::Tree::fullTree 1
