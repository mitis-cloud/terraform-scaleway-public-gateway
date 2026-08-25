# Changelog

All notable changes to this module are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2026-08-25

### Fixed

- `allowed_ip_ranges` is now omitted when empty rather than sent as an explicit empty
  list. Previously an unset variable cleared Scaleway's default `0.0.0.0/0` rule and
  silently restricted the bastion.

## [1.0.0] - 2026-08-25

### Added

- Initial release. See README.
