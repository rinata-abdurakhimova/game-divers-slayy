param(
    [switch]$RequireGodot,
    [string]$GodotPath = $env:GODOT_EXE
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$failures = [System.Collections.Generic.List[string]]::new()
$warnings = [System.Collections.Generic.List[string]]::new()

function Add-Failure([string]$Message) {
    $failures.Add($Message)
    Write-Host "[FAIL] $Message" -ForegroundColor Red
}

function Add-Pass([string]$Message) {
    Write-Host "[PASS] $Message" -ForegroundColor Green
}

function Add-Warning([string]$Message) {
    $warnings.Add($Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

Push-Location $repoRoot
try {
    $requiredFiles = @(
        "AGENTS.md",
        "ARCHITECTURE.md",
        "INTEGRATION_CONTRACT.md",
        "OWNERSHIP.md",
        "docs/QA_BOT_WORKFLOW.md"
    )

    foreach ($path in $requiredFiles) {
        if (Test-Path -LiteralPath $path -PathType Leaf) {
            Add-Pass "Found $path"
        } else {
            Add-Failure "Missing required file: $path"
        }
    }

    $contract = if (Test-Path "INTEGRATION_CONTRACT.md") {
        Get-Content "INTEGRATION_CONTRACT.md" -Raw
    } else {
        ""
    }

    foreach ($token in @(
        "player_died",
        "health_changed",
        "score_changed",
        "level_completed",
        "game_over",
        "restart_requested"
    )) {
        if ($contract -notmatch [regex]::Escape($token)) {
            Add-Failure "Integration contract is missing '$token'"
        }
    }

    $skillFiles = @(Get-ChildItem ".agents/skills" -Filter "SKILL.md" -Recurse -File -ErrorAction SilentlyContinue)
    if ($skillFiles.Count -lt 6) {
        Add-Failure "Expected at least six repository skills; found $($skillFiles.Count)"
    } else {
        Add-Pass "Found $($skillFiles.Count) repository skills"
    }

    foreach ($skillFile in $skillFiles) {
        $skillText = Get-Content $skillFile.FullName -Raw
        if ($skillText -notmatch "(?s)^---\s*\r?\nname:\s*[a-z0-9-]+\s*\r?\ndescription:\s*.+?\r?\n---") {
            Add-Failure "Invalid skill frontmatter: $($skillFile.FullName)"
        }
        if ($skillText -match "\[TODO") {
            Add-Failure "Unresolved TODO in skill: $($skillFile.FullName)"
        }
    }

    $sourceExtensions = @(".gd", ".tscn", ".tres", ".godot", ".cfg", ".md", ".yml", ".yaml")
    $sourceFiles = Get-ChildItem -Recurse -File | Where-Object {
        $_.FullName -notmatch "[\\/]\.git[\\/]" -and
        $_.Extension -in $sourceExtensions
    }
    $mergeMarkers = @($sourceFiles | Select-String -Pattern "^(<<<<<<<|=======|>>>>>>>)" -ErrorAction SilentlyContinue)
    if ($mergeMarkers.Count -gt 0) {
        foreach ($marker in $mergeMarkers) {
            Add-Failure "Merge marker at $($marker.Path):$($marker.LineNumber)"
        }
    } else {
        Add-Pass "No unresolved merge markers"
    }

    if (Test-Path "project.godot" -PathType Leaf) {
        $godotExecutable = $null
        if (-not [string]::IsNullOrWhiteSpace($GodotPath) -and (Test-Path -LiteralPath $GodotPath -PathType Leaf)) {
            $godotExecutable = (Resolve-Path -LiteralPath $GodotPath).Path
        } else {
            $godot = Get-Command godot4, godot -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($null -ne $godot) {
                $godotExecutable = $godot.Source
            }
        }

        if ($null -eq $godotExecutable) {
            if ($RequireGodot) {
                Add-Failure "Godot is required but was not found on PATH"
            } else {
                Add-Warning "Godot not found; skipped headless boot"
            }
        } else {
            $qaLogDirectory = Join-Path $repoRoot ".godot_qa"
            New-Item -ItemType Directory -Path $qaLogDirectory -Force | Out-Null
            $qaLogPath = Join-Path $qaLogDirectory "headless-boot.log"
            Remove-Item -LiteralPath $qaLogPath -Force -ErrorAction SilentlyContinue
            & $godotExecutable --headless --log-file $qaLogPath --path $repoRoot --quit-after 3
            if ($LASTEXITCODE -ne 0) {
                Add-Failure "Godot headless boot failed with exit code $LASTEXITCODE"
            } else {
                $runtimeErrors = @()
                if (Test-Path -LiteralPath $qaLogPath -PathType Leaf) {
                    $runtimeErrors = @(
                        Get-Content -LiteralPath $qaLogPath |
                            Select-String -Pattern "SCRIPT ERROR:|Parse Error:|Failed to load script"
                    )
                }
                if ($runtimeErrors.Count -gt 0) {
                    foreach ($runtimeError in $runtimeErrors) {
                        Add-Failure "Godot runtime error: $($runtimeError.Line.Trim())"
                    }
                } else {
                    Add-Pass "Godot headless boot"
                }
            }
        }
    } else {
        Add-Warning "project.godot does not exist yet; skipped headless boot"
    }

    if ($failures.Count -gt 0) {
        Write-Host ""
        Write-Host "QA failed with $($failures.Count) issue(s)." -ForegroundColor Red
        exit 1
    }

    Write-Host ""
    Write-Host "QA passed with $($warnings.Count) warning(s)." -ForegroundColor Green
    exit 0
} finally {
    Pop-Location
}
