#requires -Version 5.1
<# Rebuild the static homepage links after adding, editing, or removing HTML posts. #>
$ErrorActionPreference = 'Stop'

function Get-PostMeta([string] $Html, [string] $Name) {
    foreach ($tag in [regex]::Matches($Html, '<meta\b[^>]*>', 'IgnoreCase')) {
        $attributes = @{}
        foreach ($attribute in [regex]::Matches($tag.Value, '([\w-]+)\s*=\s*(["''])(.*?)\2', 'Singleline')) {
            $attributes[$attribute.Groups[1].Value] = [System.Net.WebUtility]::HtmlDecode($attribute.Groups[3].Value)
        }
        if ($attributes['name'] -eq $Name) { return $attributes['content'] }
    }
    return ''
}

$homepagePath = Join-Path $PSScriptRoot 'index.html'
$homepage = [IO.File]::ReadAllText($homepagePath)
$start = '<!-- BLOG-LIST:START -->'
$end = '<!-- BLOG-LIST:END -->'
if ([regex]::Matches($homepage, [regex]::Escape($start)).Count -ne 1 -or
    [regex]::Matches($homepage, [regex]::Escape($end)).Count -ne 1 -or
    $homepage.IndexOf($start) -gt $homepage.IndexOf($end)) {
    throw 'index.html must contain exactly one ordered pair of BLOG-LIST markers.'
}

$posts = @(Get-ChildItem -LiteralPath (Join-Path $PSScriptRoot 'blogs') -File |
    Where-Object Extension -eq '.html' | ForEach-Object {
        $html = [IO.File]::ReadAllText($_.FullName)
        $title = Get-PostMeta $html 'blog-title'
        if (!$title) {
            $match = [regex]::Match($html, '<title\b[^>]*>(.*?)</title>', 'IgnoreCase,Singleline')
            $title = [System.Net.WebUtility]::HtmlDecode(($match.Groups[1].Value -split ' \| ')[0].Trim())
        }
        if (!$title) { $title = $_.BaseName }
        $date = Get-PostMeta $html 'blog-date'
        if ($date) {
            $null = [datetime]::ParseExact($date, 'yyyy-MM-dd', [cultureinfo]::InvariantCulture)
        }
        [pscustomobject]@{
            Title = $title
            Date = $date
            Published = Get-PostMeta $html 'blog-published'
            Filename = $_.Name
        }
    } | Sort-Object -Property Date, Published, Filename -Descending)

$lines = @('        <ul class="blog-list">')
foreach ($post in $posts) {
    $title = [System.Net.WebUtility]::HtmlEncode($post.Title)
    $url = [uri]::EscapeDataString($post.Filename)
    $stamp = ''
    if ($post.Date) {
        $stamp = ' <time class="post-date" datetime="{0}">{0}</time>' -f $post.Date
    }
    $lines += '          <li><a href="blogs/{0}">{1}</a>{2}</li>' -f $url, $title, $stamp
}
$lines += '        </ul>'
if (!$posts.Count) { $lines += '        <p>No posts yet.</p>' }
$replacement = $start + "`n" + ($lines -join "`n") + "`n        " + $end
$pattern = [regex]::Escape($start) + '[\s\S]*?' + [regex]::Escape($end)
$updated = [regex]::Replace($homepage, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($match) $replacement })
[IO.File]::WriteAllText($homepagePath, $updated, [Text.UTF8Encoding]::new($false))
Write-Host "Updated homepage with $($posts.Count) blog post(s)."
