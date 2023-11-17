# Remote-Reliability-History
Remotely get Windows Reliability History also known as Stability Index
![image](https://github.com/ricofox959/Remote-Reliability-History/assets/23040918/34284bc6-9f80-414f-917e-5de27ad5dca5)

# About
This is a powershell-based tool to get a remote device's Reliability History and render stability index data in the form of a timeline graph using jscharts.

Reliability History shows events that affect a computer's stability index from 0 - 10, 10 being the highest score. Critical or Error events can decrease the score.
I have observed that BSOD events are not captured through the WMI/CIM method of the event data shown.
Also, this is still in development so there may be other event IDs I have not identified that will fail to display.

PSHTML is the core of what makes this graph work, so be sure the module is installed and check them out here: https://pshtml.readthedocs.io/en/latest/
I recommend installing PSHTML from the PowerShell Gallery 

I hope you find this helpful and I welcome any advice or issues you may find using this tool.

# Running the Code
Load the function into memory and simply run the command:
  PS C:\Users\Rico\OneDrive\Documents\GitHub\Remote-Reliability-History> Get-ReliabilityHistory -ComputerName <computer name>

# Launching Reliability Monitor
Reliability Monitor is built into Windows 7, Windows 10 and 11. It is also found in Windows Server OS. I am currently only testing on Windows 10, so if you find issues please let me know of them too.

To access Reliability Monitor on your PC
  1. Open Control Panel.
  2. Open Security and Maintenance.
  3. Expand the Maintenance Category, then select “View Reliability history” under the heading that reads “Check for solutions to problem reports.”
