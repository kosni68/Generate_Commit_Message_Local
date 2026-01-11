Add-Type -AssemblyName System.Windows.Forms

Write-Host "Starting AI Commit Paste script"

# Get staged diff
$diff = git diff --cached
if ([string]::IsNullOrWhiteSpace($diff)) {
    Write-Host "No staged changes found"
    Write-Host "No staged changes." -ForegroundColor Yellow
    exit 1
}

Write-Host "Staged diff retrieved, length: $($diff.Length)"

# Test if AI server is running
if (!(Test-NetConnection -ComputerName localhost -Port 1234 -InformationLevel Quiet)) {
    Write-Host "AI server not running on localhost:1234"
    Write-Host "AI server not running on localhost:1234." -ForegroundColor Red
    exit 1
}

Write-Host "AI server is running"

$prompt = @"
You are a senior software engineer.
Generate a concise git commit message from the following diff.

Rules:
- Imperative mood
- Max 72 characters
- No punctuation at the end
- Describe WHAT changed, not HOW

Git diff:
$diff
"@

Write-Host "Prompt created for AI"

$body = @{
    model = "local-model"
    messages = @(
        @{ role = "system"; content = "You generate git commit messages." }
        @{ role = "user"; content = $prompt }
    )
    temperature = 0.2
} | ConvertTo-Json -Depth 5

Write-Host "Request body prepared"

$response = Invoke-RestMethod `
    -Uri "http://localhost:1234/v1/chat/completions" `
    -Method POST `
    -Headers @{ "Content-Type" = "application/json" } `
    -Body $body

Write-Host "Response received from AI"

$message = $response.choices[0].message.content.Trim()

Write-Host "Commit message generated: $message"

# Put message into clipboard
Set-Clipboard -Value $message

Write-Host "Message copied to clipboard"

# Small delay to ensure clipboard is ready
Start-Sleep -Milliseconds 300

# Simulate Ctrl+V
[System.Windows.Forms.SendKeys]::SendWait("^v")

Write-Host "Paste simulated"
