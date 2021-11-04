# Converts the price of a crypto currency to USD, using the messari.io API
# Please note that the messari API enforces rate limits, see https://messari.io/api/docs

$coinID = $args[0]

$request = 'https://data.messari.io/api/v1/assets/' + $coinID + '/metrics'
$json = Invoke-WebRequest -UseBasicParsing $request | ConvertFrom-Json

if ($json.length -eq 0) {
	exit 1;
}

Write-Output $json.data.market_data.price_usd
