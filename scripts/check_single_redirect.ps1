$headers = @{ 'api_access_token' = 'CDuFU9XcuoXTF7uHarDFWCw3' }
$url = 'http://192.168.29.71:3000/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBDZz09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--12a2a7064c5693190f9791b46c369f7f24b64fa8/WhatsApp%20Image%202025-12-09%20at%2013.56.28.jpeg'
$wr = Invoke-WebRequest -Uri $url -Headers $headers -MaximumRedirection 0 -ErrorAction SilentlyContinue
Write-Host "StatusCode: $($wr.StatusCode)"
Write-Host "Location: $($wr.Headers['Location'])"

