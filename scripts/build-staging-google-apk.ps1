param(
  [string]$ApiBaseUrl = "https://carenet-staging-mobile-gateway-2kbj9ok1.uc.gateway.dev",
  [string]$GoogleServerClientId = "",
  [string]$GoogleWebClientJson = ""
)

$ErrorActionPreference = "Stop"

function Get-WebClientIdFromJson {
  param([string]$Path)

  if (-not (Test-Path -LiteralPath $Path)) {
    throw "Google Web client JSON was not found: $Path"
  }

  $json = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
  $clientId = $json.web.client_id
  if ([string]::IsNullOrWhiteSpace($clientId)) {
    throw "The JSON file does not look like a Web OAuth client config. Expected web.client_id."
  }

  return $clientId
}

if ([string]::IsNullOrWhiteSpace($GoogleServerClientId) -and
    -not [string]::IsNullOrWhiteSpace($GoogleWebClientJson)) {
  $GoogleServerClientId = Get-WebClientIdFromJson -Path $GoogleWebClientJson
}

if ([string]::IsNullOrWhiteSpace($GoogleServerClientId)) {
  throw "Provide -GoogleServerClientId <web-client-id> or -GoogleWebClientJson <path-to-web-client-json>."
}

if ($GoogleServerClientId -notmatch '\.apps\.googleusercontent\.com$') {
  throw "GOOGLE_SIGN_IN_SERVER_CLIENT_ID must be a Google OAuth client ID."
}

flutter build apk --debug `
  --dart-define=CARENET_API_BASE_URL=$ApiBaseUrl `
  --dart-define=GOOGLE_SIGN_IN_SERVER_CLIENT_ID=$GoogleServerClientId
