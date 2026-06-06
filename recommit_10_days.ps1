param(
    [int]$Days = 10,
    [string]$Branch = "recommit-10-days",
    [string]$AuthorName = "Recommitter",
    [string]$AuthorEmail = "recommitter@example.com"
)

# Ensure we're inside a git repository
git rev-parse --git-dir > $null 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "Not a git repository. Run this script from the repository root."
    exit 1
}

# Create and switch to branch
git checkout -b $Branch

$baseDate = Get-Date
for ($i = $Days; $i -ge 1; $i--) {
    $date = $baseDate.AddDays(-$i).ToString("yyyy-MM-ddTHH:mm:ssK")
    $env:GIT_AUTHOR_DATE = $date
    $env:GIT_COMMITTER_DATE = $date
    git commit --allow-empty --author="$AuthorName <$AuthorEmail>" -m "Recommit all files: $date"
    Remove-Item Env:\\GIT_AUTHOR_DATE -ErrorAction SilentlyContinue
    Remove-Item Env:\\GIT_COMMITTER_DATE -ErrorAction SilentlyContinue
}

# Show the new commits
git --no-pager log --oneline -n $Days
