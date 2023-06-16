Function Get-ReliabilityHistory {
    <#
    .SYNOPSIS
    Opens an HTML page of Windows Reliability History for a remote computer.
    
    .DESCRIPTION
     Get-ReliabilityHistory opens an html page for a single remote computer. The upper section of the page will display a Stability Index graph going back 19 days.
     The lower portion of the page will show related events grouped and displayed by day selected.
    
    .EXAMPLE
    Get-ReliabilityHistory -ComputerName minnit7630
    
    .NOTES
    General notes
    PSHTML is a prequeite for this function to work
    https://pshtml.readthedocs.io/en/latest/
    
    It can be installed from Powershell Gallery 
    https://www.powershellgallery.com/packages/PSHTML/0.8.2
    Install-Module -Name PSHTML
    
    https://www.chartjs.org/docs/latest/getting-started/integration.html
    #>
        [CmdletBinding()]
        param(
            [Parameter(ValueFromPipeline = $True)]
            [string[]]$ComputerName
        )
    
        Begin {
            if ($ComputerName -eq ".") {
                $ComputerName = $env:COMPUTERNAME
            }
            if ($null -eq $ComputerName) {
                $ComputerName = $env:COMPUTERNAME
            }

            # Use CIM WMI if local machine else use Remote CIM/WMI method
            if ($ComputerName -eq $env:COMPUTERNAME ) {
                # Gather the reliability / stability index data for last 19 days
                $Index = Get-CimInstance Win32_ReliabilityStabilityMetrics | Sort-Object -Property EndMeasurementDate | Where-Object EndMeasurementDate -GT (Get-Date).AddDays(-19)
                
                # Gather ALL the Events related to stability index data
                $Events = Get-CimInstance Win32_ReliabilityRecords 
            }
            Else {
                # Gather the reliability / stability index data for last 19 days
                $Index = Get-CimInstance Win32_ReliabilityStabilityMetrics -ComputerName $ComputerName | Sort-Object -Property EndMeasurementDate | Where-Object EndMeasurementDate -GT (Get-Date).AddDays(-19)
                
                # Gather ALL the Events related to stability index data
                $Events = Get-CimInstance Win32_ReliabilityRecords -ComputerName $ComputerName
            }
        }

        Process {
            Set-ExecutionPolicy -ExecutionPolicy Unrestricted
            Import-Module PSHTML -Force
        
            $LineCanvasID = "Linecanvas"
            $HTMLPage = html {
                head {
                    Title "Reliability History - $ComputerName"
                    style -Content "
                    h1 {
                        color: #00b0f0;
                        font-size: 42pt;
                    }

                    body {font-family: Segoe UI Light;}
                    .tab {
                        overflow: hidden;
                        border: 1px solid #ccc;
                        background-color: #f1f1f1;
                    }
                    .tab button {
                        background-color: inherit;
                        float: left;
                        border:none;
                        outline:none;
                        cursor: pointer;
                        padding: 14px 16px;
                        transition: 0.3s;
                        font-size: 17px;
                    }
                    .tab button:hover {
                        background-color: #ddd;
                    }
                    .tab button.active {
                        background-color: #ccc;
                    }
                    .tabcontent {
                        display: none;
                        padding: 6px 12px;
                        border: 1px solid #ccc;
                        border-top: none;
                    }
                    "
                } # End head
        
                Body {
                    H1 "$ComputerName`: Reliability and problem history"

        
                    Div {
        
                        p {
                            "The stability index assesses the system's overall stability on a scale from 1 to 10. By selecting a specified period in time, you may review the specific hardware and software problems that have impacted the system."
                        }
                        canvas -Height 400px -Width 1700px -Id $LineCanvasID {}
                    } # End Div
        
                    script -src "https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.3/Chart.min.js" -type "text/javascript"
        
                    script -content {
                        $Data1 = $Index.SystemStabilityIndex
                        $EventDates = $Index.EndMeasurementDate.ToShortDateString()
                        $DataSet1 = New-PSHTMLChartLineDataSet -Data $Data1 -label "$ComputerName" -LineColor 'Blue' -LineWidth 1 -LineChartType Straight -PointRadius 0 -LineType Full
                        New-PSHTMLChart -Type line -DataSet @($DataSet1) -Title "Line Chart $ComputerName" -Labels $EventDates -CanvasID $LineCanvasID
                    }
                    p {
                        "Click on a date to see reliability details."
                    }
        
                    # Arrange data and group
                    $EventsbyDate = $Events | Select-Object @{Name = "Source"; Expression = {$_.ProductName} }, @{Name = "Summary";Expression = {
                        switch ($_.EventIdentifier) {
                            "6008"  {"Windows was not properly shutdown"} # Critial
                            "1000"  {"Stopped working"}
                            #"1001" Event ID1000 is not collected?
                            "1002"  {"Stopped responding and was closed"}
                            "20"    {"Failed Windows Update"} # Warning
                            "1033"  {"Successful application installation"} #informational
                            "1035"  {"Successful application removal"} #informational
                            "19"    {"Successful Windows Update"} #informational   
                        } } }, TimeGenerated | Group-Object {$_.TimeGenerated.ToString("MM/dd/yyyy")}
                        
                        # Create Toggleable Tabs
                        div -Class tab {
                        $EventsbyDate | Sort-Object -Property Name | ForEach-Object {
                                # Create Tab links
                                button -Content $_.Name -Class tablinks -Attributes @{onclick = "openDate(event, '$($_.Name)')"}
                            }
                        }
                         
                        # Create Tab content
                        $EventsbyDate | ForEach-Object {
                            div -Class tabcontent -Id $($_.Name) {
                                h3 -Content $($_.Name)
                                p "Reliability details for: $($_.Name)"
                                ConvertTo-PSHTMLTable -Object $_.Group
                            }
                        }
                    
                        # Add JavaScript for toggling tabs
                        script -content '
                            function openDate(evt, tabName) {
                                var i, tabcontent, tablinks;
                                tabcontent = document.getElementsByClassName("tabcontent");
                                for (i = 0; i < tabcontent.length; i++) {
                                    tabcontent[i].style.display = "none";
                                }
                                tablinks = document.getElementsByClassName("tablinks");
                                for (i = 0; i < tablinks.length; i++) {
                                    tablinks[i].className = tablinks[i].className.replace(" active", "");
                                }
                                document.getElementById(tabName).style.display = "block";
                                evt.currentTarget.className += "active";
                            }
                        '
        
                } # End Body
            } # End html
        } # End Process Block
        
        End {
            $Outpath = "$Home\$ComputerName" + "_ReliabilityHistory.html"
            $HTMLPage | Out-File -FilePath $Outpath -Encoding utf8
            Start-Process $Outpath
        }      
    } # End Function Get-ReliabilityHistory    