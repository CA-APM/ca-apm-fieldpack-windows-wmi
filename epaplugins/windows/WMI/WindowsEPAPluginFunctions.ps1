###Windows PowerShell Script to extract Windows Memory, CPU, DISK Metric for EPAgent
###@Auther Srikant Noorani @

##
##Global XML Config Class
##
$CONFIG_CLASS_SOURCE = @"
public class CONFIG_CLASS {
	public System.String RESOURCE = "";
	public System.Collections.ArrayList INSTANCE_NAMES = new System.Collections.ArrayList(); 
	public System.String WILY_RESOURCE_NAME = "";
	public System.String WILY_METRIC_NAME = "";
	public System.String WILY_DATA_TYPE = "";
	public System.Boolean IS_DELTA = false;
	public System.Int16 VALUE_MULTIPLIER=1;
	public System.String COUNTER_PATH = "";
}
"@

Add-Type -TypeDefinition $CONFIG_CLASS_SOURCE

$METRIC_DATA_SOURCE = @"
public class METRIC_DATA {
	public System.String WILY_RESOURCE_PATH = "";
	public System.String WILY_DATA_TYPE = "";
	public System.String VALUE = "";
	public System.Boolean IS_DELTA = false;
	public System.Int16 VALUE_MULTIPLIER=1;
	public System.String COUNTER = "";
}
"@

Add-Type -TypeDefinition $METRIC_DATA_SOURCE


###
###All Functions
###

##
##Valid value against the DT
##
function ValidateMetricValue ( $DATA_VALUE, $DATA_TYPE ) {

	switch ( $DATA_TYPE.toUpper() ) {
		"LONGCOUNTER" {
			return [long]$DATA_VALUE
		}
		
		"INTCOUNTER" {
			return [int]$DATA_VALUE
		}
		
		"PERINTERVALCOUNTER" {
			return [int]$DATA_VALUE
		}
		"LONGAVERAGE" {
			return [long]$DATA_VALUE
		}
	}
	return 0;
}

##
##return valid metric path
##
function returnWilyMetricPath ( $RESOURCE_NAME, $INSTANCE_NAME, $METRIC_NAME ) {
	$RESOURCE_NAME = $RESOURCE_NAME.replace(":", "_")
	$METRIC_NAME = $METRIC_NAME.replace(":", "_")
	if ($INSTANCE_NAME ) {
		$INSTANCE_NAME = $INSTANCE_NAME.replace(":", "_")
		
		return "$($RESOURCE_NAME)|$($INSTANCE_NAME):$($METRIC_NAME)"
	}
	return "$($RESOURCE_NAME):$($METRIC_NAME)"
}


