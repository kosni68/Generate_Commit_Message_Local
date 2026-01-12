# AI Commit Message Generator

A PowerShell utility that automatically generates professional git commit messages using AI, following the Conventional Commits format.

## Features

- **Automatic Commit Message Generation**: Uses an AI server to generate concise, professional commit messages based on your code changes
- **Conventional Commits Format**: Messages follow the standard format: `type(scope): description`
- **Git Integration**: Automatically stages changes if needed and analyzes the diff
- **Smart Prompting**: Includes detailed instructions to ensure consistent, professional commit messages

## Requirements

- PowerShell 5.1 or later
- Git installed and configured
- AI server running on `localhost:1234` with the [Tavernari/git-commit-message](https://huggingface.co/Tavernari/git-commit-message) model
- Windows operating system

## AI Model

This tool uses the **Tavernari/git-commit-message** model hosted on Hugging Face:
- **Model**: [Tavernari/git-commit-message](https://huggingface.co/Tavernari/git-commit-message)
- **Type**: Summarization model based on Qwen2
- **Purpose**: Specialized in generating meaningful git commit messages with reasoning
- **Features**: Analyzes diffs and generates structured commit messages following Conventional Commits format

The model can be run locally via Ollama or other inference servers for privacy and speed.

## Installation

1. Clone or download this repository
2. Place `ai-commit-paste.ps1` in your desired location
3. Ensure an AI server is running on `localhost:1234`

## Usage

Run the script from PowerShell:

```powershell
.\ai-commit-paste.ps1
```

### What the script does:

1. Checks for staged changes in git
2. If no staged changes exist, stages all modifications
3. Verifies that the AI server is running on `localhost:1234`
4. Sends the git diff to the AI server with a detailed prompt
5. Receives and processes the generated commit message

## Commit Message Format

Generated messages follow this convention:

- **Type**: `feat`, `fix`, `perf`, `build`, `refactor`, `style`, `docs`, `test`, etc.
- **Scope**: Optional component/feature in parentheses
- **Description**: Clear action in imperative mood (max 50 characters after type/scope)

### Examples:

- `feat(auth): add email notifications on login`
- `fix(payment): resolve credit card validation error`
- `refactor(api): simplify request handler logic`
- `docs(readme): update installation instructions`

## Requirements for AI Server

The AI server running on `localhost:1234` should:
- Accept POST/GET requests
- Take the provided prompt and git diff
- Return a properly formatted commit message
- Handle the Conventional Commits format

## Notes

- Messages use imperative mood ("add", "fix", "update")
- No personal pronouns in commit messages
- Professional and business-focused tone
- One clear action per commit message