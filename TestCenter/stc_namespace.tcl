# Many of the objects are added to the Namespace just for the tree.
# These objects are marked with Type == NA.
				
proc ::TestCenter::BuildDefaultNameSpace {} {
	variable ::TestCenter::resultDataSet_Array
	variable ::TestCenter::statViews_Array
	variable ::TestCenter::project

	::TrafficGenerator::clearObjectRecord
	::TestCenter::setStatsViews

	::TrafficGenerator::addToNameSpace [stc::get system1 -Name] system1 NA {} {}
	set project [stc::get system1 -children-Project]
	::TrafficGenerator::addToNameSpace [stc::get $project -Name] $project NA {} system1
	
	::TestCenter::BuildPortNameSpace
	::TestCenter::BuildDeviceNameSpace
	::TestCenter::BuildResultNameSpace

	::TrafficGenerator::setAllObjectTypes {Port StreamBlock EmulatedDevice AnalyzerFilter CaptureFilter}
	return [::TrafficGenerator::getObjects_Array]

}
		
proc ::TestCenter::BuildPortNameSpace {} {
	variable ::TestCenter::project

	foreach port [stc::get $project -children-Port] {
		# STC adds (offline) to the name (since it is offline at this point) so we remove it
		set name [lrange [stc::get $port -Name] 0 end-1]
		::TrafficGenerator::addToNameSpace $name $port Port {} $project
		foreach stream [stc::get $port -children-StreamBlock] {
			set name [stc::get $stream -Name]
			::TrafficGenerator::addToNameSpace $name $stream StreamBlock {} $port
		}
		
		set analyzer [stc::get $port -children-analyzer] 
		set analyzerframeconfigfilter [stc::get $analyzer -children-analyzerframeconfigfilter]
		if {$analyzerframeconfigfilter == ""} {
			continue
		}
		::TrafficGenerator::addToNameSpace [stc::get $analyzer -Name] $analyzer NA {} $port
		foreach filter [concat [stc::get $analyzer -children-analyzer32bitfilter] [stc::get $analyzer -children-analyzer16bitfilter]] {
			set name [stc::get $filter -FilterName]
			::TrafficGenerator::addToNameSpace $name $filter AnalyzerFilter {} $analyzer
		}
		
		set capture [stc::get $port -children-capture]
		::TrafficGenerator::addToNameSpace [stc::get $capture -Name] $capture NA {} $port
		foreach filter [concat [stc::get $capture -children-capturerangepattern] [stc::get $capture -children-captureanalyzerfilter]] {
			set name [stc::get $filter -Name]
			::TrafficGenerator::addToNameSpace $name $filter CaptureFilter {} $capture
		}

		set captureFilter [stc::get $capture -children-capturefilter]
		::TrafficGenerator::addToNameSpace [stc::get $captureFilter -Name] $captureFilter NA {} $capture		
		foreach filter [stc::get $captureFilter -children-captureanalyzerfilter] {
			set name [stc::get $filter -FilterDescription]
			::TrafficGenerator::addToNameSpace $name $filter CaptureFilter {} $captureFilter
		}
	}

}

		
proc ::TestCenter::BuildDeviceNameSpace {} {
	variable ::TestCenter::project

	foreach device [stc::get $project -children-emulateddevice] {
		set name [stc::get $device -Name]
		::TrafficGenerator::addToNameSpace $name $device EmulatedDevice {} $project
	}

}

#
# Generaly speaking, the loaded configuration file can include results objects of the following types:
# - Standard system views - the GUI saves all standard views that are open during the Save command.
# - Custom views - the GUI saves all custom views, whether open or not.
# - Subscribed views - the API command SaveToTccCommand saves all results objects that were created with Subscribe command (Unsubscribe does not destroy the results object).
# We are interested only in the custom views.
# Moreover, we delete all other (non interesting) objects to clear the configuration file.
# Otherwise, whenever a test subscribes and saves the configuration it will add more and more objects to the configuration file.
#  
proc ::TestCenter::BuildResultNameSpace {} {
	variable ::TestCenter::resultDataSet_Array
	variable ::TestCenter::statViews_Array
	variable ::TestCenter::project

	foreach result [concat [stc::get $project -children-resultdataset] [stc::get $project -children-dynamicresultview]] {
		set i [array size statViews_Array]
		set view [stc::get $result -Name]
		set viewL [string tolower $view]
		if {[stc::get $result -ResultViewOwner] == "USER" && ![regexp {resultdataset*} $viewL]} {
			set statViews_Array($viewL) [statView_Record sv_R[incr i] -resultType $view -configTypes User -group User -description ""]
			set resultDataSet_Array($viewL,User) $result
		} else {
			stc::delete $result 
		} 
	}

	foreach result [stc::get $project -children-dynamicresultview] {
		if {[stc::get $result -ResultViewOwner] == "USER"} {
			stc::perform SubscribeDynamicResultView -DynamicResultView $resultDataSet_Array([string tolower [stc::get $result -Name]],User)
		}
	}

}
