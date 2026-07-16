@{
    Severity = @('Error', 'Warning')

    # Rules excluded because they conflict with documented conventions in AGENTS.md.
    ExcludeRules = @(
        # AGENTS.md mandates Write-Host for user-facing output.
        'PSAvoidUsingWriteHost',
        # The installer uses try/catch-continue error handling; ShouldProcess
        # (-WhatIf/-Confirm) is not appropriate for these interactive helpers.
        'PSUseShouldProcessForStateChangingFunctions',
        # Non-fatal errors are intentionally swallowed so the script can continue.
        'PSAvoidUsingEmptyCatchBlock'
    )
}
