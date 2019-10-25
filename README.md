# certbot-manual-dns-name

*Pseudo plugin for cerbot DNS challenges using manual hooks*

## Summary

This repository provides authorization and cleanup hooks for use with
Let'sEncrypt's `certbot` in manual mode.

### Usage

```
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
