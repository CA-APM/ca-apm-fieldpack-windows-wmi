###Windows PowerShell Script to extract Windows Memory, CPU, DISK Metric for EPAgent
###@Auther Srikant Noorani @ 

###
###Include Function File
###

. "C:\EPAgent\epaplugins\windows\WMI\WindowsEPAPluginFunctions.ps1"

###
###Global Variables
###


$FILE_NAME = "C:\EPAgent\epaplugins\windows\WMI\WindowsEPAPlugin.xml"
$COUNTER_LIST = New-Object System.Collections.ArrayList
$WILY_PATH_TO_METRIC_DATA_MAP = @{}
$WILY_PATH_TO_PREV_VALUE_MAP = @{}

set-variable -name SLEEP_TIME -value 10 -scope global

###
###Main
###

while ( $true) {

	clearObjects
	$CONFIG_METRIC_OBJECTS = readXMLConfigFile $FILE_NAME
	processConfigObjects $CONFIG_METRIC_OBJECTS

	$COUNTER_SAMPLE_OBJECTS = get-counter -counter $COUNTER_LIST -ErrorAction SilentlyContinue

	#For Regular Windows Counter
	$WILY_PATH_TO_METRIC_DATA_MAP.GetEnumerator() | foreach-object -process { $METRIC_DATA = $_.value
		$METRIC_NAME = $_.name
		$AVAILABILTY = 0
		$COUNTER = $METRIC_DATA.COUNTER
		foreach ( $COUNTER_SAMPLE_OBJECT in $COUNTER_SAMPLE_OBJECTS.CounterSamples ) {
			if (  ([string]($COUNTER_SAMPLE_OBJECT.path)).toUpper().IndexOf($COUNTER.ToUpper()) -ne -1 ) {	
				$VALUE = $COUNTER_SAMPLE_OBJECT.cookedValue		

				if ( $METRIC_NAME.IndexOf("Process Availability") -ne -1 ){
					$AVAILABILTY = 1
					$VALUE = 1				
				} 
				$METRIC_DATA.VALUE = $VALUE
				if ( $METRIC_DATA.IS_DELTA ) {
					if ( $WILY_PATH_TO_PREV_VALUE_MAP.ContainsKey($METRIC_NAME) ) {
						$VALUE = $VALUE - $WILY_PATH_TO_PREV_VALUE_MAP.Get_Item($METRIC_NAME)
						if ( $VALUE -lt 0 ) {
							$VALUE = $METRIC_DATA.VALUE
						}
						$WILY_PATH_TO_PREV_VALUE_MAP.Set_Item($METRIC_NAME, $METRIC_DATA.VALUE)
					} else {
						$WILY_PATH_TO_PREV_VALUE_MAP.add($METRIC_NAME, $METRIC_DATA.VALUE)
						$VALUE = $null
					}
					
				}	
					$VALUE = [int]$VALUE * $METRIC_DATA.VALUE_MULTIPLIER
					publishMetrics $METRIC_NAME $VALUE $METRIC_DATA.WILY_DATA_TYPE
					
					break
			}
		}
		if ( $METRIC_NAME.IndexOf("Process Availability") -ne -1 -and $AVAILABILTY -ne 1 ) {
			publishMetrics $METRIC_NAME $AVAILABILITY "LongCounter"
		}	
	}
Start-Sleep -s $SLEEP_TIME
}



