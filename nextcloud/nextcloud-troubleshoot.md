# Nextcloud Troubleshoot

### App Store Timeout
**3rdparty/guzzlehttp/guzzle/src/Handler/CurlFactory.php |** `line404`
> increase 1000 to 10000

**lib/private/App/AppStore/Fetcher/Fetcher.php |** `line 98` 
> change the timeout from 10 to 30 or 90

**lib/private/Http/Client.php |** `line 66` 
> change the timeout from 30 to 90

