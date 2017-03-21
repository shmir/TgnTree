
package req inifile

set auxToolsRoot [file dirname [file dirname [info script]]]
set iniFilePath [file join $auxToolsRoot TclAuxTools.ini]

set ini [::ini::open $iniFilePath]

set stc_install_dir [::ini::value $ini STC install_dir]
set initialdir		[::ini::value $ini STC initial_dir]

set commonDir		$auxToolsRoot/Common
set avalancheDir	$auxToolsRoot/Avalanche

lappend auto_path [file join $stc_install_dir "Layer 4-7 Application/TclAPI"]

package require av
av::login temp-workspace-[expr {round(rand()*1000)}]

source "$commonDir/trafficgenerator.tcl"
source "$commonDir/tree/autoscroll.tcl"
source "$commonDir/tree/traffic_tree_main.tcl"
source "$commonDir/tree/traffic_tree_view.tcl"

source "$avalancheDir/avalanche_main.tcl"
source "$avalancheDir/avalanche_namespace.tcl"
source "$avalancheDir/avalanche_tree.tcl"

::Avalanche::Tree::BuildAvlView
.main_P.mbar.settings_M delete 0
set ::TrafficGenerator::Tree::fullTree 0
