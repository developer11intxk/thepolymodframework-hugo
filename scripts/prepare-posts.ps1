# Prepare post leaf bundles for Hugo.
#
# Hugo bundles require the content file to be named index.md. Authored posts
# use the convention: content/posts/<node> <title>/post.md
#
# For each post.md this script:
#   1. copies it to index.md (assets in the folder become page resources)
#   2. injects a `date:` field derived from the `node:` front matter field
#      (YYYY-MM-DD-hh-mm-ss -> YYYY-MM-DDThh:mm:ss) if no date is present
#
# post.md is left in place so it can be committed; index.md is a build
# artifact and is git-ignored (see .gitignore). Run before `hugo` locally
# and in CI.

$ErrorActionPreference = 'Stop'

$postsRoot = Join-Path (Split-Path -Parent $PSScriptRoot) 'content\posts'
if (-not (Test-Path -LiteralPath $postsRoot)) {
    Write-Host 'No content/posts directory; nothing to prepare.'
    exit 0
}

$nodePattern = '(?m)^\s*node\s*:\s*["'']?(?<y>\d{4})-(?<mo>\d{2})-(?<d>\d{2})-(?<h>\d{2})-(?<mi>\d{2})-(?<s>\d{2})["'']?\s*$'
$datePattern = '(?m)^\s*date\s*:'
$frontMatterPattern = '(?m)^---\s*$'
$utf8 = New-Object System.Text.UTF8Encoding($false)

$prepared = 0
Get-ChildItem -LiteralPath $postsRoot -Recurse -Filter 'post.md' -File | ForEach-Object {
    $post = $_
    $dest = Join-Path $post.DirectoryName 'index.md'

    $content = [System.IO.File]::ReadAllText($post.FullName)
    $iso = $null

    if ($content -match $nodePattern) {
        $iso = '{0}-{1}-{2}T{3}:{4}:{5}' -f $Matches.y, $Matches.mo, $Matches.d, $Matches.h, $Matches.mi, $Matches.s
        if ($content -notmatch $datePattern) {
            $content = [regex]::Replace($content, $nodePattern, { param($m) "$($m.Value)`ndate: $iso" })
        }
    }
    elseif ($content -notmatch $datePattern) {
        $dirName = Split-Path -Leaf $post.DirectoryName
        if ($dirName -match '^(?<y>\d{4})-(?<mo>\d{2})-(?<d>\d{2})-(?<h>\d{2})-(?<mi>\d{2})-(?<s>\d{2})') {
            $iso = '{0}-{1}-{2}T{3}:{4}:{5}' -f $Matches.y, $Matches.mo, $Matches.d, $Matches.h, $Matches.mi, $Matches.s
            if ($content -match $frontMatterPattern) {
                $content = [regex]::Replace($content, $frontMatterPattern, { param($m) "---`ndate: $iso" }, 1)
            }
            else {
                $content = "date: $iso`n---`n$content"
            }
        }
    }

    [System.IO.File]::WriteAllText($dest, $content, $utf8)
    Write-Host "OK    $($post.FullName) -> index.md"
    $prepared++
}

Write-Host "Prepared $prepared post bundle(s)."
