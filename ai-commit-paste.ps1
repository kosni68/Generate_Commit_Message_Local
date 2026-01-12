Add-Type -AssemblyName System.Windows.Forms

# Initialize timing tracking
$script:startTime = Get-Date
$script:lastTime = $script:startTime

function LogTime($message) {
    $currentTime = Get-Date
    $elapsedTotal = ($currentTime - $script:startTime).TotalMilliseconds
    $elapsedSinceLast = ($currentTime - $script:lastTime).TotalMilliseconds
    Write-Host "[⏱️ +${elapsedSinceLast}ms | Total: ${elapsedTotal}ms] $message" -ForegroundColor Cyan
    $script:lastTime = $currentTime
}

Write-Host "Starting AI Commit Paste script"
LogTime "Script initialized"

# Get staged diff
$diff = git diff --cached
LogTime "Git diff --cached completed"
if ([string]::IsNullOrWhiteSpace($diff)) {
    Write-Host "No staged changes found, staging all modifications..."
    git add .
    LogTime "Git add . completed"
    $diff = git diff --cached
    LogTime "Second git diff --cached completed"
    if ([string]::IsNullOrWhiteSpace($diff)) {
        Write-Host "No modifications to stage." -ForegroundColor Yellow
        exit 1
    }
    Write-Host "Changes staged successfully" -ForegroundColor Green
}

Write-Host "Staged diff retrieved, length: $($diff.Length)"
LogTime "Diff retrieval completed"

# Test if AI server is running - fast TCP check
$tcpClient = New-Object System.Net.Sockets.TcpClient
$tcpClient.ConnectAsync("127.0.0.1", 1234).Wait(500) | Out-Null
$serverRunning = $tcpClient.Connected
$tcpClient.Close()

if (!$serverRunning) {
    Write-Host "AI server not running on localhost:1234." -ForegroundColor Red
    exit 1
}

Write-Host "AI server is running"
LogTime "AI server connection verified"

$prompt = @"
You are a senior software engineer.
Generate a concise git commit message from the following diff using Conventional Commits format.

Format: type(scope): description
- type: feat, fix, perf, build, refactor, style, docs, test, etc.
- scope: optional, the affected component/feature in parentheses
- description: what changed (max 50 characters after "type(scope): ")

Rules:
- Imperative mood (e.g., "add", "fix", "update", not "added" or "fixes")
- Start with lowercase after the colon
- No period at the end
- Be specific: mention the component/feature being changed
- Use only standard types: feat, fix, perf, build, refactor, style, docs, test
- No personal pronouns (I, we, you)
- One clear action per commit message
- Professional and business-focused tone
- Include scope when applicable

Examples:
- feat(auth): add email notifications on login
- fix(shopping-cart): prevent order of empty cart
- perf(api): optimize database query performance
- refactor(core): simplify state management
- style(ui): remove extra whitespace
- build: update dependencies

Git diff:
$diff
"@

Write-Host "Prompt created for AI"
LogTime "Prompt creation completed"

$body = @{
    model = "local-model"
    messages = @(
        @{ role = "system"; content = "You generate git commit messages." }
        @{ role = "user"; content = $prompt }
    )
    temperature = 0.2
} | ConvertTo-Json -Depth 5

Write-Host "Request body prepared"
LogTime "Request body serialization completed"

# Save body to temp file to avoid curl parsing issues with JSON dashes
$tempFile = [System.IO.Path]::GetTempFileName()
$body | Out-File -FilePath $tempFile -Encoding UTF8 -NoNewline

# Use curl for faster performance
$curlResponse = curl.exe -s -X POST `
    -H "Content-Type: application/json" `
    -d "@$tempFile" `
    "http://localhost:1234/v1/chat/completions"

# Clean up temp file
Remove-Item -Path $tempFile -Force

Write-Host "Response received from AI"
LogTime "AI API request completed (THIS IS THE SLOWEST PART)"

# Parse JSON response
$response = $curlResponse | ConvertFrom-Json
$message = $response.choices[0].message.content.Trim()

Write-Host "Commit message generated: $message"
LogTime "Message extraction completed"

# Put message into clipboard
Set-Clipboard -Value $message

Write-Host "Message copied to clipboard"
LogTime "Clipboard copy completed"

# Small delay to ensure clipboard is ready (reduced from 300ms to 50ms)
Start-Sleep -Milliseconds 50
LogTime "Sleep delay completed"

# Simulate Ctrl+V
[System.Windows.Forms.SendKeys]::SendWait("^v")

Write-Host "Paste simulated"
LogTime "Paste simulation completed"

# Final timing summary
$totalTime = ((Get-Date) - $script:startTime).TotalMilliseconds
Write-Host "`n========== TIMING SUMMARY ==========" -ForegroundColor Yellow
Write-Host "Total execution time: ${totalTime}ms" -ForegroundColor Yellow
Write-Host "===================================`n" -ForegroundColor Yellow
