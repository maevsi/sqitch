## [2.0.0-beta.4](https://github.com/maevsi/sqitch/compare/2.0.0-beta.3...2.0.0-beta.4) (2023-09-26)


### Features

* **sql:** use uuids instead of ids ([277ec7f](https://github.com/maevsi/sqitch/commit/277ec7f759075395aaf507f45b1d294092b35c31))

## [2.0.0-beta.3](https://github.com/maevsi/sqitch/compare/2.0.0-beta.2...2.0.0-beta.3) (2023-09-26)


### ⚠ BREAKING CHANGES

* **contact:** use `E.164` phone number format
* **email:** shorten and loosen format

### Features

* **contact:** use `E.164` phone number format ([92ac35d](https://github.com/maevsi/sqitch/commit/92ac35d22795f5ec8a1861c94a151bf76c735949))
* **email:** shorten and loosen format ([9e6c62b](https://github.com/maevsi/sqitch/commit/9e6c62b8bf592bec1c657215b3f7ffc930217fc0))

## [2.0.0-beta.2](https://github.com/maevsi/sqitch/compare/2.0.0-beta.1...2.0.0-beta.2) (2023-09-19)


### ⚠ BREAKING CHANGES

* **docker:** mount entrypoint

### Features

* **docker:** mount entrypoint ([2572193](https://github.com/maevsi/sqitch/commit/25721933e677297ddf2af6d3f19e0ca0190887ab))

## [2.0.0-beta.1](https://github.com/maevsi/sqitch/compare/1.17.11...2.0.0-beta.1) (2023-09-14)


### ⚠ BREAKING CHANGES

* remove email address case restriction

### Features

* remove email address case restriction ([41e7eee](https://github.com/maevsi/sqitch/commit/41e7eeebff7482361f648a6e7ace53deaeab328f))

## [1.17.11](https://github.com/maevsi/sqitch/compare/1.17.10...1.17.11) (2023-09-09)


### Bug Fixes

* schedule release ([3c95c24](https://github.com/maevsi/sqitch/commit/3c95c24f7cb7526b95c1e9ad6a4bad1ea768efa7))

## [1.17.10](https://github.com/maevsi/sqitch/compare/1.17.9...1.17.10) (2023-08-26)


### Bug Fixes

* **docker:** correct production environment variable ([db4f23f](https://github.com/maevsi/sqitch/commit/db4f23f02afbbf3ca6b36c6f65abcc31f02ebb50))

## [1.17.9](https://github.com/maevsi/sqitch/compare/1.17.8...1.17.9) (2023-08-26)


### Bug Fixes

* **docker:** correct `target` secret name ([bbdb6c6](https://github.com/maevsi/sqitch/commit/bbdb6c66203f2989fd0699338ce2912e1a8f070a))

## [1.17.8](https://github.com/maevsi/sqitch/compare/1.17.7...1.17.8) (2023-08-26)


### Bug Fixes

* schedule release ([a55e664](https://github.com/maevsi/sqitch/commit/a55e6642d60d0474407dd37ba3a1fdd6d18ff583))

## [1.17.7](https://github.com/maevsi/sqitch/compare/1.17.6...1.17.7) (2023-08-12)


### Bug Fixes

* schedule release ([5eae41f](https://github.com/maevsi/sqitch/commit/5eae41f8593fa5dcad2c53c6e478a0745cb12a20))

## [1.17.6](https://github.com/maevsi/sqitch/compare/1.17.5...1.17.6) (2023-07-29)


### Bug Fixes

* schedule release ([c5d196e](https://github.com/maevsi/sqitch/commit/c5d196e1def3a4ea5e2280d1201ed1fc63be7af5))

## [1.17.5](https://github.com/maevsi/sqitch/compare/1.17.4...1.17.5) (2023-07-15)


### Bug Fixes

* schedule release ([6ca3111](https://github.com/maevsi/sqitch/commit/6ca3111a0a9c5f16bbbf4df59586ac8ac732c021))

## [1.17.4](https://github.com/maevsi/sqitch/compare/1.17.3...1.17.4) (2023-07-01)


### Bug Fixes

* schedule release ([8337009](https://github.com/maevsi/sqitch/commit/83370099dd1f420e659257c0a6aefcd4259e0438))

## [1.17.3](https://github.com/maevsi/sqitch/compare/1.17.2...1.17.3) (2023-06-23)


### Bug Fixes

* **contact:** account for null in inequality check ([7a0873e](https://github.com/maevsi/sqitch/commit/7a0873e0bfee8e66a2c44b33c309cff5ef23ae9e))

## [1.17.2](https://github.com/maevsi/sqitch/compare/1.17.1...1.17.2) (2023-06-10)


### Bug Fixes

* schedule release ([1ee2e3a](https://github.com/maevsi/sqitch/commit/1ee2e3afc444b9053f35643f440420f12e1a8b91))

## [1.17.1](https://github.com/maevsi/sqitch/compare/1.17.0...1.17.1) (2023-05-29)


### Bug Fixes

* schedule release ([9037d37](https://github.com/maevsi/sqitch/commit/9037d3770691a0ccb1b076097a2d83723876ed4b))

# [1.17.0](https://github.com/maevsi/sqitch/compare/1.16.0...1.17.0) (2023-05-15)


### Bug Fixes

* **docker:** correct copy sources ([80f336e](https://github.com/maevsi/sqitch/commit/80f336e8b18359c89cf93ad8ba37471ac8def5c6))
* **dump:** remove version comments ([9bd4bb0](https://github.com/maevsi/sqitch/commit/9bd4bb0762483b879ef28c640becb927714727e4))
* **package:** add name ([69501dd](https://github.com/maevsi/sqitch/commit/69501dddf18a0ef8717b4c3a69e3ec5658151327))
* **schema-update:** correct docker context directory ([18c62d4](https://github.com/maevsi/sqitch/commit/18c62d45f981e00293e909ad083851911e5c8755))
* **sqitch:** add docker entrypoint ([6cc8e2b](https://github.com/maevsi/sqitch/commit/6cc8e2b0e515551b7ea7d88accbb93218e9f6426))
* **sqitch:** correct schema update script ([f9d0650](https://github.com/maevsi/sqitch/commit/f9d065086cc2d8029dcba0bcb6842afcab694f13))
* **sqitch:** let docker sleep indefinetly ([fb55be9](https://github.com/maevsi/sqitch/commit/fb55be9ecc1f011d680100040f5d4f6f52ae5551))
* **sql:** disallow deleting contact assigned to own account ([d2acdaf](https://github.com/maevsi/sqitch/commit/d2acdaff40351b505931b5c6ab785a1baf7bbd52))


### Features

* setup own repository ([c8ab8dd](https://github.com/maevsi/sqitch/commit/c8ab8dd56844698e897796af797001de92f8cc86))

# [1.17.0-beta.1](https://github.com/maevsi/sqitch/compare/1.16.0...1.17.0-beta.1) (2023-05-14)


### Bug Fixes

* **docker:** correct copy sources ([80f336e](https://github.com/maevsi/sqitch/commit/80f336e8b18359c89cf93ad8ba37471ac8def5c6))
* **dump:** remove version comments ([9bd4bb0](https://github.com/maevsi/sqitch/commit/9bd4bb0762483b879ef28c640becb927714727e4))
* **package:** add name ([69501dd](https://github.com/maevsi/sqitch/commit/69501dddf18a0ef8717b4c3a69e3ec5658151327))
* **schema-update:** correct docker context directory ([18c62d4](https://github.com/maevsi/sqitch/commit/18c62d45f981e00293e909ad083851911e5c8755))
* **sqitch:** add docker entrypoint ([6cc8e2b](https://github.com/maevsi/sqitch/commit/6cc8e2b0e515551b7ea7d88accbb93218e9f6426))
* **sqitch:** correct schema update script ([f9d0650](https://github.com/maevsi/sqitch/commit/f9d065086cc2d8029dcba0bcb6842afcab694f13))
* **sqitch:** let docker sleep indefinetly ([fb55be9](https://github.com/maevsi/sqitch/commit/fb55be9ecc1f011d680100040f5d4f6f52ae5551))
* **sql:** disallow deleting contact assigned to own account ([d2acdaf](https://github.com/maevsi/sqitch/commit/d2acdaff40351b505931b5c6ab785a1baf7bbd52))


### Features

* setup own repository ([c8ab8dd](https://github.com/maevsi/sqitch/commit/c8ab8dd56844698e897796af797001de92f8cc86))

# [1.17.0-beta.1](https://github.com/maevsi/sqitch/compare/1.16.0...1.17.0-beta.1) (2023-05-14)


### Bug Fixes

* **docker:** correct copy sources ([80f336e](https://github.com/maevsi/sqitch/commit/80f336e8b18359c89cf93ad8ba37471ac8def5c6))
* **dump:** remove version comments ([9bd4bb0](https://github.com/maevsi/sqitch/commit/9bd4bb0762483b879ef28c640becb927714727e4))
* **package:** add name ([69501dd](https://github.com/maevsi/sqitch/commit/69501dddf18a0ef8717b4c3a69e3ec5658151327))
* **schema-update:** correct docker context directory ([18c62d4](https://github.com/maevsi/sqitch/commit/18c62d45f981e00293e909ad083851911e5c8755))
* **sqitch:** add docker entrypoint ([6cc8e2b](https://github.com/maevsi/sqitch/commit/6cc8e2b0e515551b7ea7d88accbb93218e9f6426))
* **sqitch:** correct schema update script ([f9d0650](https://github.com/maevsi/sqitch/commit/f9d065086cc2d8029dcba0bcb6842afcab694f13))
* **sqitch:** let docker sleep indefinetly ([fb55be9](https://github.com/maevsi/sqitch/commit/fb55be9ecc1f011d680100040f5d4f6f52ae5551))
* **sql:** disallow deleting contact assigned to own account ([d2acdaf](https://github.com/maevsi/sqitch/commit/d2acdaff40351b505931b5c6ab785a1baf7bbd52))


### Features

* setup own repository ([c8ab8dd](https://github.com/maevsi/sqitch/commit/c8ab8dd56844698e897796af797001de92f8cc86))
