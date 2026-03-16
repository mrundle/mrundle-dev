# Example of how to have a main() function

function funcname([int]$depth = 0) {
    (Get-PSCallStack | Select-Object FunctionName | Select-Object -Index (1+$depth)).FunctionName

}

function foo {
    param (
        [string]$throwaway_a,
        [string]$throwaway_b,
        [string]$throwaway_c,
        [Parameter(mandatory)][string]$varA,
        [Parameter(mandatory)][string]$varB,
        [string]$throwaway_d,
        [string]$throwaway_e,
        [string]$throwaway_f
    )
    echo "from function $(funcname), `$varB: $varB"
}

function bar([string]$varA) {
    echo "from function $(funcname), `$varA: $varA"
}

function main {
    param (
        [string]$throwaway_a,
        [string]$throwaway_b,
        [string]$throwaway_c,
        [Parameter(mandatory)][string]$varA,
        [Parameter(mandatory)][string]$varB,
        [string]$throwaway_d,
        [string]$throwaway_e,
        [string]$throwaway_f
    )
    echo "from function $(funcname), `$varA: $varA"
    foo @PSBoundParameters
    bar @PSBoundParameters
}

main -varA "valueX" -varB "valueY"
