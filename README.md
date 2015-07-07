#Windows WMI Monitoring (1.0)

Description
This EPAgent field pack provides a mechanism to collect windows wmi metrics. Its run as a stateful plugin that collect metrics at a regular interval. The plugin is written in Windows Powershell. The agent is deployed under c:\EPAgent

NOTE TO CONTRIBUTORS: Projects are designed to be self documenting in this README file. Rich text (including screenshots) can be found inside the projects themselves (as committed assets). Generally a project overview (including description, sample screenshots, etc.) can be found on the project wiki page at http://github.com/ca-apm/ca-apm-fieldpack-windows-wmi/wiki.

##Releases

From time to time, projects may make compiled releases available. While source code is always available for complete build, releases serve as a "tag" (numbered release) and often contain prepared packages that are prebuilt and ready to use. Visit http://github.com/ca-apm/ca-apm-fieldpack-windows-wmi/releases for details.

##APM version

9.5,9.6,9.7

##Supported third party versions

Third party versions tested with.

##Limitations

What the field pack will not do.

##License

Link to the license under which this field pack is provided. See Licensing on the CA APM Developer Community.

Please review the LICENSE file in this repository. Licenses may vary by repository. Your download and use of this software constitutes your agreement to this license.

##Installation Instructions

standard plugin installation. Agent Needs to be deployed under C:\EPAgent

##Prerequisites

Make sure powershell is available and you are able to run. You may have to change th epowershell execution policy

##Dependencies
EPAgent 9.5,9.6,9.7

##Installation

standard epa deploy it under c:\EPAgent
add the following to your agent properties file

introscope.epagent.plugins.stateful.names=POWERSHELL
introscope.epagent.stateful.POWERSHELL.command=powershell -File C:\\EPAgent\\epaplugins\\windows\\WMI\\WindowsEPAPlugin.ps1


##Configuration

How to configure the field pack.

#Usage Instructions
run as regular. If you need to add more metrics pls use epaplugins\windows\WMI\WindowsEPAPlugin.xml

##Metric description



##Custom Management Modules

Dashboards, etc. included with this field pack.

##Custom type viewers

Type viewers included with this field pack. Include agent and metric path that the type viewer matches against.

##Name Formatter Replacements

If the field pack includes name formatters cite all place holders here and what they are replaced with.

##Debugging and Troubleshooting

1. look for error msg in the agent log
2. run the plugin from powershell window and troubleshoot

Support

This document and associated tools are made available from CA Technologies as examples and provided at no charge as a courtesy to the CA APM Community at large. This resource may require modification for use in your environment. However, please note that this resource is not supported by CA Technologies, and inclusion in this site should not be construed to be an endorsement or recommendation by CA Technologies. These utilities are not covered by the CA Technologies software license agreement and there is no explicit or implied warranty from CA Technologies. They can be used and distributed freely amongst the CA APM Community, but not sold. As such, they are unsupported software, provided as is without warranty of any kind, express or implied, including but not limited to warranties of merchantability and fitness for a particular purpose. CA Technologies does not warrant that this resource will meet your requirements or that the operation of the resource will be uninterrupted or error free or that any defects will be corrected. The use of this resource implies that you understand and agree to the terms listed herein.

Although these utilities are unsupported, please let us know if you have any problems or questions by adding a comment to the CA APM Community Site area where the resource is located, so that the Author(s) may attempt to address the issue or question.

Unless explicitly stated otherwise this field pack is only supported on the same platforms as the APM core agent. See APM Compatibility Guide.

Contributing
The CA APM Community is the primary means of interfacing with other users and with the CA APM product team. The developer subcommunity is where you can learn more about building APM-based assets, find code examples, and ask questions of other developers and the CA APM product team.

If you wish to contribute to this or any other project, please refer to easy instructions available on the CA APM Developer Community.

Change log
Changes for each version of the field pack.

Version	Author	Comment
1.0	Your name	First version of the field pack.
