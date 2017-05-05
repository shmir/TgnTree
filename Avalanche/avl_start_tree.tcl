
set tgnTreeRoot 	[file dirname [file dirname [info script]]]
set commonDir		$tgnTreeRoot/Common
set avalancheDir	$tgnTreeRoot/Avalanche

# TO BE DEFINED BY THE USER
#
# Avalanche client install path.
set avlInstallDir "C:/Program Files (x86)/Spirent Communications/Spirent TestCenter 4.71"
# Initial directory to Browse for Avalanche configuration files (spf). 
set initialdir $avalancheDir
#
# EDO NOT CHANGE AFTER THIS POINT

lappend auto_path [file join $avlInstallDir "Layer 4-7 Application/TclAPI"]
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
