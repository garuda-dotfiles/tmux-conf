# move-pane.ps1: psmux port of the C-S-h/j/k/l pane moves in tmux.conf.
# psmux refuses join-pane inside one window and has no `join-pane -b`, so the
# pane is broken out to its own window, joined next to the neighbour, and
# swapped with it when it has to land before (above/left of) the neighbour.
param([Parameter(Mandatory)][ValidateSet('L', 'D', 'U', 'R')][string]$Dir)

$panes = tmux list-panes -F '#{pane_id} #{pane_left} #{pane_top} #{pane_width} #{pane_height} #{pane_active}' |
    ForEach-Object {
        $f = $_ -split ' '
        [pscustomobject]@{ Id = $f[0]; L = [int]$f[1]; T = [int]$f[2]; R = [int]$f[1] + [int]$f[3] - 1; B = [int]$f[2] + [int]$f[4] - 1; Active = $f[5] -eq '1' }
    }
$cur = $panes | Where-Object Active | Select-Object -First 1
if (-not $cur) { exit 1 }
$others = $panes | Where-Object { $_.Id -ne $cur.Id }

$atLeft = $cur.L -eq ($panes | Measure-Object L -Minimum).Minimum
$atRight = $cur.R -eq ($panes | Measure-Object R -Maximum).Maximum
$atTop = $cur.T -eq ($panes | Measure-Object T -Minimum).Minimum
$atBottom = $cur.B -eq ($panes | Measure-Object B -Maximum).Maximum

# Neighbour across the 1-cell border, preferring the one beside the pane's top-left corner
function Get-Neighbour([string]$side) {
    $c = switch ($side) {
        'L' { $others | Where-Object { $_.R + 2 -eq $cur.L -and $_.T -le $cur.B -and $_.B -ge $cur.T } }
        'R' { $others | Where-Object { $_.L - 2 -eq $cur.R -and $_.T -le $cur.B -and $_.B -ge $cur.T } }
        'U' { $others | Where-Object { $_.B + 2 -eq $cur.T -and $_.L -le $cur.R -and $_.R -ge $cur.L } }
        'D' { $others | Where-Object { $_.T - 2 -eq $cur.B -and $_.L -le $cur.R -and $_.R -ge $cur.L } }
    }
    $best = $c | Where-Object { ($side -in 'L', 'R' -and $_.T -le $cur.T -and $_.B -ge $cur.T) -or ($side -in 'U', 'D' -and $_.L -le $cur.L -and $_.R -ge $cur.L) } | Select-Object -First 1
    if ($best) { $best } else { $c | Select-Object -First 1 }
}

# Join the current pane beside $target: -h side by side, else stacked; $before puts it above/left
function Join-To($target, [bool]$horizontal, [bool]$before) {
    if (-not $target) { return }
    tmux break-pane -d -s $cur.Id | Out-Null
    if ($horizontal) { tmux join-pane -h -s $cur.Id -t $target.Id | Out-Null }
    else { tmux join-pane -s $cur.Id -t $target.Id | Out-Null }
    if ($before) { tmux swap-pane -s $cur.Id -t $target.Id | Out-Null }
    tmux select-pane -t $cur.Id | Out-Null
}

$partialHeight = -not ($atTop -and $atBottom)
switch ($Dir) {
    'L' {
        if ($atLeft) { if ($partialHeight) { tmux display-message 'psmux: no full-height split (split-window -f)' } }
        else { Join-To (Get-Neighbour 'L') $false (-not $atBottom) }
    }
    'R' {
        if ($atRight) { if ($partialHeight) { tmux display-message 'psmux: no full-height split (split-window -f)' } }
        else { Join-To (Get-Neighbour 'R') $false (-not $atBottom) }
    }
    'D' {
        if ($atBottom) { if ($atTop -ne $atBottom) { Join-To (Get-Neighbour 'R') $false $atLeft } }
        else { Join-To (Get-Neighbour 'D') $true $atLeft }
    }
    'U' {
        if ($atTop) { if ($atTop -ne $atBottom) { Join-To (Get-Neighbour 'R') $false $atLeft } }
        else { Join-To (Get-Neighbour 'U') $true $atLeft }
    }
}
