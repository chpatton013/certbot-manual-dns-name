# certbot-manual-dns-name

*Pseudo-plugin for cerbot DNS challenges for name.com using manual hooks*

## Summary

This repository provides authorization and cleanup hooks for use with
Let'sEncrypt's `certbot` in manual mode to make DNS-based ACME challenges for
domains registered through name.com.

"But why", I hear you plead, "wouldn't you just use the built-in RFC-2136 DNS
plugin that certbot already provides?"

Well, name.com does not implement RFC-2136. So there really is no other option
but to roll this myself.

### Usage

You must invoke certbot with the appropriate command-line flags to run in manual
mode and invoke these scripts during the challenge procedure.

You will also need to set some environment variables:
* `NAME_DNS_USERNAME`: (required) Name.com username for your account.
* `NAME_DNS_API_TOKEN`: (required) Name.com API token for this application.
* `NAME_DNS_PROPAGATION_TIME`: (optional) Change the maximum timeout of 1 week.
* `NAME_DNS_DEBUG`: (optional) Make requests against name.com's dev site.

```
export NAME_DNS_USERNAME=username
export NAME_DNS_API_TOKEN=api-token
certbot \
  certonly \
  --manual \
  --manual-auth-hook=.../certbot-manual-dns-name/auth-hook.sh \
  --manual-cleanup-hook=.../certbot-manual-dns-name/cleanup-hook.sh
  [...]
```

## License

`certbot-manual-dns-name` is licensed under the terms of the MIT License, as
described in [LICENSE.md](LICENSE.md).

## Contributing

Contributions are welcome in the form of bug reports, feature requests, or pull
requests.

Contribution to `certbot-manual-dns-name` is organized under the terms of the
[Contributor Covenant](CONTRIBUTOR_COVENANT.md).
