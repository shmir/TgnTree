
package req inifile

set tgnTreeRoot [file dirname [file dirname [info script]]]
set iniFilePath [file join $tgnTreeRoot TclAuxTools.ini]

set commonDir		$tgnTreeRoot/Common
set avalancheDir	$tgnTreeRoot/Avalanche

set ini [::ini::open $iniFilePath]
set avl_install_dir [::ini::value $ini AVL install_dir]
set initialdir		[::ini::value $ini AVL initial_dir $avalancheDir]

lappend auto_path [file join $avl_install_dir "Layer 4-7 Application/TclAPI"]
package require av
av::login temp-workspace-[expr {round(rand()*1000)}]

source "$commonDir/trafficgenerator.tcl"
source "$commonDir/tree/autoscroll.tcl"
source "$commonDir/tree/traffic_tree_main.tcl"
source "$commonDir/tree/traffic_tree_view.tcl"

source "$avalancheDir/avl_main.tcl"
source "$avalancheDir/avl_namespace.tcl"
source "$avalancheDir/avl_tree.tcl"

::TrafficGenerator::Tree::Init
::Avalanche::Tree::BuildAvlView
