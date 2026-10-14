#requires -Version 5.1
<# Convert a Markdown file to a dated HTML post and update the homepage. #>
param(
    [Parameter(Mandatory, Position = 0)]
    [string] $MarkdownFile
)
$ErrorActionPreference = 'Stop'

# The familiar Windows PowerShell prompt can launch the newer Markdown engine.
if ($PSVersionTable.PSVersion.Major -lt 7) {
    $command = Get-Command pwsh -ErrorAction SilentlyContinue
    $candidates = @(
        $(if ($command) { $command.Source }),
        (Join-Path $env:ProgramFiles 'PowerShell\7\pwsh.exe'),
        (Join-Path $env:USERPROFILE '.cache\codex-runtimes\codex-primary-runtime\dependencies\native\powershell\pwsh.exe')
    )
    $engine = $candidates | Where-Object { $_ -and (Test-Path -LiteralPath $_ -PathType Leaf) } | Select-Object -First 1
    if (!$engine) {
        throw 'PowerShell 7 is needed to convert Markdown. Install it, then run this same command again: winget install --id Microsoft.PowerShell --source winget'
    }
    & $engine -NoProfile -File $PSCommandPath -MarkdownFile $MarkdownFile
    if ($LASTEXITCODE -ne 0) { throw "Publishing failed in PowerShell 7 (exit code $LASTEXITCODE)." }
    return
}

$source = Get-Item -LiteralPath $MarkdownFile
if ($source.PSIsContainer -or $source.Extension -notin '.md', '.markdown') {
    throw 'Provide a Markdown file (.md or .markdown).'
}
$title = $source.BaseName
$markdown = [IO.File]::ReadAllText($source.FullName)
$body = (ConvertFrom-Markdown -InputObject $markdown).Html
$now = Get-Date
$date = $now.ToString('yyyy-MM-dd', [cultureinfo]::InvariantCulture)
$published = $now.ToUniversalTime().ToString('o', [cultureinfo]::InvariantCulture)
$displayDate = $now.ToString('MMMM d, yyyy', [cultureinfo]::GetCultureInfo('en-US'))

# Keep the visible title exactly as named; make only the URL filesystem-friendly.
$slug = [regex]::Replace($title.ToLowerInvariant(), '[^\p{L}\p{Nd}]+', '-').Trim('-')
if (!$slug) { $slug = 'post' }
if ($slug.Length -gt 100) { $slug = $slug.Substring(0, 100).TrimEnd('-') }
$blogs = Join-Path $PSScriptRoot 'blogs'
$null = New-Item -ItemType Directory -Force -Path $blogs
$filename = "$date-$slug.html"
$outputPath = Join-Path $blogs $filename
$suffix = 2
while (Test-Path -LiteralPath $outputPath) {
    $filename = "$date-$slug-$suffix.html"
    $outputPath = Join-Path $blogs $filename
    $suffix++
}

$template = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'templates/blog-post.html'))
$values = @{
    TITLE = [System.Net.WebUtility]::HtmlEncode($title)
    DATE = $date
    PUBLISHED = $published
    DISPLAY_DATE = $displayDate
    BODY = $body
}
# One substitution pass keeps literal template-like text in a post intact.
$html = [regex]::Replace($template, '\{\{(TITLE|DATE|PUBLISHED|DISPLAY_DATE|BODY)\}\}',
    [System.Text.RegularExpressions.MatchEvaluator]{ param($match) $values[$match.Groups[1].Value] })
[IO.File]::WriteAllText($outputPath, $html, [Text.UTF8Encoding]::new($false))
& (Join-Path $PSScriptRoot 'Update-BlogIndex.ps1')
Write-Host "Created $outputPath"
Write-Host 'Ready to preview. Commit and push when you want to put it online.'
