# Remote-Reliability-History
Remotely get Windows Reliability History also known as Stability Index
![image](https://github.com/ricofox959/Remote-Reliability-History/assets/23040918/34284bc6-9f80-414f-917e-5de27ad5dca5)

# About
This is a powershell based tool to get a remote devices Reliability History and render stability index data in the form of a timeline graph using jscharts.

Reliability History shows events that effect a computer's stability index from 0 - 10, 10 being the highest score. Critial or Error events can descrease the score.
I have observered that BSOD events are not captured throught the WMI/CIM method of the event data shown.
Also this is still in development so there may be other event ID's I have not identified and that will fail to display.

PSHTML is the core of what makes this graph work, so be sure the module is installed and check them out here: https://pshtml.readthedocs.io/en/latest/
I recommend installing PSHTML from the PowerShell Gallery 

I hope you find this helpful and I welcome any advice or issues you may find using this tool.
