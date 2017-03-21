
set ixn_install_dir {C:/Program Files (x86)/Ixia/IxNetwork/7.40-GA}

proc BuildStaticTree {outputFile} {
	global outputFileH

	set outputFileH [open $outputFile w]
	BuildStaticTreeRecursive [ixNet getRoot]
	flush $outputFileH
	close $outputFileH
}

proc BuildStaticTreeRecursive {parent} {
	global outputFileH

	# Sometimes IxNetwork throws Exception (API bug) so we must wrap with catch.  
	if {[catch {lsort [::IxNetwork::GetChildList $parent]} children] == 0} {
		puts $outputFileH "$parent\t$children"
		flush $outputFileH
		foreach child $children {
			if {[lsearch [split $parent /] $child] == -1} {		
				BuildStaticTreeRecursive $parent/$child
			}
		}
	}
	
}

source  [file join $ixn_install_dir TclScripts/lib/IxTclNetwork/pkgIndex.tcl] 
set version [package require IxTclNetwork]

ixNet connect localhost -port 8009 -version $version
set root [ixNet getRoot]

ixNet exec newConfig
ixNet commit

set commonDir		"C:/Users/yoram-s/python/tgconvert_workspace/TclAuxTools/Common"
set ixNetworkDir	"C:/Users/yoram-s/python/tgconvert_workspace/TclAuxTools/IxNetwork"

source "$commonDir/trafficgenerator.tcl"
source "$commonDir/tree/autoscroll.tcl"
source "$commonDir/tree/traffic_tree_main.tcl"
source "$commonDir/tree/traffic_tree_view.tcl"

source "$ixNetworkDir/ixn_main.tcl"
source "$ixNetworkDir/ixn_namespace.tcl"
source "$ixNetworkDir/ixn_tree.tcl"

set t1 [clock seconds] ; BuildStaticTree c:/temp/staticTree.txt ; expr [clock seconds] - $t1
