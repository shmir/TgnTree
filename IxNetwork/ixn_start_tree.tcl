
set tgnTreeRoot [file dirname [file dirname [info script]]]
set commonDir $tgnTreeRoot/Common
set ixNetworkDir $tgnTreeRoot/IxNetwork

# TO BE DEFINED BY THE USER
#
# IxNetwork client install path.
set ixnInstallDir "C:/Program Files (x86)/Ixia/IxNetwork/8.01-GA"
# Initial directory to Browse for IxNetwork configuration files (ixncfg). 
set initialdir $ixNetworkDir
#
# EDO NOT CHANGE AFTER THIS POINT

source  [file join $ixnInstallDir TclScripts/lib/IxTclNetwork/pkgIndex.tcl] 
set version [package require IxTclNetwork]
ixNet connect localhost -port 8009 -version $version

source "$commonDir/trafficgenerator.tcl"
source "$commonDir/tree/autoscroll.tcl"
source "$commonDir/tree/traffic_tree_main.tcl"
source "$commonDir/tree/traffic_tree_view.tcl"

source "$ixNetworkDir/ixn_main.tcl"
source "$ixNetworkDir/ixn_namespace.tcl"
source "$ixNetworkDir/ixn_tree.tcl"

::IxNetwork::ReadStaticTreeFile $ixNetworkDir/ixn_static_tree.txt
::TrafficGenerator::Tree::Init
::IxNetwork::Tree::BuildIxnView
