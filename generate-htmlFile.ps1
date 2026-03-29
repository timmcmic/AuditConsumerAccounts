function Generate-HTMLFile
{
    Param
    (
        [Parameter(Mandatory = $true)]
        $htmlTime,
        [Parameter(Mandatory = $true)]
        $accounts
    )
    
    out-logfile -string "Begin Generate-HTMLFile"

    $outputHTML = $global:LogFile.replace("log","html")

    #Prepare the HTML file for output.
    #Define the HTML file.

    out-logfile -string "Preparring to generate HTML file."

    $functionHTMLSuffix = "html"
    $outputHTML = $global:LogFile.replace("log","$functionHTMLSuffix")

    $headerString = ("EntraID to Consumer Account Report")

    New-HTML -TitleText $headerString -FilePath $outputHTML {
        New-HTMLHeader {
            New-HTMLText -Text $headerString -FontSize 24 -Color White -BackGroundColor Black -Alignment center
        }
        new-htmlMain{
            #Define HTML table options.

            New-HTMLTableOption -DataStore JavaScript

            out-logfile -string "Generate consumer account table."

            if ($accounts.count -gt 0)
            {
                $test = $accounts | where {$_.AccountPresent -eq $true}

                if ($test.count -gt 0)
                {
                    out-logfile -string "Consumer accounts were present - generate table."

                    new-htmlSection -HeaderText ("Consumer Account Summary Report") {
                        new-htmlTable -DataTable ($test | Select-Object Address,ID,UPN,RequestID) -Filtering -AlphabetSearch{
                        } 
                    }-HeaderTextAlignment "Left" -HeaderTextSize "16" -HeaderTextColor "White" -HeaderBackGroundColor "Blue"  -CanCollapse -BorderRadius 10px -collapsed
                }
                else 
                {
                    new-HTMLText -Text "No Consumer Accounts Found" -FontSize 24 -Color White -BackGroundColor Red -Alignment center
                }

                $test = $accounts | where {$_.accountError -eq $TRUE}

                if ($test.count -gt 0)
                {
                    out-logfile -string "Account testing failed - list errors.."

                    new-htmlSection -HeaderText ("Consumer Account Failed Queries") {
                        new-htmlTable -DataTable ($test | Select-Object Address,ID,UPN,AccountErrorText) -Filtering -AlphabetSearch{
                        } 
                    }-HeaderTextAlignment "Left" -HeaderTextSize "16" -HeaderTextColor "White" -HeaderBackGroundColor "Red"  -CanCollapse -BorderRadius 10px -collapsed
                }
                else 
                {
                    new-HTMLText -Text "No Consumer Accounts Test Errors Found" -FontSize 24 -Color White -BackGroundColor Red -Alignment center
                }
            }
            else 
            {
                new-HTMLText -Text "No Consumer Accounts Found" -FontSize 24 -Color White -BackGroundColor Red -Alignment center
                new-HTMLText -Text "No Consumer Accounts Test Errors Found" -FontSize 24 -Color White -BackGroundColor Red -Alignment center
            }

            
        
            out-logfile -string "Generate timeline."

            new-htmlSection -HeaderText ("Migration Timeline Highlights"){
                new-HTMLTimeLIne {
                    new-HTMLTimeLineItem -HeadingText "StartTime" -Date $htmlTime.htmlStartTime
                    new-HTMLTimeLineItem -HeadingText "Start Powershell Validation" -Date $htmlTime.htmlStartPowershellValidation
                    new-HTMLTimeLineItem -HeadingText "Start MSGraph Connection" -Date $htmlTime.htmlStartMSGraph
                    new-HTMLTimeLineItem -HeadingText "Start Verify MSGraph" -Date $htmlTime.htmlVerifyMSGraph
                    new-HTMLTimeLineItem -HeadingText "Validate Email Addresses" -Date $htmlTime.ValidateAddressesProvided
                    new-HTMLTimeLineItem -HeadingText "Start Get MSGraph Users" -Date $htmlTime.htmlGetMSGraphUsers
                    new-HTMLTimeLineItem -HeadingText "Start Get MSGraph Domains" -Date $htmlTime.htmlGetMSGraphDomains
                    new-HTMLTimeLineItem -HeadingText "Chunk Users to Test" -Date $htmlTime.htmlChunkUsers
                    new-HTMLTimeLineItem -HeadingText "Evaluate Addresses to Test" -Date $htmlTime.htmlAddressesToTest
                    new-HTMLTimeLineItem -HeadingText "Chunk Addresses To Test" -Date $htmlTime.htmlChunkAccounts
                    new-HTMLTimeLineItem -HeadingText "Evaluate Consumer Accounts" -Date $htmlTime.htmlConsumerAccountTest
                    new-HTMLTimeLineItem -HeadingText "EndTime" -Date $htmlTime.htmlEndTime
                }
            } -HeaderTextAlignment "Left" -HeaderTextSize "16" -HeaderTextColor "White" -HeaderBackGroundColor "Black"  -CanCollapse -BorderRadius 10px -collapsed #>
        }
    } -online -ShowHTML
}   
