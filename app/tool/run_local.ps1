# One-command local run. Uses live Supabase data when config.local.js has
# real keys, otherwise falls back to bundled sample data. Run from app/.
$cfg = Get-Content ..\config.local.js -Raw -ErrorAction SilentlyContinue
$url = ([regex]::Match("$cfg", 'SUPABASE_URL:\s*"([^"]+)"')).Groups[1].Value
$key = ([regex]::Match("$cfg", 'SUPABASE_ANON_KEY:\s*"([^"]+)"')).Groups[1].Value
if ($url -match "xyzcompany" -or [string]::IsNullOrWhiteSpace($url)) {
  Write-Output "No live keys - running on bundled sample data."
  flutter run -d chrome
} else {
  Write-Output "Live data connected."
  flutter run -d chrome --dart-define=SUPABASE_URL=$url --dart-define=SUPABASE_ANON_KEY=$key
}
