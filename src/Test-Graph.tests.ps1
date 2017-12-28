# Copyright 2017, Adam Edwards
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

$here = Split-Path -Parent $MyInvocation.MyCommand.Path

Describe "The Test-Graph cmdlet" {
    $manifestLocation   = Join-Path $here '..\poshgraph.psd1'
    $graphPing200Response = get-content -encoding utf8 -path "$psscriptroot\testassets\graphping200.json"

    Mock Invoke-WebRequest {
        $result = $graphPing200Response | convertfrom-json
        $result.headers = @{}
        $result
    }

    Context "when receiving a successful response from Graph" {
        BeforeAll {
            remove-module -force 'poshgraph' 2>$null
            import-module stdposh -force
            import-module $manifestlocation -force
        }

        AfterAll {
            remove-module -force 'poshgraph' 2>$null
        }

        It "should succeed when given no parameters" {
            { Test-Graph | out-null } | Should Not Throw
        }

        It "should succeed when given a cloud parameter" {
            { Test-Graph -cloud ([GraphCloud]::Public) | out-null } | Should Not Throw
            { Test-Graph -cloud ([GraphCloud]::ChinaCloud) | out-null } | Should Not Throw
            { Test-Graph -cloud ([GraphCloud]::GermanyCloud) | out-null } | Should Not Throw
            { Test-Graph -cloud ([GraphCloud]::USGovernmentCloud) | out-null } | Should Not Throw
        }

        It "should succeed when given a custom graph URI parameter" {
            { Test-Graph -endpointuri 'https://graph.microsoft.com' | out-null } | Should Not Throw
        }

        It "should succeed when given a verbose parameter" {
            { Test-Graph -verbose *> $null } | Should Not Throw
        }

        It "should return a result with expected members" {
            $testResult = Test-Graph
            ($testResult.TimeLocal).gettype() | Should BeExactly 'datetime'
            ($testResult.TimeUtc).gettype() | Should BeExactly 'datetime'
            ($testResult.Build).gettype() | Should BeExactly 'string'
            ($testResult.Slice).gettype() | Should BeExactly 'string'
            ($testResult.Ring).gettype() | Should BeExactly 'string'
            ($testResult.ScaleUnit).gettype() | Should BeExactly 'string'
            ($testResult.Host).gettype() | Should BeExactly 'string'
            ($testResult.ADSiteName).gettype() | Should BeExactly 'string'
        }

    }
}