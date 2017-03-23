
package req inifile

set auxToolsRoot [file dirname [file dirname [info script]]]
set iniFilePath [file join $auxToolsRoot TclAuxTools.ini]

set commonDir		$auxToolsRoot/Common
set ixNetworkDir	$auxToolsRoot/IxNetwork

set ini [::ini::open $iniFilePath]
set ixn_install_dir [::ini::value $ini IXN install_dir]
set initialdir		[::ini::value $ini IXN initial_dir $ixNetworkDir]

source  [file join $ixn_install_dir TclScripts/lib/IxTclNetwork/pkgIndex.tcl] 
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