##
##Publish to StdOut - Will be picked up by EPAgent 
##
function publishMetrics ( $FULL_PATH, $VALUE, $TYPE ) {
	#$FULL_PATH = ValidateMetricPath $FULL_PATH
	$FULL_PATH = "`"$FULL_PATH`""
	
	if ( $VALUE -eq $null ){
		return
	}
		
	$VALUE = ValidateMetricValue $VALUE $TYPE
	$VALUE = "`"$VALUE`""
	$TYPE = "`"$TYPE`""
	
	write-host "<metric type=$TYPE name=$FULL_PATH value=$VALUE />"
 }
 
 function clearObjects  {
 
	$COUNTER_LIST.clear()
	$WILY_PATH_TO_METRIC_DATA_MAP.clear()
 }

##
##ReadXMLConfigFile
##
function readXMLConfigFile ($FILE_NAME) {
	$CONFIG_METRIC_OBJECTS = New-Object System.Collections.ArrayList
	
	[xml]$CONFIG_FILE = get-content -Path "$FILE_NAME"

	if ( $CONFIG_FILE.EPAPlugins.OS.Type.ToUpper() -eq "WINDOWS" ) {
		$LOCAL_SLEEP_TIME = [int]$CONFIG_FILE.EPAPlugins.OS.SleepTimeInSec
		set-variable -name SLEEP_TIME -value $LOCAL_SLEEP_TIME -scope global
	
		$CONFIG_FILE.EPAPlugins.OS.Metrics.ChildNodes | foreach-object -process { 
			$CONFIG_METRIC_OBJECT = New-Object CONFIG_CLASS
			$INSTANCE_NAMES = $_.InstanceNames
			
			if ( $INSTANCE_NAMES -ne $null ) {
				
				$CONFIG_METRIC_OBJECT.INSTANCE_NAMES = $INSTANCE_NAMES.split(";")
			} else {
				$CONFIG_METRIC_OBJECT.INSTANCE_NAMES = $null
			}
			$CONFIG_METRIC_OBJECT.WILY_RESOURCE_NAME = $_.WilyResourceName.trim()
			$CONFIG_METRIC_OBJECT.WILY_METRIC_NAME = $_.WilyMetricName.trim()
			$CONFIG_METRIC_OBJECT.WILY_DATA_TYPE = $_.WilyDataType.trim()
			$CONFIG_METRIC_OBJECT.COUNTER_PATH = $_.CounterPath.trim()	
			if ( $_.ProcessingType -ne $null ) {
				$CONFIG_METRIC_OBJECT.IS_DELTA = $true
			}
			if ( $_.ValueMultiplier -ne $null ) {
				$CONFIG_METRIC_OBJECT.VALUE_MULTIPLIER = [int]$_.ValueMultiplier.trim()
			}
			$NO_OUTPUT = $CONFIG_METRIC_OBJECTS.add($CONFIG_METRIC_OBJECT)
		}	
	}
	return $CONFIG_METRIC_OBJECTS
}
	

##
##processConfigObjects
##
function processConfigObjects ( $CONFIG_METRIC_OBJECTS ) {
	
	#loop through each metric object
	foreach ($CONFIG_OBJECT in $CONFIG_METRIC_OBJECTS) {
		
		# if a metric object has multiple instances
		if ( $CONFIG_OBJECT.INSTANCE_NAMES.count -gt 0 ) {
			foreach ( $INSTANCE_NAME in $CONFIG_OBJECT.INSTANCE_NAMES ) {
				$METRIC_DATA_OBJECT = New-Object METRIC_DATA
				
				$INSTANCE_NAME = $INSTANCE_NAME.trim()
				$RESOURCE_PATH = returnWilyMetricPath $CONFIG_OBJECT.WILY_RESOURCE_NAME $INSTANCE_NAME $CONFIG_OBJECT.WILY_METRIC_NAME
				$COUNTER_PATH = $CONFIG_OBJECT.COUNTER_PATH.replace("`*",$INSTANCE_NAME)
				
				$METRIC_DATA_OBJECT.WILY_RESOURCE_PATH = $RESOURCE_PATH
				$METRIC_DATA_OBJECT.WILY_DATA_TYPE = $CONFIG_OBJECT.WILY_DATA_TYPE
				$METRIC_DATA_OBJECT.IS_DELTA = $CONFIG_OBJECT.IS_DELTA	
				$METRIC_DATA_OBJECT.COUNTER = $COUNTER_PATH		
				$METRIC_DATA_OBJECT.VALUE_MULTIPLIER = [int]$CONFIG_OBJECT.VALUE_MULTIPLIER
				$NO_OUTPUT = $COUNTER_LIST.add($COUNTER_PATH )
				$WILY_PATH_TO_METRIC_DATA_MAP.add($RESOURCE_PATH, $METRIC_DATA_OBJECT)				
			}
		} else {
			$METRIC_DATA_OBJECT = New-Object METRIC_DATA
			
			$RESOURCE_PATH = returnWilyMetricPath $CONFIG_OBJECT.WILY_RESOURCE_NAME $null $CONFIG_OBJECT.WILY_METRIC_NAME
			$COUNTER_PATH = $CONFIG_OBJECT.COUNTER_PATH
			
			$METRIC_DATA_OBJECT.WILY_RESOURCE_PATH = $RESOURCE_PATH
			$METRIC_DATA_OBJECT.WILY_DATA_TYPE = $CONFIG_OBJECT.WILY_DATA_TYPE
			$METRIC_DATA_OBJECT.IS_DELTA = $CONFIG_OBJECT.IS_DELTA
			$METRIC_DATA_OBJECT.COUNTER = $COUNTER_PATH
			$METRIC_DATA_OBJECT.VALUE_MULTIPLIER = [int]$CONFIG_OBJECT.VALUE_MULTIPLIER
			$NO_OUTPUT = $COUNTER_LIST.add($COUNTER_PATH )
			$WILY_PATH_TO_METRIC_DATA_MAP.add($RESOURCE_PATH, $METRIC_DATA_OBJECT)
		}
		
		#$WILY_PATH_TO_METRIC_DATA_MAP.add($METRIC_DATA_OBJECT.WILY_RESOURCE_PATH, $METRIC_DATA_OBJECT)
	}
}
