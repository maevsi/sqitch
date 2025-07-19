## [9.5.1](https://github.com/maevsi/sqitch/compare/9.5.0...9.5.1) (2025-07-19)

### Bug Fixes

* schedule release ([45f6435](https://github.com/maevsi/sqitch/commit/45f6435e66cac829688f8d3ab71a41a4995a09a2))

## [9.5.0](https://github.com/maevsi/sqitch/compare/9.4.1...9.5.0) (2025-07-10)

### Features

* **account:** allow unblock ([ede85eb](https://github.com/maevsi/sqitch/commit/ede85ebdd11f21f8fe7d81dc522a78cf248434c8))

## [9.4.1](https://github.com/maevsi/sqitch/compare/9.4.0...9.4.1) (2025-07-09)

### Bug Fixes

* **account:** disallow selecting blocked ([c31ea39](https://github.com/maevsi/sqitch/commit/c31ea39547e360a5baf17a4b9e7a656904e8c51a))

## [9.4.0](https://github.com/maevsi/sqitch/compare/9.3.0...9.4.0) (2025-07-09)

### Features

* **account:** drop event check from deletion ([506e018](https://github.com/maevsi/sqitch/commit/506e01823886653073278d2b64ca8377d6b1a6f1))

## [9.3.0](https://github.com/maevsi/sqitch/compare/9.2.0...9.3.0) (2025-07-09)

### Features

* **account:** specify unicode collation for username ([3c45a32](https://github.com/maevsi/sqitch/commit/3c45a323acbd31f5e364dbe339b442835f6aa82d))

## [9.2.0](https://github.com/maevsi/sqitch/compare/9.1.1...9.2.0) (2025-06-28)

### Features

* **account:** correct comment and policy permissions ([648fe40](https://github.com/maevsi/sqitch/commit/648fe402f5a39005d512612e70b4b3ba4b0e69b2))

## [9.1.1](https://github.com/maevsi/sqitch/compare/9.1.0...9.1.1) (2025-06-21)

### Bug Fixes

* schedule release ([c6c99dc](https://github.com/maevsi/sqitch/commit/c6c99dce2943f12bccd99369af554b8b10d0d3ad))

## [9.1.0](https://github.com/maevsi/sqitch/compare/9.0.0...9.1.0) (2025-06-13)

### Features

* **event-favorite:** grant select for anonymous ([84ce920](https://github.com/maevsi/sqitch/commit/84ce9204127f4a2aef4dd07d3c9d8a9bfcb17380))

## [9.0.0](https://github.com/maevsi/sqitch/compare/8.4.0...9.0.0) (2025-06-06)

### ⚠ BREAKING CHANGES

* **preference:** disallow columns to be null for size
* **account:** require birth date in registration
* **account:** remove birth date update function
* **notification:** grant read access to grafana
* **preference:** add id
* cleanup comments and formatting
* **account:** only allow birth dates that are at least 18 years old
* **event:** disallow null id for favorite
* add missing smart comment prefix
* **preference:** simplify naming
* specify function arguments for revert
* **event:** disable endpoints for category and format

### Features

* **account:** only allow birth dates that are at least 18 years old ([3114191](https://github.com/maevsi/sqitch/commit/3114191b4f315be6b49b36015d6df40d49bf246d))
* **account:** remove birth date update function ([f59486f](https://github.com/maevsi/sqitch/commit/f59486fb91a472cb981fe8aa9bd3a1d6561f8046))
* **account:** require birth date in registration ([a76b182](https://github.com/maevsi/sqitch/commit/a76b182aab14e2d14e3d0fc9a28d84f211034dc4))
* **event:** disable endpoints for category and format ([8c1764a](https://github.com/maevsi/sqitch/commit/8c1764aa4b5963af9b12ee187cf14a6b2507c6d5))
* **notification:** grant read access to grafana ([6a5bd96](https://github.com/maevsi/sqitch/commit/6a5bd96f79538d2f7eb14bea3570fd756ce0cacc))
* **preference:** add id ([786a8d3](https://github.com/maevsi/sqitch/commit/786a8d38940a8b6989a342e97711bbed54e2ceab))
* **preference:** simplify naming ([04115fd](https://github.com/maevsi/sqitch/commit/04115fdca95422ba29cd6d8a083e0a1a72c4d6c1))

### Bug Fixes

* add missing smart comment prefix ([3c78d9a](https://github.com/maevsi/sqitch/commit/3c78d9a6affb0a4846e3f71fda5b77de1420a811))
* **event:** disallow null id for favorite ([bb882a1](https://github.com/maevsi/sqitch/commit/bb882a1d649031e1bf775c9482b27ed2c0ab8ae1))
* **preference:** disallow columns to be null for size ([35807d2](https://github.com/maevsi/sqitch/commit/35807d2838080716947b21f20d971b75409656e4))

### Miscellaneous Chores

* cleanup comments and formatting ([1e5d667](https://github.com/maevsi/sqitch/commit/1e5d667d156010d457399c41403d5bee17c30c0d))
* specify function arguments for revert ([bb96980](https://github.com/maevsi/sqitch/commit/bb9698049291f6be8f784a7569270ec6e3526236))

## [9.0.0-beta.10](https://github.com/maevsi/sqitch/compare/9.0.0-beta.9...9.0.0-beta.10) (2025-06-06)

### ⚠ BREAKING CHANGES

* **preference:** disallow columns to be null for size

### Bug Fixes

* **preference:** disallow columns to be null for size ([35807d2](https://github.com/maevsi/sqitch/commit/35807d2838080716947b21f20d971b75409656e4))

## [9.0.0-beta.9](https://github.com/maevsi/sqitch/compare/9.0.0-beta.8...9.0.0-beta.9) (2025-06-02)

### ⚠ BREAKING CHANGES

* **account:** require birth date in registration
* **account:** remove birth date update function

### Features

* **account:** remove birth date update function ([f59486f](https://github.com/maevsi/sqitch/commit/f59486fb91a472cb981fe8aa9bd3a1d6561f8046))
* **account:** require birth date in registration ([a76b182](https://github.com/maevsi/sqitch/commit/a76b182aab14e2d14e3d0fc9a28d84f211034dc4))

## [9.0.0-beta.8](https://github.com/maevsi/sqitch/compare/9.0.0-beta.7...9.0.0-beta.8) (2025-06-02)

### ⚠ BREAKING CHANGES

* **notification:** grant read access to grafana

### Features

* **notification:** grant read access to grafana ([6a5bd96](https://github.com/maevsi/sqitch/commit/6a5bd96f79538d2f7eb14bea3570fd756ce0cacc))

## [9.0.0-beta.7](https://github.com/maevsi/sqitch/compare/9.0.0-beta.6...9.0.0-beta.7) (2025-05-27)

### ⚠ BREAKING CHANGES

* **preference:** add id

### Features

* **preference:** add id ([786a8d3](https://github.com/maevsi/sqitch/commit/786a8d38940a8b6989a342e97711bbed54e2ceab))

## [9.0.0-beta.6](https://github.com/maevsi/sqitch/compare/9.0.0-beta.5...9.0.0-beta.6) (2025-05-27)

### ⚠ BREAKING CHANGES

* cleanup comments and formatting

### Miscellaneous Chores

* cleanup comments and formatting ([1e5d667](https://github.com/maevsi/sqitch/commit/1e5d667d156010d457399c41403d5bee17c30c0d))

## [9.0.0-beta.5](https://github.com/maevsi/sqitch/compare/9.0.0-beta.4...9.0.0-beta.5) (2025-05-27)

### ⚠ BREAKING CHANGES

* **account:** only allow birth dates that are at least 18 years old

### Features

* **account:** only allow birth dates that are at least 18 years old ([3114191](https://github.com/maevsi/sqitch/commit/3114191b4f315be6b49b36015d6df40d49bf246d))

## [9.0.0-beta.4](https://github.com/maevsi/sqitch/compare/9.0.0-beta.3...9.0.0-beta.4) (2025-05-27)

### Features

* **account:** add birth date setter function ([1ec9e33](https://github.com/maevsi/sqitch/commit/1ec9e33ceebae5670dfb8d1bc777f09ba31affd0))
* **account:** add location setter function ([531335c](https://github.com/maevsi/sqitch/commit/531335c4a0276f2271e95071c04341cbaa4b9f06))
* **preference:** add location ([2c2d5dc](https://github.com/maevsi/sqitch/commit/2c2d5dc0b11027edb97cbc4c95f150fc2d64726a))
* **zammad:** create database and role ([1565f57](https://github.com/maevsi/sqitch/commit/1565f575277da81aa79edad5f8adea454916e2e1))

### Bug Fixes

* revert "Merge pull request [#211](https://github.com/maevsi/sqitch/issues/211) from maevsi/feat/zammad/db" ([f71fa5b](https://github.com/maevsi/sqitch/commit/f71fa5bec07d14b36a34fd9ec3559aac67547750))

## [9.0.0-beta.3](https://github.com/maevsi/sqitch/compare/9.0.0-beta.2...9.0.0-beta.3) (2025-05-26)

### ⚠ BREAKING CHANGES

* **event:** disallow null id for favorite

### Bug Fixes

* **event:** disallow null id for favorite ([bb882a1](https://github.com/maevsi/sqitch/commit/bb882a1d649031e1bf775c9482b27ed2c0ab8ae1))

## [9.0.0-beta.2](https://github.com/maevsi/sqitch/compare/9.0.0-beta.1...9.0.0-beta.2) (2025-05-20)

### ⚠ BREAKING CHANGES

* **preference:** simplify naming
* **event:** disable endpoints for category and format

### Features

* **event:** disable endpoints for category and format ([8c1764a](https://github.com/maevsi/sqitch/commit/8c1764aa4b5963af9b12ee187cf14a6b2507c6d5))
* **preference:** simplify naming ([04115fd](https://github.com/maevsi/sqitch/commit/04115fdca95422ba29cd6d8a083e0a1a72c4d6c1))

## [9.0.0-beta.1](https://github.com/maevsi/sqitch/compare/8.0.1...9.0.0-beta.1) (2025-05-20)

### ⚠ BREAKING CHANGES

* add missing smart comment prefix
* specify function arguments for revert

### Bug Fixes

* add missing smart comment prefix ([3c78d9a](https://github.com/maevsi/sqitch/commit/3c78d9a6affb0a4846e3f71fda5b77de1420a811))

### Miscellaneous Chores

* specify function arguments for revert ([bb96980](https://github.com/maevsi/sqitch/commit/bb9698049291f6be8f784a7569270ec6e3526236))

## [8.4.0](https://github.com/maevsi/sqitch/compare/8.3.1...8.4.0) (2025-05-27)

### Features

* **preference:** add location ([2c2d5dc](https://github.com/maevsi/sqitch/commit/2c2d5dc0b11027edb97cbc4c95f150fc2d64726a))

## [8.3.1](https://github.com/maevsi/sqitch/compare/8.3.0...8.3.1) (2025-05-27)

### Bug Fixes

* revert "Merge pull request [#211](https://github.com/maevsi/sqitch/issues/211) from maevsi/feat/zammad/db" ([f71fa5b](https://github.com/maevsi/sqitch/commit/f71fa5bec07d14b36a34fd9ec3559aac67547750))

## [8.3.0](https://github.com/maevsi/sqitch/compare/8.2.0...8.3.0) (2025-05-26)

### Features

* **zammad:** create database and role ([1565f57](https://github.com/maevsi/sqitch/commit/1565f575277da81aa79edad5f8adea454916e2e1))

## [8.2.0](https://github.com/maevsi/sqitch/compare/8.1.0...8.2.0) (2025-05-22)

### Features

* **account:** add location setter function ([531335c](https://github.com/maevsi/sqitch/commit/531335c4a0276f2271e95071c04341cbaa4b9f06))

## [8.1.0](https://github.com/maevsi/sqitch/compare/8.0.1...8.1.0) (2025-05-22)

### Features

* **account:** add birth date setter function ([1ec9e33](https://github.com/maevsi/sqitch/commit/1ec9e33ceebae5670dfb8d1bc777f09ba31affd0))

## [8.0.1](https://github.com/maevsi/sqitch/compare/8.0.0...8.0.1) (2025-05-15)

### Bug Fixes

* **upload:** correct insert trigger creator ([235804a](https://github.com/maevsi/sqitch/commit/235804a5fefad5cab04f7ab343b5a28cc220687d))

## [8.0.0](https://github.com/maevsi/sqitch/compare/7.0.1...8.0.0) (2025-05-15)

### ⚠ BREAKING CHANGES

* **upload:** drop custom create function
* **upload:** rework permissions
* **event:** remove groups (#195)
* **event:** remove groups
* **event-favorite:** correct smart tags (#194)
* **policy:** simplify policies (#190)
* run separately from `sqitch` (#187)
* **event:** remove existence validation function (#191)
* **account:** add imprint and description (#188)

### Features

* **account:** add imprint and description ([#188](https://github.com/maevsi/sqitch/issues/188)) ([ce8a9c9](https://github.com/maevsi/sqitch/commit/ce8a9c95f9e0dbf91d4f5df424650b1541e61461))
* **event:** remove existence validation function ([#191](https://github.com/maevsi/sqitch/issues/191)) ([4abfcaf](https://github.com/maevsi/sqitch/commit/4abfcaf0d5a12ab93b9270d3b92d1ec44df33f60))
* **event:** remove groups ([22cf406](https://github.com/maevsi/sqitch/commit/22cf406c924bf048fc539faea747d2936312f28b))
* **event:** remove groups ([#195](https://github.com/maevsi/sqitch/issues/195)) ([4bae6c6](https://github.com/maevsi/sqitch/commit/4bae6c67b8a427d453cc8825ec6955a55f03fe3a))
* **grafana:** readd ([0fbae08](https://github.com/maevsi/sqitch/commit/0fbae08feb875e51c2fc19ac18a3d9a25f4f2234))
* **upload:** drop custom create function ([caa5e05](https://github.com/maevsi/sqitch/commit/caa5e053a85f62861e3ddaee4d366c8db7a5a81a))
* **upload:** rework permissions ([bfb3603](https://github.com/maevsi/sqitch/commit/bfb36037b1e804184dd12b18cbc2acffe4ea9519))

### Bug Fixes

* **address:** allow selects for accessible events ([dec870a](https://github.com/maevsi/sqitch/commit/dec870a9236a44adf688a4d61444e138afb9c1bb))
* **event-favorite:** correct smart tags ([c977979](https://github.com/maevsi/sqitch/commit/c97797938503a3845b0b07784b1e283236b25078))
* **event-favorite:** correct smart tags ([#194](https://github.com/maevsi/sqitch/issues/194)) ([fa81e9e](https://github.com/maevsi/sqitch/commit/fa81e9ecaea39d7bf9b809835fd1303c0412325b))

### Miscellaneous Chores

* **policy:** simplify policies ([#190](https://github.com/maevsi/sqitch/issues/190)) ([7e525e1](https://github.com/maevsi/sqitch/commit/7e525e1e82cdeda035064bc8367030d0a57027e4))

### Tests

* run separately from `sqitch` ([#187](https://github.com/maevsi/sqitch/issues/187)) ([ef987b2](https://github.com/maevsi/sqitch/commit/ef987b26c615cd64c3f66d7f2947ca0347a430a4))

## [8.0.0-beta.10](https://github.com/maevsi/sqitch/compare/8.0.0-beta.9...8.0.0-beta.10) (2025-05-15)

### Bug Fixes

* **address:** allow selects for accessible events ([dec870a](https://github.com/maevsi/sqitch/commit/dec870a9236a44adf688a4d61444e138afb9c1bb))

## [8.0.0-beta.9](https://github.com/maevsi/sqitch/compare/8.0.0-beta.8...8.0.0-beta.9) (2025-05-13)

### Features

* **grafana:** readd ([0fbae08](https://github.com/maevsi/sqitch/commit/0fbae08feb875e51c2fc19ac18a3d9a25f4f2234))

## [8.0.0-beta.8](https://github.com/maevsi/sqitch/compare/8.0.0-beta.7...8.0.0-beta.8) (2025-05-12)

### ⚠ BREAKING CHANGES

* **upload:** drop custom create function
* **upload:** rework permissions

### Features

* **upload:** drop custom create function ([caa5e05](https://github.com/maevsi/sqitch/commit/caa5e053a85f62861e3ddaee4d366c8db7a5a81a))
* **upload:** rework permissions ([bfb3603](https://github.com/maevsi/sqitch/commit/bfb36037b1e804184dd12b18cbc2acffe4ea9519))

## [8.0.0-beta.7](https://github.com/maevsi/sqitch/compare/8.0.0-beta.6...8.0.0-beta.7) (2025-05-10)

### Bug Fixes

* schedule release ([8e1b5b8](https://github.com/maevsi/sqitch/commit/8e1b5b8f29e4de79249f693341ee42862825ced8))

## [8.0.0-beta.6](https://github.com/maevsi/sqitch/compare/8.0.0-beta.5...8.0.0-beta.6) (2025-05-09)

### ⚠ BREAKING CHANGES

* **event:** remove groups (#195)
* **event:** remove groups

### Features

* **event:** remove groups ([22cf406](https://github.com/maevsi/sqitch/commit/22cf406c924bf048fc539faea747d2936312f28b))
* **event:** remove groups ([#195](https://github.com/maevsi/sqitch/issues/195)) ([4bae6c6](https://github.com/maevsi/sqitch/commit/4bae6c67b8a427d453cc8825ec6955a55f03fe3a))

## [8.0.0-beta.5](https://github.com/maevsi/sqitch/compare/8.0.0-beta.4...8.0.0-beta.5) (2025-05-02)

### ⚠ BREAKING CHANGES

* **event-favorite:** correct smart tags (#194)

### Bug Fixes

* **event-favorite:** correct smart tags ([c977979](https://github.com/maevsi/sqitch/commit/c97797938503a3845b0b07784b1e283236b25078))
* **event-favorite:** correct smart tags ([#194](https://github.com/maevsi/sqitch/issues/194)) ([fa81e9e](https://github.com/maevsi/sqitch/commit/fa81e9ecaea39d7bf9b809835fd1303c0412325b))

## [8.0.0-beta.4](https://github.com/maevsi/sqitch/compare/8.0.0-beta.3...8.0.0-beta.4) (2025-05-02)

### ⚠ BREAKING CHANGES

* **policy:** simplify policies (#190)

### Miscellaneous Chores

* **policy:** simplify policies ([#190](https://github.com/maevsi/sqitch/issues/190)) ([7e525e1](https://github.com/maevsi/sqitch/commit/7e525e1e82cdeda035064bc8367030d0a57027e4))

## [8.0.0-beta.3](https://github.com/maevsi/sqitch/compare/8.0.0-beta.2...8.0.0-beta.3) (2025-05-02)

### ⚠ BREAKING CHANGES

* run separately from `sqitch` (#187)

### Tests

* run separately from `sqitch` ([#187](https://github.com/maevsi/sqitch/issues/187)) ([ef987b2](https://github.com/maevsi/sqitch/commit/ef987b26c615cd64c3f66d7f2947ca0347a430a4))

## [8.0.0-beta.2](https://github.com/maevsi/sqitch/compare/8.0.0-beta.1...8.0.0-beta.2) (2025-04-17)

### ⚠ BREAKING CHANGES

* **event:** remove existence validation function (#191)

### Features

* **event:** remove existence validation function ([#191](https://github.com/maevsi/sqitch/issues/191)) ([4abfcaf](https://github.com/maevsi/sqitch/commit/4abfcaf0d5a12ab93b9270d3b92d1ec44df33f60))

## [8.0.0-beta.1](https://github.com/maevsi/sqitch/compare/7.0.0...8.0.0-beta.1) (2025-04-10)

### ⚠ BREAKING CHANGES

* **account:** add imprint and description (#188)

### Features

* **account:** add imprint and description ([#188](https://github.com/maevsi/sqitch/issues/188)) ([ce8a9c9](https://github.com/maevsi/sqitch/commit/ce8a9c95f9e0dbf91d4f5df424650b1541e61461))

## [7.0.1](https://github.com/maevsi/sqitch/compare/7.0.0...7.0.1) (2025-04-26)

### Bug Fixes

* schedule release ([8e1b5b8](https://github.com/maevsi/sqitch/commit/8e1b5b8f29e4de79249f693341ee42862825ced8))

## [7.0.0](https://github.com/maevsi/sqitch/compare/6.2.0...7.0.0) (2025-04-07)

### ⚠ BREAKING CHANGES

* **account:** fail silently at registration on duplicate email (#186)
* **constraint:** add `ON DELETE` clauses to foreign keys (#175)
* **event:** add format preference (#180)
* **role:** rename for services
* **environment:** dissolve target variable file
* **role:** rename postgraphile secret variable

### Features

* **account:** fail silently at registration on duplicate email ([#186](https://github.com/maevsi/sqitch/issues/186)) ([da03588](https://github.com/maevsi/sqitch/commit/da03588cbd21aa36883696c1bef78325968092fa))
* **constraint:** add `ON DELETE` clauses to foreign keys ([#175](https://github.com/maevsi/sqitch/issues/175)) ([11fd0f4](https://github.com/maevsi/sqitch/commit/11fd0f4c04ef0ad30e09f0c492bcbfeb6bb6429f))
* **event:** add format preference ([#180](https://github.com/maevsi/sqitch/issues/180)) ([31ee10b](https://github.com/maevsi/sqitch/commit/31ee10bcf6ca9fcf3284ce337e3d387bbbb2a7e2))

### Bug Fixes

* **account:** accept legal term on registration ([b55aa95](https://github.com/maevsi/sqitch/commit/b55aa951401f2d296008328bb0b81b5693fe7f1e))
* **plan:** add dependency on account verification for friendship test ([fcbbb8c](https://github.com/maevsi/sqitch/commit/fcbbb8c1c564c593b65ea1bd2f874112ae4ee912))

### Code Refactoring

* **environment:** dissolve target variable file ([9f4ae82](https://github.com/maevsi/sqitch/commit/9f4ae82019b34c0dea7ff815401937edebe4c435))
* **role:** rename for services ([c83b9d1](https://github.com/maevsi/sqitch/commit/c83b9d140a8a0b56f2490f9ce9f7ebdac8398fcd))
* **role:** rename postgraphile secret variable ([7bbae8e](https://github.com/maevsi/sqitch/commit/7bbae8ea0255be81387bce8ea78f1eac8ed10aee))

## [7.0.0-beta.10](https://github.com/maevsi/sqitch/compare/7.0.0-beta.9...7.0.0-beta.10) (2025-04-03)

### ⚠ BREAKING CHANGES

* **account:** fail silently at registration on duplicate email (#186)

### Features

* **account:** fail silently at registration on duplicate email ([#186](https://github.com/maevsi/sqitch/issues/186)) ([da03588](https://github.com/maevsi/sqitch/commit/da03588cbd21aa36883696c1bef78325968092fa))

## [7.0.0-beta.9](https://github.com/maevsi/sqitch/compare/7.0.0-beta.8...7.0.0-beta.9) (2025-03-31)

### ⚠ BREAKING CHANGES

* **constraint:** add `ON DELETE` clauses to foreign keys (#175)

### Features

* **constraint:** add `ON DELETE` clauses to foreign keys ([#175](https://github.com/maevsi/sqitch/issues/175)) ([11fd0f4](https://github.com/maevsi/sqitch/commit/11fd0f4c04ef0ad30e09f0c492bcbfeb6bb6429f))

## [7.0.0-beta.8](https://github.com/maevsi/sqitch/compare/7.0.0-beta.7...7.0.0-beta.8) (2025-03-31)

### Features

* add audit log ([#168](https://github.com/maevsi/sqitch/issues/168)) ([0933459](https://github.com/maevsi/sqitch/commit/0933459063f46ca3f8eb225c5ff2b5bdf697249c))

## [7.0.0-beta.7](https://github.com/maevsi/sqitch/compare/7.0.0-beta.6...7.0.0-beta.7) (2025-03-30)

### ⚠ BREAKING CHANGES

* **event:** add format preference (#180)

### Features

* **event:** add format preference ([#180](https://github.com/maevsi/sqitch/issues/180)) ([31ee10b](https://github.com/maevsi/sqitch/commit/31ee10bcf6ca9fcf3284ce337e3d387bbbb2a7e2))

## [7.0.0-beta.6](https://github.com/maevsi/sqitch/compare/7.0.0-beta.5...7.0.0-beta.6) (2025-03-29)

### Bug Fixes

* **plan:** add dependency on account verification for friendship test ([fcbbb8c](https://github.com/maevsi/sqitch/commit/fcbbb8c1c564c593b65ea1bd2f874112ae4ee912))

## [7.0.0-beta.5](https://github.com/maevsi/sqitch/compare/7.0.0-beta.4...7.0.0-beta.5) (2025-03-27)

### Features

* **event:** add format mapping ([#178](https://github.com/maevsi/sqitch/issues/178)) ([b3ddef8](https://github.com/maevsi/sqitch/commit/b3ddef8f0f291cd443245563e8996c8e64ef5559))

## [7.0.0-beta.4](https://github.com/maevsi/sqitch/compare/7.0.0-beta.3...7.0.0-beta.4) (2025-03-18)

### Bug Fixes

* **account:** accept legal term on registration ([b55aa95](https://github.com/maevsi/sqitch/commit/b55aa951401f2d296008328bb0b81b5693fe7f1e))

## [7.0.0-beta.3](https://github.com/maevsi/sqitch/compare/7.0.0-beta.2...7.0.0-beta.3) (2025-03-17)

### ⚠ BREAKING CHANGES

* **role:** rename for services

### Code Refactoring

* **role:** rename for services ([c83b9d1](https://github.com/maevsi/sqitch/commit/c83b9d140a8a0b56f2490f9ce9f7ebdac8398fcd))

## [7.0.0-beta.2](https://github.com/maevsi/sqitch/compare/7.0.0-beta.1...7.0.0-beta.2) (2025-03-17)

### ⚠ BREAKING CHANGES

* **environment:** dissolve target variable file

### Code Refactoring

* **environment:** dissolve target variable file ([9f4ae82](https://github.com/maevsi/sqitch/commit/9f4ae82019b34c0dea7ff815401937edebe4c435))

## [7.0.0-beta.1](https://github.com/maevsi/sqitch/compare/6.0.0...7.0.0-beta.1) (2025-03-12)

### ⚠ BREAKING CHANGES

* **role:** rename postgraphile secret variable

### Code Refactoring

* **role:** rename postgraphile secret variable ([7bbae8e](https://github.com/maevsi/sqitch/commit/7bbae8ea0255be81387bce8ea78f1eac8ed10aee))

## [6.2.0](https://github.com/maevsi/sqitch/compare/6.1.0...6.2.0) (2025-03-31)

### Features

* add audit log ([#168](https://github.com/maevsi/sqitch/issues/168)) ([0933459](https://github.com/maevsi/sqitch/commit/0933459063f46ca3f8eb225c5ff2b5bdf697249c))

## [6.1.0](https://github.com/maevsi/sqitch/compare/6.0.0...6.1.0) (2025-03-25)

### Features

* **event:** add format mapping ([#178](https://github.com/maevsi/sqitch/issues/178)) ([b3ddef8](https://github.com/maevsi/sqitch/commit/b3ddef8f0f291cd443245563e8996c8e64ef5559))

## [6.0.0](https://github.com/maevsi/sqitch/compare/5.0.2...6.0.0) (2025-03-12)

### ⚠ BREAKING CHANGES

* rename maevsi to vibetype

### Features

* **guest:** add possibility for multiple creation ([e1a95c8](https://github.com/maevsi/sqitch/commit/e1a95c831861d5a8af09ce5f5c262cea0385c6ac))
* **guest:** add TODO comment ([ac165e6](https://github.com/maevsi/sqitch/commit/ac165e6e7e2bfc867c6a67bca0159b2366b3321d))
* **guest:** work in feedback ([255ff9c](https://github.com/maevsi/sqitch/commit/255ff9c24d0aa4846e40cb92e92800d7c4f21bf9))
* rename maevsi to vibetype ([5f8ed4a](https://github.com/maevsi/sqitch/commit/5f8ed4ad0ee8d5ab875a41b66397e15d8af4ba14))

### Bug Fixes

* **account:** improve error messages for blocking ([7d40c82](https://github.com/maevsi/sqitch/commit/7d40c8232eeffec726e62b6e46cce9fd5f08c9b9))
* **friendship:** add test cases ([265cd7a](https://github.com/maevsi/sqitch/commit/265cd7a9ecbfdee9c0c21cecd53b15940ef154ae))
* **guest:** fix in `test_account_block` ([364a937](https://github.com/maevsi/sqitch/commit/364a93758129148b2635226c68a0e5410f66d842))

## [6.0.0-beta.1](https://github.com/maevsi/sqitch/compare/5.1.0-beta.1...6.0.0-beta.1) (2025-03-10)

### ⚠ BREAKING CHANGES

* rename maevsi to vibetype

### Features

* rename maevsi to vibetype ([5f8ed4a](https://github.com/maevsi/sqitch/commit/5f8ed4ad0ee8d5ab875a41b66397e15d8af4ba14))

## [5.1.0-beta.1](https://github.com/maevsi/sqitch/compare/5.0.2...5.1.0-beta.1) (2025-03-06)

### Features

* **guest:** add possibility for multiple creation ([e1a95c8](https://github.com/maevsi/sqitch/commit/e1a95c831861d5a8af09ce5f5c262cea0385c6ac))
* **guest:** add TODO comment ([ac165e6](https://github.com/maevsi/sqitch/commit/ac165e6e7e2bfc867c6a67bca0159b2366b3321d))
* **guest:** work in feedback ([255ff9c](https://github.com/maevsi/sqitch/commit/255ff9c24d0aa4846e40cb92e92800d7c4f21bf9))

### Bug Fixes

* **account:** improve error messages for blocking ([7d40c82](https://github.com/maevsi/sqitch/commit/7d40c8232eeffec726e62b6e46cce9fd5f08c9b9))
* **friendship:** add test cases ([265cd7a](https://github.com/maevsi/sqitch/commit/265cd7a9ecbfdee9c0c21cecd53b15940ef154ae))
* **guest:** fix in `test_account_block` ([364a937](https://github.com/maevsi/sqitch/commit/364a93758129148b2635226c68a0e5410f66d842))

## [5.0.2](https://github.com/maevsi/sqitch/compare/5.0.1...5.0.2) (2025-02-27)

### Bug Fixes

* **invite:** exclude search vector from event columns ([e6cbb95](https://github.com/maevsi/sqitch/commit/e6cbb95aff603b40e374cf9350f32f9767ec96f1))

## [5.0.1](https://github.com/maevsi/sqitch/compare/5.0.0...5.0.1) (2025-02-27)

### Bug Fixes

* **address:** correct nullability ([09fe569](https://github.com/maevsi/sqitch/commit/09fe569b9463860f65dc6e5a586a2fb2305945f8))

## [5.0.0](https://github.com/maevsi/sqitch/compare/4.13.5...5.0.0) (2025-02-27)

### ⚠ BREAKING CHANGES

* **role:** read usernames from secrets (#49)
* **event:** allow to mark upload as header image (#144)
* **index:** merge into table definitions (#147)
* **address:** correct reference columns' name suffix (#140)
* **invitation:** rename to guest (#122)
* **event-favorite:** align to general schema (#135)
* add address (#134)
* **contact:** add note (#133)
* add location (#114)
* **event:** add full text search (#121)
* **extension:** add postgis (#119)
* **grafana:** remove (#107)
* **timestamp:** add time zone (#92)
* **notification:** align timestamp column name
* **account:** rename `created` column to `created_at`

### Features

* **account:** rename `created` column to `created_at` ([df18548](https://github.com/maevsi/sqitch/commit/df18548e11871a22271fa9d131a0538782c1e51b))
* add address ([#134](https://github.com/maevsi/sqitch/issues/134)) ([97a8645](https://github.com/maevsi/sqitch/commit/97a8645f591f7975f367b1ed7ad6b3c920797b3e))
* add location ([#114](https://github.com/maevsi/sqitch/issues/114)) ([8d9a9d1](https://github.com/maevsi/sqitch/commit/8d9a9d1580d6e1c9f9ed1c419350dad57e4fabd9))
* **address:** add location ([55fc3e5](https://github.com/maevsi/sqitch/commit/55fc3e526e9a47eee9e17d3e4fd86b90eec0baba))
* **address:** correct reference columns' name suffix ([#140](https://github.com/maevsi/sqitch/issues/140)) ([9039aee](https://github.com/maevsi/sqitch/commit/9039aee79b8618e2213793a2690278b900cd2e18)), closes [#138](https://github.com/maevsi/sqitch/issues/138) [#141](https://github.com/maevsi/sqitch/issues/141) [#138](https://github.com/maevsi/sqitch/issues/138)
* **address:** simplify policies ([cd4787e](https://github.com/maevsi/sqitch/commit/cd4787e852730c7716b56e64c57a404cc12b3d77))
* **contact:** add note ([#133](https://github.com/maevsi/sqitch/issues/133)) ([153fd3f](https://github.com/maevsi/sqitch/commit/153fd3f8b6e52263fe317425c4470caf2ddb74a1))
* **device:** add ([27c156c](https://github.com/maevsi/sqitch/commit/27c156c57fceada8b543ec351aa130d4028d232b))
* **device:** prevent token value updates ([4bd0d0f](https://github.com/maevsi/sqitch/commit/4bd0d0fdd940d08c32bd64bfef533fba40b6f974))
* **device:** work in feedback ([9b7c451](https://github.com/maevsi/sqitch/commit/9b7c451a88b3df87b8eb6efa35fd2ed6f206f26a))
* **event-favorite:** align to general schema ([#135](https://github.com/maevsi/sqitch/issues/135)) ([87d45df](https://github.com/maevsi/sqitch/commit/87d45dfe526a63d31953c1080ff9abb70f641e21))
* **event:** add full text search ([#121](https://github.com/maevsi/sqitch/issues/121)) ([83533e9](https://github.com/maevsi/sqitch/commit/83533e92951db2315fbc689cd1c6e7270d7b06eb))
* **event:** add visibility unlisted ([#126](https://github.com/maevsi/sqitch/issues/126)) ([759c4d4](https://github.com/maevsi/sqitch/commit/759c4d43f4a3338dce8d55c1eaa347b34edf4ede))
* **event:** allow to mark upload as header image ([#144](https://github.com/maevsi/sqitch/issues/144)) ([25e76dd](https://github.com/maevsi/sqitch/commit/25e76ddb4256ef5d0fa6b15cdc16dba00a79bf17))
* **extension:** add postgis ([#119](https://github.com/maevsi/sqitch/issues/119)) ([5a24dfa](https://github.com/maevsi/sqitch/commit/5a24dfaf542a1045fbd8ff0ee7a678ee44ad501f))
* **friend:** complete the friend feature ([50c7644](https://github.com/maevsi/sqitch/commit/50c76445d23ffbf73d20daecffc439cf2dbdf56e))
* **friend:** draft ([c972eb1](https://github.com/maevsi/sqitch/commit/c972eb1dc030abffa99d90c30916bf5c55095106))
* **friends:** add tests ([93cf92d](https://github.com/maevsi/sqitch/commit/93cf92dc5bfefe308dc949ebec1898e7f9efe3c6))
* **friends:** add tests ([df1fa0c](https://github.com/maevsi/sqitch/commit/df1fa0cbf23a687182a17698aa87763fcd5a8c8a))
* **friends:** add tests ([54de3f8](https://github.com/maevsi/sqitch/commit/54de3f847b7d4f70b9028515fa1b423db065ef1b))
* **friends:** add tests ([12914f5](https://github.com/maevsi/sqitch/commit/12914f5cc88b5a201a94b243b279eee6f3529064))
* **friends:** add tests ([8c9dbb4](https://github.com/maevsi/sqitch/commit/8c9dbb441179f7ba8a0f63a158a14047ef71528c))
* **friends:** give names to check constraints ([eb46d17](https://github.com/maevsi/sqitch/commit/eb46d17137eb7693ebec03048fe45cf900cdec4c))
* **friendship:** improve constraint names ([24309dc](https://github.com/maevsi/sqitch/commit/24309dcebede1323ea4a971e09d04d6e8e97c4c3))
* **friendship:** rename `pending` enum to `requested` ([667e475](https://github.com/maevsi/sqitch/commit/667e4752567dc501273a8f92e721bb7dc925544f))
* **friendship:** restrict update depending on friendship state ([bf599b9](https://github.com/maevsi/sqitch/commit/bf599b9957fa2ecdbb2ba6916100be4e8b76c2dd))
* **friendship:** work in feedback ([18f894e](https://github.com/maevsi/sqitch/commit/18f894e3d4fe950f8751866d3a5247093f7629fd))
* **grafana:** remove ([#107](https://github.com/maevsi/sqitch/issues/107)) ([960b978](https://github.com/maevsi/sqitch/commit/960b97899d8b55cd1b1ef9aad9065c4b1b7f9118))
* **invitation:** rename to guest ([#122](https://github.com/maevsi/sqitch/issues/122)) ([49b20ed](https://github.com/maevsi/sqitch/commit/49b20edb861e1efcd9f061668320bd91dfa8d39b))
* **metadata:** rename author to creator ([#136](https://github.com/maevsi/sqitch/issues/136)) ([55381ff](https://github.com/maevsi/sqitch/commit/55381ff14c144bb7efee3715cce50135130fd81a))
* **notification:** align timestamp column name ([92b2ec2](https://github.com/maevsi/sqitch/commit/92b2ec28752a96b70d4a51256959032074259b6d))
* **role:** read usernames from secrets ([#49](https://github.com/maevsi/sqitch/issues/49)) ([2a413f6](https://github.com/maevsi/sqitch/commit/2a413f62150859a6f90aabe1f1ee03dc6ddf0382)), closes [#154](https://github.com/maevsi/sqitch/issues/154)
* **timestamp:** add time zone ([#92](https://github.com/maevsi/sqitch/issues/92)) ([d36d378](https://github.com/maevsi/sqitch/commit/d36d3786a6eed54feb64f8ace35e42f925d78302))

### Bug Fixes

* **account-block:** bug fixes in functions and policies ([#139](https://github.com/maevsi/sqitch/issues/139)) ([8d71f87](https://github.com/maevsi/sqitch/commit/8d71f87cfd64c09f8753bb5913d139095b9ccbc7))
* **address:** expose creator id for insertion ([514f6bb](https://github.com/maevsi/sqitch/commit/514f6bb410303d73d042c5e4d1e31aa07e900aa2))
* **device:** correct permissions ([bccfe40](https://github.com/maevsi/sqitch/commit/bccfe40ad30b08cbfd1810069c34f3fb0bcb93d9))
* **device:** tune policies ([14ca9cc](https://github.com/maevsi/sqitch/commit/14ca9cc652e23d6db066f8aa1d6c58c103536f35))
* **friendship:** add missing not-null constraint ([2119a5e](https://github.com/maevsi/sqitch/commit/2119a5ea1672c7428b9c416e03a4d2230572f925))
* **friendship:** add usage of enum type to `sqitch.plan` ([329de43](https://github.com/maevsi/sqitch/commit/329de432a174879f04ab0c3dab382634e1417971))
* **friendship:** remove status `rejected` and function `friendship_account_ids` ([c083f6c](https://github.com/maevsi/sqitch/commit/c083f6ceda37cc4fedfa35535b03e6a25aae0083))
* **location:** move test function to appropriate schema ([#130](https://github.com/maevsi/sqitch/issues/130)) ([e5b4a36](https://github.com/maevsi/sqitch/commit/e5b4a365eb548f2753394e58da7ea5549b01fe42))

### Performance Improvements

* **event:** early return search trigger function ([#132](https://github.com/maevsi/sqitch/issues/132)) ([697da38](https://github.com/maevsi/sqitch/commit/697da3855a51552281df0726e121a1d4ecd221db))
* **index:** merge into table definitions ([#147](https://github.com/maevsi/sqitch/issues/147)) ([20b8c5d](https://github.com/maevsi/sqitch/commit/20b8c5d4b34104b055a52bbf06e1debe0264bb8f)), closes [#149](https://github.com/maevsi/sqitch/issues/149)

## [5.0.0-beta.19](https://github.com/maevsi/sqitch/compare/5.0.0-beta.18...5.0.0-beta.19) (2025-02-27)

### Features

* **address:** add location ([55fc3e5](https://github.com/maevsi/sqitch/commit/55fc3e526e9a47eee9e17d3e4fd86b90eec0baba))

## [5.0.0-beta.18](https://github.com/maevsi/sqitch/compare/5.0.0-beta.17...5.0.0-beta.18) (2025-02-26)

### Bug Fixes

* schedule release ([2f3fa7a](https://github.com/maevsi/sqitch/commit/2f3fa7aa51f98195caa0a753031ea5c0d93fbaab))
* **security:** correct secret name ([5974dc1](https://github.com/maevsi/sqitch/commit/5974dc1a95deebeb4e4a6d3f85b37b440efaaf89))

## [5.0.0-beta.17](https://github.com/maevsi/sqitch/compare/5.0.0-beta.16...5.0.0-beta.17) (2025-02-26)

### Bug Fixes

* schedule release ([3c6097d](https://github.com/maevsi/sqitch/commit/3c6097d050c54ddeb5dadd785855933f27500c5b))

## [5.0.0-beta.16](https://github.com/maevsi/sqitch/compare/5.0.0-beta.15...5.0.0-beta.16) (2025-02-26)

### Features

* **address:** simplify policies ([cd4787e](https://github.com/maevsi/sqitch/commit/cd4787e852730c7716b56e64c57a404cc12b3d77))

## [5.0.0-beta.15](https://github.com/maevsi/sqitch/compare/5.0.0-beta.14...5.0.0-beta.15) (2025-02-25)

### Bug Fixes

* **address:** expose creator id for insertion ([514f6bb](https://github.com/maevsi/sqitch/commit/514f6bb410303d73d042c5e4d1e31aa07e900aa2))

## [5.0.0-beta.14](https://github.com/maevsi/sqitch/compare/5.0.0-beta.13...5.0.0-beta.14) (2025-02-25)

### Features

* **friend:** complete the friend feature ([50c7644](https://github.com/maevsi/sqitch/commit/50c76445d23ffbf73d20daecffc439cf2dbdf56e))
* **friend:** draft ([c972eb1](https://github.com/maevsi/sqitch/commit/c972eb1dc030abffa99d90c30916bf5c55095106))
* **friends:** add tests ([93cf92d](https://github.com/maevsi/sqitch/commit/93cf92dc5bfefe308dc949ebec1898e7f9efe3c6))
* **friends:** add tests ([df1fa0c](https://github.com/maevsi/sqitch/commit/df1fa0cbf23a687182a17698aa87763fcd5a8c8a))
* **friends:** add tests ([54de3f8](https://github.com/maevsi/sqitch/commit/54de3f847b7d4f70b9028515fa1b423db065ef1b))
* **friends:** add tests ([12914f5](https://github.com/maevsi/sqitch/commit/12914f5cc88b5a201a94b243b279eee6f3529064))
* **friends:** add tests ([8c9dbb4](https://github.com/maevsi/sqitch/commit/8c9dbb441179f7ba8a0f63a158a14047ef71528c))
* **friends:** give names to check constraints ([eb46d17](https://github.com/maevsi/sqitch/commit/eb46d17137eb7693ebec03048fe45cf900cdec4c))
* **friendship:** improve constraint names ([24309dc](https://github.com/maevsi/sqitch/commit/24309dcebede1323ea4a971e09d04d6e8e97c4c3))
* **friendship:** rename `pending` enum to `requested` ([667e475](https://github.com/maevsi/sqitch/commit/667e4752567dc501273a8f92e721bb7dc925544f))
* **friendship:** restrict update depending on friendship state ([bf599b9](https://github.com/maevsi/sqitch/commit/bf599b9957fa2ecdbb2ba6916100be4e8b76c2dd))
* **friendship:** work in feedback ([18f894e](https://github.com/maevsi/sqitch/commit/18f894e3d4fe950f8751866d3a5247093f7629fd))

### Bug Fixes

* **friendship:** add missing not-null constraint ([2119a5e](https://github.com/maevsi/sqitch/commit/2119a5ea1672c7428b9c416e03a4d2230572f925))
* **friendship:** add usage of enum type to `sqitch.plan` ([329de43](https://github.com/maevsi/sqitch/commit/329de432a174879f04ab0c3dab382634e1417971))
* **friendship:** remove status `rejected` and function `friendship_account_ids` ([c083f6c](https://github.com/maevsi/sqitch/commit/c083f6ceda37cc4fedfa35535b03e6a25aae0083))

## [5.0.0-beta.13](https://github.com/maevsi/sqitch/compare/5.0.0-beta.12...5.0.0-beta.13) (2025-02-21)

### Features

* **device:** add ([27c156c](https://github.com/maevsi/sqitch/commit/27c156c57fceada8b543ec351aa130d4028d232b))
* **device:** prevent token value updates ([4bd0d0f](https://github.com/maevsi/sqitch/commit/4bd0d0fdd940d08c32bd64bfef533fba40b6f974))
* **device:** work in feedback ([9b7c451](https://github.com/maevsi/sqitch/commit/9b7c451a88b3df87b8eb6efa35fd2ed6f206f26a))

### Bug Fixes

* **device:** correct permissions ([bccfe40](https://github.com/maevsi/sqitch/commit/bccfe40ad30b08cbfd1810069c34f3fb0bcb93d9))
* **device:** tune policies ([14ca9cc](https://github.com/maevsi/sqitch/commit/14ca9cc652e23d6db066f8aa1d6c58c103536f35))

## [5.0.0-beta.12](https://github.com/maevsi/sqitch/compare/5.0.0-beta.11...5.0.0-beta.12) (2025-02-16)

### ⚠ BREAKING CHANGES

* **role:** read usernames from secrets (#49)

### Features

* **role:** read usernames from secrets ([#49](https://github.com/maevsi/sqitch/issues/49)) ([2a413f6](https://github.com/maevsi/sqitch/commit/2a413f62150859a6f90aabe1f1ee03dc6ddf0382)), closes [#154](https://github.com/maevsi/sqitch/issues/154)

## [5.0.0-beta.11](https://github.com/maevsi/sqitch/compare/5.0.0-beta.10...5.0.0-beta.11) (2025-02-06)

### ⚠ BREAKING CHANGES

* **event:** allow to mark upload as header image (#144)

### Features

* **event:** allow to mark upload as header image ([#144](https://github.com/maevsi/sqitch/issues/144)) ([25e76dd](https://github.com/maevsi/sqitch/commit/25e76ddb4256ef5d0fa6b15cdc16dba00a79bf17))

## [5.0.0-beta.10](https://github.com/maevsi/sqitch/compare/5.0.0-beta.9...5.0.0-beta.10) (2025-02-04)

### Bug Fixes

* **account-block:** bug fixes in functions and policies ([#139](https://github.com/maevsi/sqitch/issues/139)) ([8d71f87](https://github.com/maevsi/sqitch/commit/8d71f87cfd64c09f8753bb5913d139095b9ccbc7))

## [5.0.0-beta.9](https://github.com/maevsi/sqitch/compare/5.0.0-beta.8...5.0.0-beta.9) (2025-02-04)

### ⚠ BREAKING CHANGES

* **index:** merge into table definitions (#147)

### Performance Improvements

* **index:** merge into table definitions ([#147](https://github.com/maevsi/sqitch/issues/147)) ([20b8c5d](https://github.com/maevsi/sqitch/commit/20b8c5d4b34104b055a52bbf06e1debe0264bb8f)), closes [#149](https://github.com/maevsi/sqitch/issues/149)

## [5.0.0-beta.8](https://github.com/maevsi/sqitch/compare/5.0.0-beta.7...5.0.0-beta.8) (2025-02-02)

### ⚠ BREAKING CHANGES

* **address:** correct reference columns' name suffix (#140)

### Features

* **address:** correct reference columns' name suffix ([#140](https://github.com/maevsi/sqitch/issues/140)) ([9039aee](https://github.com/maevsi/sqitch/commit/9039aee79b8618e2213793a2690278b900cd2e18)), closes [#138](https://github.com/maevsi/sqitch/issues/138) [#141](https://github.com/maevsi/sqitch/issues/141) [#138](https://github.com/maevsi/sqitch/issues/138)

## [5.0.0-beta.7](https://github.com/maevsi/sqitch/compare/5.0.0-beta.6...5.0.0-beta.7) (2025-01-30)

### Bug Fixes

* **account-block:** change function call mode to SECURITY DEFINER ([#131](https://github.com/maevsi/sqitch/issues/131)) ([7160274](https://github.com/maevsi/sqitch/commit/716027482c7707ea126932baedffd80c783f7641))

## [5.0.0-beta.6](https://github.com/maevsi/sqitch/compare/5.0.0-beta.5...5.0.0-beta.6) (2025-01-29)

### ⚠ BREAKING CHANGES

* **invitation:** rename to guest (#122)

### Features

* **invitation:** rename to guest ([#122](https://github.com/maevsi/sqitch/issues/122)) ([49b20ed](https://github.com/maevsi/sqitch/commit/49b20edb861e1efcd9f061668320bd91dfa8d39b))

## [5.0.0-beta.5](https://github.com/maevsi/sqitch/compare/5.0.0-beta.4...5.0.0-beta.5) (2025-01-29)

### ⚠ BREAKING CHANGES

* **event-favorite:** align to general schema (#135)
* add address (#134)
* **contact:** add note (#133)

### Features

* add address ([#134](https://github.com/maevsi/sqitch/issues/134)) ([97a8645](https://github.com/maevsi/sqitch/commit/97a8645f591f7975f367b1ed7ad6b3c920797b3e))
* **contact:** add note ([#133](https://github.com/maevsi/sqitch/issues/133)) ([153fd3f](https://github.com/maevsi/sqitch/commit/153fd3f8b6e52263fe317425c4470caf2ddb74a1))
* **event-favorite:** align to general schema ([#135](https://github.com/maevsi/sqitch/issues/135)) ([87d45df](https://github.com/maevsi/sqitch/commit/87d45dfe526a63d31953c1080ff9abb70f641e21))
* **metadata:** rename author to creator ([#136](https://github.com/maevsi/sqitch/issues/136)) ([55381ff](https://github.com/maevsi/sqitch/commit/55381ff14c144bb7efee3715cce50135130fd81a))

### Performance Improvements

* **event:** early return search trigger function ([#132](https://github.com/maevsi/sqitch/issues/132)) ([697da38](https://github.com/maevsi/sqitch/commit/697da3855a51552281df0726e121a1d4ecd221db))

## [5.0.0-beta.4](https://github.com/maevsi/sqitch/compare/5.0.0-beta.3...5.0.0-beta.4) (2025-01-26)

### Bug Fixes

* **location:** move test function to appropriate schema ([#130](https://github.com/maevsi/sqitch/issues/130)) ([e5b4a36](https://github.com/maevsi/sqitch/commit/e5b4a365eb548f2753394e58da7ea5549b01fe42))

## [5.0.0-beta.3](https://github.com/maevsi/sqitch/compare/5.0.0-beta.2...5.0.0-beta.3) (2025-01-25)

### ⚠ BREAKING CHANGES

* add location (#114)
* **event:** add full text search (#121)
* **extension:** add postgis (#119)
* **grafana:** remove (#107)
* **timestamp:** add time zone (#92)

### Features

* **account:** add login using email address ([#112](https://github.com/maevsi/sqitch/issues/112)) ([937d255](https://github.com/maevsi/sqitch/commit/937d255ab04313442f173804f2fd87f817249f81))
* **account:** add possibility to block ([#73](https://github.com/maevsi/sqitch/issues/73)) ([4ab872e](https://github.com/maevsi/sqitch/commit/4ab872eef7c165605f1070636e1050f3a876e51a))
* **achievement:** add early bird achievement ([#111](https://github.com/maevsi/sqitch/issues/111)) ([0238bea](https://github.com/maevsi/sqitch/commit/0238bea39fc942bd49c894eb57214534a01db0a1))
* add language enumeration ([76a1465](https://github.com/maevsi/sqitch/commit/76a1465f219c4c0171aafcac1bbbac16580d9691))
* add location ([#114](https://github.com/maevsi/sqitch/issues/114)) ([8d9a9d1](https://github.com/maevsi/sqitch/commit/8d9a9d1580d6e1c9f9ed1c419350dad57e4fabd9))
* **contact:** add language ([669570f](https://github.com/maevsi/sqitch/commit/669570f6322aa8ad971990b2de9fcf8afdf14007))
* **contact:** add nickname ([8b7169a](https://github.com/maevsi/sqitch/commit/8b7169a856b5e81ebb0676ac7de6ce512a83d548))
* **contact:** add timezone ([02da0f9](https://github.com/maevsi/sqitch/commit/02da0f9cdb644ef78c5c6a4b354d2bd968904337))
* **event_upload:** adjust policies. ([23eb8f4](https://github.com/maevsi/sqitch/commit/23eb8f4fbc169117e928c3b75a33635d7d970ff3))
* **event-category-mapping:** check if invited ([4ba7dac](https://github.com/maevsi/sqitch/commit/4ba7dac31bb06937cf01829db9e58d98e9a9c723))
* **event:** add full text search ([#121](https://github.com/maevsi/sqitch/issues/121)) ([83533e9](https://github.com/maevsi/sqitch/commit/83533e92951db2315fbc689cd1c6e7270d7b06eb))
* **event:** add visibility unlisted ([#126](https://github.com/maevsi/sqitch/issues/126)) ([759c4d4](https://github.com/maevsi/sqitch/commit/759c4d43f4a3338dce8d55c1eaa347b34edf4ede))
* **event:** assign images to events ([f4822f8](https://github.com/maevsi/sqitch/commit/f4822f8252089929dea47f3585737d49b19b7c30))
* **event:** mark events as favourite ([#109](https://github.com/maevsi/sqitch/issues/109)) ([7b75524](https://github.com/maevsi/sqitch/commit/7b75524def9ab2575db922567e9d6db87ef3a929))
* **extension:** add postgis ([#119](https://github.com/maevsi/sqitch/issues/119)) ([5a24dfa](https://github.com/maevsi/sqitch/commit/5a24dfaf542a1045fbd8ff0ee7a678ee44ad501f))
* **grafana:** remove ([#107](https://github.com/maevsi/sqitch/issues/107)) ([960b978](https://github.com/maevsi/sqitch/commit/960b97899d8b55cd1b1ef9aad9065c4b1b7f9118))
* **invitation:** add update metadata ([f493fe4](https://github.com/maevsi/sqitch/commit/f493fe4d6c5e5127a0cad253768c864fcdfe296b))
* **invitation:** column names prefixed ([2e29431](https://github.com/maevsi/sqitch/commit/2e294319a7b651deb1b472953ebb3ee770c5a5c6))
* **invitation:** provide flattened invitations ([119b0dd](https://github.com/maevsi/sqitch/commit/119b0dd3c7337db9688a78778eb8a9484e6d3785))
* **policy:** add policy to recommendation tables ([280f47b](https://github.com/maevsi/sqitch/commit/280f47b8fd93ee871f2bd25ba2daeaf5e496b84f))
* **recommendation:** add enum and tables needed for event recommendation ([7fb5e21](https://github.com/maevsi/sqitch/commit/7fb5e21f28fc70ea7bcbb6e764cd54cb5f0a899b))
* **recommendation:** several modifications to db schema ([8581ad0](https://github.com/maevsi/sqitch/commit/8581ad091bea58ff33fab8a31e1c9e8fd2f2c430))
* **revert:** add revert for recommendation tables ([cff0b7f](https://github.com/maevsi/sqitch/commit/cff0b7fdef045ac3f388553f7c4bbffb3a019c78))
* **schema:** fix small errors and build schema ([3183da0](https://github.com/maevsi/sqitch/commit/3183da01587f4b83e646a5158cb8fba42f44a7ff))
* **table:** add creation timestamps ([d8d142d](https://github.com/maevsi/sqitch/commit/d8d142d8d1b12ae4890b97f60fc2daf7eb20fe96))
* **timestamp:** add time zone ([#92](https://github.com/maevsi/sqitch/issues/92)) ([d36d378](https://github.com/maevsi/sqitch/commit/d36d3786a6eed54feb64f8ace35e42f925d78302))
* **verify:** add verification for event recommendation tables ([1d6bb59](https://github.com/maevsi/sqitch/commit/1d6bb59a8cd21b4b3bc1c8a48161b3d3ff6226a3))

### Bug Fixes

* **account-block:** remove bug in function, create new table function ([#125](https://github.com/maevsi/sqitch/issues/125)) ([35b22b4](https://github.com/maevsi/sqitch/commit/35b22b4a1530e6cb95687578c0725428e243b4cd))
* **build:** commit forgotten files ([d554d0f](https://github.com/maevsi/sqitch/commit/d554d0fe33d903da55a1b14ff9b35772ebad867b))
* **event-upload:** work in feedback ([678ddfc](https://github.com/maevsi/sqitch/commit/678ddfce330171ab340bd112f2734d1ab304559b))
* **invitation-flat:** work in feedback ([6ac75ac](https://github.com/maevsi/sqitch/commit/6ac75ac03d73bdf6daed20e3bf47668fe9a45e22))
* **invoker-account-id:** grant execute for tusd ([#123](https://github.com/maevsi/sqitch/issues/123)) ([7245225](https://github.com/maevsi/sqitch/commit/7245225527b7f98a76d881863c574c862254defd))
* **legal-term-acceptance:** omit update and delete ([555e031](https://github.com/maevsi/sqitch/commit/555e031c96e3a83ae41e3b03dd5c2de72e51780f))
* omit update for creation timestamps ([084ad1e](https://github.com/maevsi/sqitch/commit/084ad1e7f89dfcfd890fde76f3d5baa9dffe1cd8))
* **policy:** fix user check in event category mapping policy ([3dfd96a](https://github.com/maevsi/sqitch/commit/3dfd96ab1949933b6326e1762ee6461ff39eda60))
* **role:** drop before creation ([#106](https://github.com/maevsi/sqitch/issues/106)) ([fecd16e](https://github.com/maevsi/sqitch/commit/fecd16ea860a18f0cfdaa7f0118899acf4133cce))
* schedule release ([6e32e10](https://github.com/maevsi/sqitch/commit/6e32e10a00373c9d88d843db73038d438b130364))
* schedule release ([7dbc9bb](https://github.com/maevsi/sqitch/commit/7dbc9bbe6c23449418012ed2eb439df4400749bf))
* **schema:** remove table prefix so schema can be build ([cc5be2d](https://github.com/maevsi/sqitch/commit/cc5be2d7f0db3a251337325ec0b3aa822d0f8482))

## [5.0.0-beta.2](https://github.com/maevsi/sqitch/compare/5.0.0-beta.1...5.0.0-beta.2) (2024-12-12)
## [4.13.5](https://github.com/maevsi/sqitch/compare/4.13.4...4.13.5) (2025-02-26)

### Bug Fixes

* schedule release ([2f3fa7a](https://github.com/maevsi/sqitch/commit/2f3fa7aa51f98195caa0a753031ea5c0d93fbaab))
* **security:** correct secret name ([5974dc1](https://github.com/maevsi/sqitch/commit/5974dc1a95deebeb4e4a6d3f85b37b440efaaf89))

## [4.13.4](https://github.com/maevsi/sqitch/compare/4.13.3...4.13.4) (2025-02-15)

### Bug Fixes

* schedule release ([3c6097d](https://github.com/maevsi/sqitch/commit/3c6097d050c54ddeb5dadd785855933f27500c5b))

## [4.13.3](https://github.com/maevsi/sqitch/compare/4.13.2...4.13.3) (2025-01-26)

### Bug Fixes

* **account-block:** change function call mode to SECURITY DEFINER ([#131](https://github.com/maevsi/sqitch/issues/131)) ([7160274](https://github.com/maevsi/sqitch/commit/716027482c7707ea126932baedffd80c783f7641))

## [4.13.2](https://github.com/maevsi/sqitch/compare/4.13.1...4.13.2) (2025-01-25)

### Bug Fixes

* **account-block:** remove bug in function, create new table function ([#125](https://github.com/maevsi/sqitch/issues/125)) ([35b22b4](https://github.com/maevsi/sqitch/commit/35b22b4a1530e6cb95687578c0725428e243b4cd))

## [4.13.1](https://github.com/maevsi/sqitch/compare/4.13.0...4.13.1) (2025-01-22)

### ⚠ BREAKING CHANGES

* **notification:** align timestamp column name

### Features

* **notification:** align timestamp column name ([92b2ec2](https://github.com/maevsi/sqitch/commit/92b2ec28752a96b70d4a51256959032074259b6d))

## [5.0.0-beta.1](https://github.com/maevsi/sqitch/compare/4.3.1...5.0.0-beta.1) (2024-12-12)

### ⚠ BREAKING CHANGES

* **account:** rename `created` column to `created_at`

### Features

* **account:** rename `created` column to `created_at` ([df18548](https://github.com/maevsi/sqitch/commit/df18548e11871a22271fa9d131a0538782c1e51b))

## [4.13.0](https://github.com/maevsi/sqitch/compare/4.12.0...4.13.0) (2025-01-16)

### Features

* **account:** add possibility to block ([#73](https://github.com/maevsi/sqitch/issues/73)) ([4ab872e](https://github.com/maevsi/sqitch/commit/4ab872eef7c165605f1070636e1050f3a876e51a))

## [4.12.0](https://github.com/maevsi/sqitch/compare/4.11.0...4.12.0) (2025-01-15)

### Features

* **account:** add login using email address ([#112](https://github.com/maevsi/sqitch/issues/112)) ([937d255](https://github.com/maevsi/sqitch/commit/937d255ab04313442f173804f2fd87f817249f81))

## [4.11.0](https://github.com/maevsi/sqitch/compare/4.10.2...4.11.0) (2025-01-14)

### Features

* **achievement:** add early bird achievement ([#111](https://github.com/maevsi/sqitch/issues/111)) ([0238bea](https://github.com/maevsi/sqitch/commit/0238bea39fc942bd49c894eb57214534a01db0a1))

## [4.10.2](https://github.com/maevsi/sqitch/compare/4.10.1...4.10.2) (2025-01-11)

### Bug Fixes

* schedule release ([6e32e10](https://github.com/maevsi/sqitch/commit/6e32e10a00373c9d88d843db73038d438b130364))

## [4.10.1](https://github.com/maevsi/sqitch/compare/4.10.0...4.10.1) (2024-12-28)

### Bug Fixes

* schedule release ([7dbc9bb](https://github.com/maevsi/sqitch/commit/7dbc9bbe6c23449418012ed2eb439df4400749bf))

## [4.10.0](https://github.com/maevsi/sqitch/compare/4.9.1...4.10.0) (2024-12-19)

### Features

* **event:** mark events as favourite ([#109](https://github.com/maevsi/sqitch/issues/109)) ([7b75524](https://github.com/maevsi/sqitch/commit/7b75524def9ab2575db922567e9d6db87ef3a929))

## [4.9.1](https://github.com/maevsi/sqitch/compare/4.9.0...4.9.1) (2024-12-18)

### Bug Fixes

* **role:** drop before creation ([#106](https://github.com/maevsi/sqitch/issues/106)) ([fecd16e](https://github.com/maevsi/sqitch/commit/fecd16ea860a18f0cfdaa7f0118899acf4133cce))

## [4.9.0](https://github.com/maevsi/sqitch/compare/4.8.0...4.9.0) (2024-12-12)

### Features

* **event-category-mapping:** check if invited ([4ba7dac](https://github.com/maevsi/sqitch/commit/4ba7dac31bb06937cf01829db9e58d98e9a9c723))
* **policy:** add policy to recommendation tables ([280f47b](https://github.com/maevsi/sqitch/commit/280f47b8fd93ee871f2bd25ba2daeaf5e496b84f))
* **recommendation:** add enum and tables needed for event recommendation ([7fb5e21](https://github.com/maevsi/sqitch/commit/7fb5e21f28fc70ea7bcbb6e764cd54cb5f0a899b))
* **recommendation:** several modifications to db schema ([8581ad0](https://github.com/maevsi/sqitch/commit/8581ad091bea58ff33fab8a31e1c9e8fd2f2c430))
* **revert:** add revert for recommendation tables ([cff0b7f](https://github.com/maevsi/sqitch/commit/cff0b7fdef045ac3f388553f7c4bbffb3a019c78))
* **schema:** fix small errors and build schema ([3183da0](https://github.com/maevsi/sqitch/commit/3183da01587f4b83e646a5158cb8fba42f44a7ff))
* **verify:** add verification for event recommendation tables ([1d6bb59](https://github.com/maevsi/sqitch/commit/1d6bb59a8cd21b4b3bc1c8a48161b3d3ff6226a3))

### Bug Fixes

* **build:** commit forgotten files ([d554d0f](https://github.com/maevsi/sqitch/commit/d554d0fe33d903da55a1b14ff9b35772ebad867b))
* **policy:** fix user check in event category mapping policy ([3dfd96a](https://github.com/maevsi/sqitch/commit/3dfd96ab1949933b6326e1762ee6461ff39eda60))
* **schema:** remove table prefix so schema can be build ([cc5be2d](https://github.com/maevsi/sqitch/commit/cc5be2d7f0db3a251337325ec0b3aa822d0f8482))

## [4.8.0](https://github.com/maevsi/sqitch/compare/4.7.0...4.8.0) (2024-12-12)

### Features

* **event_upload:** adjust policies. ([23eb8f4](https://github.com/maevsi/sqitch/commit/23eb8f4fbc169117e928c3b75a33635d7d970ff3))
* **event:** assign images to events ([f4822f8](https://github.com/maevsi/sqitch/commit/f4822f8252089929dea47f3585737d49b19b7c30))

### Bug Fixes

* **event-upload:** work in feedback ([678ddfc](https://github.com/maevsi/sqitch/commit/678ddfce330171ab340bd112f2734d1ab304559b))

## [4.7.0](https://github.com/maevsi/sqitch/compare/4.6.0...4.7.0) (2024-12-12)

### Features

* **invitation:** column names prefixed ([2e29431](https://github.com/maevsi/sqitch/commit/2e294319a7b651deb1b472953ebb3ee770c5a5c6))
* **invitation:** provide flattened invitations ([119b0dd](https://github.com/maevsi/sqitch/commit/119b0dd3c7337db9688a78778eb8a9484e6d3785))

### Bug Fixes

* **invitation-flat:** work in feedback ([6ac75ac](https://github.com/maevsi/sqitch/commit/6ac75ac03d73bdf6daed20e3bf47668fe9a45e22))

## [4.6.0](https://github.com/maevsi/sqitch/compare/4.5.1...4.6.0) (2024-12-12)

### Features

* **invitation:** add update metadata ([f493fe4](https://github.com/maevsi/sqitch/commit/f493fe4d6c5e5127a0cad253768c864fcdfe296b))

## [4.5.1](https://github.com/maevsi/sqitch/compare/4.5.0...4.5.1) (2024-12-12)

### Bug Fixes

* **legal-term-acceptance:** omit update and delete ([555e031](https://github.com/maevsi/sqitch/commit/555e031c96e3a83ae41e3b03dd5c2de72e51780f))
* omit update for creation timestamps ([084ad1e](https://github.com/maevsi/sqitch/commit/084ad1e7f89dfcfd890fde76f3d5baa9dffe1cd8))

## [4.5.0](https://github.com/maevsi/sqitch/compare/4.4.0...4.5.0) (2024-12-12)

### Features

* **table:** add creation timestamps ([d8d142d](https://github.com/maevsi/sqitch/commit/d8d142d8d1b12ae4890b97f60fc2daf7eb20fe96))

## [4.4.0](https://github.com/maevsi/sqitch/compare/4.3.1...4.4.0) (2024-12-12)

### Features

* add language enumeration ([76a1465](https://github.com/maevsi/sqitch/commit/76a1465f219c4c0171aafcac1bbbac16580d9691))
* **contact:** add language ([669570f](https://github.com/maevsi/sqitch/commit/669570f6322aa8ad971990b2de9fcf8afdf14007))
* **contact:** add nickname ([8b7169a](https://github.com/maevsi/sqitch/commit/8b7169a856b5e81ebb0676ac7de6ce512a83d548))
* **contact:** add timezone ([02da0f9](https://github.com/maevsi/sqitch/commit/02da0f9cdb644ef78c5c6a4b354d2bd968904337))

## [4.3.1](https://github.com/maevsi/sqitch/compare/4.3.0...4.3.1) (2024-12-06)

### Bug Fixes

* **account:** enable row level security for social networks ([5606344](https://github.com/maevsi/sqitch/commit/5606344016974dd223ece949fb11d0d4b02400de))

## [4.3.0](https://github.com/maevsi/sqitch/compare/4.2.0...4.3.0) (2024-12-06)

### Features

* **account:** Add ability to store an account's preferred event sizes ([5f47988](https://github.com/maevsi/sqitch/commit/5f47988bc0ebedf2caa3a38399adc4f4de6c5b38))
* **event:** Add event sizes ([e3b389b](https://github.com/maevsi/sqitch/commit/e3b389bb302b16a208a1dddedc35f1b909175af6))
* **event:** remove size function ([9338623](https://github.com/maevsi/sqitch/commit/93386233fd89a5c1fd7a2cfec4cce6c8a30be935))

## [4.2.0](https://github.com/maevsi/sqitch/compare/4.1.1...4.2.0) (2024-12-06)

### Features

* **account:** add social links ([b23fa1d](https://github.com/maevsi/sqitch/commit/b23fa1d6608275eadef48c33202bf33ae9b92411))
* **social-network:** rework ([605cd77](https://github.com/maevsi/sqitch/commit/605cd773d156cfe4d24764d88b3ee294fce6bfbc))

## [4.1.1](https://github.com/maevsi/sqitch/compare/4.1.0...4.1.1) (2024-12-05)

### Bug Fixes

* **account:** allow empty birth date ([d308c21](https://github.com/maevsi/sqitch/commit/d308c21bda037f111c275df3c900b86e7a289d26))

## [4.1.0](https://github.com/maevsi/sqitch/compare/4.0.5...4.1.0) (2024-12-02)

### Features

* **account:** column day_of_birth added ([71cc5e4](https://github.com/maevsi/sqitch/commit/71cc5e46105e70205492d782207750805f1bc184))

## [4.0.5](https://github.com/maevsi/sqitch/compare/4.0.4...4.0.5) (2024-11-30)

### Bug Fixes

* schedule release ([432f826](https://github.com/maevsi/sqitch/commit/432f826cced7129907548418635f207ff1d06b24))

## [4.0.4](https://github.com/maevsi/sqitch/compare/4.0.3...4.0.4) (2024-11-16)

### Bug Fixes

* schedule release ([1f54ae2](https://github.com/maevsi/sqitch/commit/1f54ae20aa31fa3f322eca46db74194482582649))

## [4.0.3](https://github.com/maevsi/sqitch/compare/4.0.2...4.0.3) (2024-11-09)

### Bug Fixes

* schedule release ([2f3dc5e](https://github.com/maevsi/sqitch/commit/2f3dc5ecd5b11657fb99dc94f364b7d11950904d))

## [4.0.2](https://github.com/maevsi/sqitch/compare/4.0.1...4.0.2) (2024-10-26)

### Bug Fixes

* schedule release ([9639a7e](https://github.com/maevsi/sqitch/commit/9639a7edb5de42ee3f9f26ac3e29f2249d184935))

## [4.0.1](https://github.com/maevsi/sqitch/compare/4.0.0...4.0.1) (2024-10-16)

### Bug Fixes

* **report:** correct smart tags ([31eceeb](https://github.com/maevsi/sqitch/commit/31eceeb7e30e5dafbc0adab852a2707ee6514078))
* **report:** omit creation timestamp from create mutation ([005f7a2](https://github.com/maevsi/sqitch/commit/005f7a24c9cc5966af5881bc82e90f81535649dd))

## [4.0.0](https://github.com/maevsi/sqitch/compare/3.6.0...4.0.0) (2024-10-16)

### ⚠ BREAKING CHANGES

* **roles:** remove stomper
* **notification:** grant execute to anonymous
* **notification:** remove trigger

### Features

* **notification:** grant execute to anonymous ([070c694](https://github.com/maevsi/sqitch/commit/070c694de479bc761b4a1578086f56eebdf73759))
* **notification:** remove trigger ([bef6af9](https://github.com/maevsi/sqitch/commit/bef6af9f33c9f57c042aa3269095b6d38fb4c3cb))
* **roles:** remove stomper ([5efe0e7](https://github.com/maevsi/sqitch/commit/5efe0e7e21bf70fc94ec7db9ee612be9c5713add))

## [4.0.0-beta.2](https://github.com/maevsi/sqitch/compare/4.0.0-beta.1...4.0.0-beta.2) (2024-10-06)

### ⚠ BREAKING CHANGES

* **roles:** remove stomper
* **notification:** grant execute to anonymous

### Features

* **notification:** grant execute to anonymous ([070c694](https://github.com/maevsi/sqitch/commit/070c694de479bc761b4a1578086f56eebdf73759))
* **roles:** remove stomper ([5efe0e7](https://github.com/maevsi/sqitch/commit/5efe0e7e21bf70fc94ec7db9ee612be9c5713add))

## [4.0.0-beta.1](https://github.com/maevsi/sqitch/compare/3.4.8...4.0.0-beta.1) (2024-10-04)

### ⚠ BREAKING CHANGES

* **notification:** remove trigger

### Features

* **notification:** remove trigger ([bef6af9](https://github.com/maevsi/sqitch/commit/bef6af9f33c9f57c042aa3269095b6d38fb4c3cb))

## [3.6.0](https://github.com/maevsi/sqitch/compare/3.5.0...3.6.0) (2024-10-15)

### Features

* **legal-term:** create tables ([591a66e](https://github.com/maevsi/sqitch/commit/591a66eecddf89f95df5a56fdae9528c6b6a8528))

### Bug Fixes

* **legal-term:** correct smart tags ([0cc036a](https://github.com/maevsi/sqitch/commit/0cc036ab63d11ed647e2d74d04d2237b11f1be8e))

## [3.5.0](https://github.com/maevsi/sqitch/compare/3.4.8...3.5.0) (2024-10-13)

### Features

* **report:** add created column ([0f8ad03](https://github.com/maevsi/sqitch/commit/0f8ad037d559b1ca85d1bfc1a8e240956523a1de))
* **report:** add policy to allow selection of own reports ([787c2b0](https://github.com/maevsi/sqitch/commit/787c2b0c70e76ae99bd44eadd3bcb229587f1727))
* **report:** add reason column to report table ([fac766e](https://github.com/maevsi/sqitch/commit/fac766ec7d9fbc9849e82e81d14c2e085b2db285))
* **report:** add report table ([62e347a](https://github.com/maevsi/sqitch/commit/62e347ab3722c98e7fcbe9b49f5c951bb68c25bb))
* **report:** add report table policies ([ea469e7](https://github.com/maevsi/sqitch/commit/ea469e78064689e7b578990722f28a47c29fe485))
* **report:** add unique constraint to prevent multiple reports by same user ([6b267cd](https://github.com/maevsi/sqitch/commit/6b267cd22fd3da23d41fc9f4f866b5645a9c0c8e))
* **report:** refactoring ([f5c84b0](https://github.com/maevsi/sqitch/commit/f5c84b0d59024cd3b7635a66f525e327099333e3))
* **report:** rename creation time column ([ad481ee](https://github.com/maevsi/sqitch/commit/ad481ee20daafff90376a7350672cf86f0c5d2ca))

## [3.4.8](https://github.com/maevsi/sqitch/compare/3.4.7...3.4.8) (2024-09-28)

### Bug Fixes

* schedule release ([319c5cd](https://github.com/maevsi/sqitch/commit/319c5cd0f456319e8dbc5dfd2f1e2defd1f3aa8a))

## [3.4.7](https://github.com/maevsi/sqitch/compare/3.4.6...3.4.7) (2024-09-14)

### Bug Fixes

* schedule release ([4ef76c1](https://github.com/maevsi/sqitch/commit/4ef76c1e32e2cbdbec26ebe6677f269500a35626))

## [3.4.6](https://github.com/maevsi/sqitch/compare/3.4.5...3.4.6) (2024-08-31)

### Bug Fixes

* schedule release ([dea09ec](https://github.com/maevsi/sqitch/commit/dea09ecda2d1bce4fc52fd656fb90a5d376e2606))

## [3.4.5](https://github.com/maevsi/sqitch/compare/3.4.4...3.4.5) (2024-08-17)

### Bug Fixes

* schedule release ([adc6548](https://github.com/maevsi/sqitch/commit/adc6548058cba7152338d6493b376ab0d2347428))

## [3.4.4](https://github.com/maevsi/sqitch/compare/3.4.3...3.4.4) (2024-08-03)

### Bug Fixes

* schedule release ([e468eca](https://github.com/maevsi/sqitch/commit/e468eca3cd0e0d116dce88feeda1601a049cb502))

## [3.4.3](https://github.com/maevsi/sqitch/compare/3.4.2...3.4.3) (2024-07-20)

### Bug Fixes

* schedule release ([af774a4](https://github.com/maevsi/sqitch/commit/af774a420cd7b1dd84f3669077a1e613f183ae27))

## [3.4.2](https://github.com/maevsi/sqitch/compare/3.4.1...3.4.2) (2024-07-06)

### Bug Fixes

* schedule release ([fda139e](https://github.com/maevsi/sqitch/commit/fda139e168b42ad910c8871e7b5afc239e23e66a))

## [3.4.1](https://github.com/maevsi/sqitch/compare/3.4.0...3.4.1) (2024-06-22)

### Bug Fixes

* schedule release ([c8f5edc](https://github.com/maevsi/sqitch/commit/c8f5edc913bebb1ef4a34212f8722b85ef0f4f01))

## [3.4.0](https://github.com/maevsi/sqitch/compare/3.3.2...3.4.0) (2024-06-14)

### Features

* **achievements:** add unlock function ([090e1ff](https://github.com/maevsi/sqitch/commit/090e1ff400177841aa1a7dae2e4a082345a673e5))
* add achievements ([406a335](https://github.com/maevsi/sqitch/commit/406a335995d05b7dc46b6a5998627d9dabcf2c9c))

## [3.3.2](https://github.com/maevsi/sqitch/compare/3.3.1...3.3.2) (2024-06-01)


### Bug Fixes

* schedule release ([96cfc1c](https://github.com/maevsi/sqitch/commit/96cfc1c7e93d94e17984b00ac5579dfd97efbc48))

## [3.3.1](https://github.com/maevsi/sqitch/compare/3.3.0...3.3.1) (2024-05-18)


### Bug Fixes

* schedule release ([7bdeec9](https://github.com/maevsi/sqitch/commit/7bdeec9895351dff33c07dae3f3d6e1902bb6693))

## [3.3.0](https://github.com/maevsi/sqitch/compare/3.2.9...3.3.0) (2024-05-09)


### Features

* **account:** allow function execution by signed in users ([fa4eb8c](https://github.com/maevsi/sqitch/commit/fa4eb8cd08c55c287c2bb99c4ff3cdfdb08fd38d))

## [3.2.9](https://github.com/maevsi/sqitch/compare/3.2.8...3.2.9) (2024-05-06)


### Bug Fixes

* schedule release ([54602d4](https://github.com/maevsi/sqitch/commit/54602d4366e3734bcc3d68730cd283cde204e946))

## [3.2.8](https://github.com/maevsi/sqitch/compare/3.2.7...3.2.8) (2024-04-20)


### Bug Fixes

* schedule release ([d4f7fdf](https://github.com/maevsi/sqitch/commit/d4f7fdf1f196c390d50db084e2fa4bf920ed24ae))

## [3.2.7](https://github.com/maevsi/sqitch/compare/3.2.6...3.2.7) (2024-04-06)


### Bug Fixes

* schedule release ([e7a5419](https://github.com/maevsi/sqitch/commit/e7a541944f2ae45ecdaec4539ca056e785dcb456))

## [3.2.6](https://github.com/maevsi/sqitch/compare/3.2.5...3.2.6) (2024-03-23)


### Bug Fixes

* schedule release ([c6d0a15](https://github.com/maevsi/sqitch/commit/c6d0a155f1f5b70be713da0f989e8042d234075f))

## [3.2.5](https://github.com/maevsi/sqitch/compare/3.2.4...3.2.5) (2024-03-09)


### Bug Fixes

* schedule release ([b4b0bfd](https://github.com/maevsi/sqitch/commit/b4b0bfdc2694f8781852112e0412464b0f2403cb))

## [3.2.4](https://github.com/maevsi/sqitch/compare/3.2.3...3.2.4) (2024-02-24)


### Bug Fixes

* schedule release ([22a2fe8](https://github.com/maevsi/sqitch/commit/22a2fe882acfbc7702c031932315772c2b235029))

## [3.2.3](https://github.com/maevsi/sqitch/compare/3.2.2...3.2.3) (2024-02-10)


### Bug Fixes

* schedule release ([722f01c](https://github.com/maevsi/sqitch/commit/722f01cb91108966192d72cc399b23d79cb1ed85))

## [3.2.2](https://github.com/maevsi/sqitch/compare/3.2.1...3.2.2) (2024-01-27)


### Bug Fixes

* schedule release ([a989a23](https://github.com/maevsi/sqitch/commit/a989a237f01a0ad338a8d44f7f0b344094a00ab8))

## [3.2.1](https://github.com/maevsi/sqitch/compare/3.2.0...3.2.1) (2024-01-13)


### Bug Fixes

* schedule release ([d846cf4](https://github.com/maevsi/sqitch/commit/d846cf47473a250bd71b47f62585190b16a413bc))

## [3.2.0](https://github.com/maevsi/sqitch/compare/3.1.3...3.2.0) (2023-12-30)


### Features

* **authenticate:** allow function execution by account role ([9322aa8](https://github.com/maevsi/sqitch/commit/9322aa83c4763207263ab00621a1e2cd40d1987b))

## [3.1.3](https://github.com/maevsi/sqitch/compare/3.1.2...3.1.3) (2023-12-23)


### Bug Fixes

* schedule release ([6195d8b](https://github.com/maevsi/sqitch/commit/6195d8b728f192d8a02e43cba3d770901ac339d6))

## [3.1.2](https://github.com/maevsi/sqitch/compare/3.1.1...3.1.2) (2023-12-09)


### Bug Fixes

* schedule release ([fa3af03](https://github.com/maevsi/sqitch/commit/fa3af038461eeef346e8c072bd30d74f5c22dbcc))

## [3.1.1](https://github.com/maevsi/sqitch/compare/3.1.0...3.1.1) (2023-12-01)


### Bug Fixes

* **role-grafana:** correct variable usage ([5cedd46](https://github.com/maevsi/sqitch/commit/5cedd46398a653a66759161a735603acf0d9223e))

## [3.1.0](https://github.com/maevsi/sqitch/compare/3.0.8...3.1.0) (2023-11-21)


### Features

* **grafana:** add database and role ([d863139](https://github.com/maevsi/sqitch/commit/d863139f3df2e0a13af89c5bc095821e72ad5359))

## [3.0.8](https://github.com/maevsi/sqitch/compare/3.0.7...3.0.8) (2023-11-20)


### Bug Fixes

* **contact:** revert trigger creation ([3f4e92d](https://github.com/maevsi/sqitch/commit/3f4e92ddebac9fb23f1efcab89bf41b51bab2c16))

## [3.0.7](https://github.com/maevsi/sqitch/compare/3.0.6...3.0.7) (2023-11-17)


### Bug Fixes

* **contact:** prevent changes to own contact ([0c9d9e0](https://github.com/maevsi/sqitch/commit/0c9d9e07909a7d4d6df54106206a9eabdcca11ae))

## [3.0.6](https://github.com/maevsi/sqitch/compare/3.0.5...3.0.6) (2023-11-17)


### Bug Fixes

* **invite:** correct profile picture ([2fb5d4a](https://github.com/maevsi/sqitch/commit/2fb5d4a60f2b7fa6469c76206e34f26ce9f35563))

## [3.0.5](https://github.com/maevsi/sqitch/compare/3.0.4...3.0.5) (2023-11-11)


### Bug Fixes

* schedule release ([e19b71b](https://github.com/maevsi/sqitch/commit/e19b71bb7422b5cb5fe576c2fb0eda479832809b))

## [3.0.4](https://github.com/maevsi/sqitch/compare/3.0.3...3.0.4) (2023-11-03)


### Bug Fixes

* **invite:** correct output ([b882541](https://github.com/maevsi/sqitch/commit/b88254186d755278d76b52718edd00b2d42ebf78))
* **policy:** widen null checks ([6323cc4](https://github.com/maevsi/sqitch/commit/6323cc45da8d81798ab07d53e17c987dad5a569f))

## [3.0.3](https://github.com/maevsi/sqitch/compare/3.0.2...3.0.3) (2023-11-03)


### Bug Fixes

* account for empty account id ([fc75db7](https://github.com/maevsi/sqitch/commit/fc75db7b6dff797b30da372ba652244e6d03cba0))
* **upload:** correct revert script ([4bf4e9c](https://github.com/maevsi/sqitch/commit/4bf4e9c4730fc8fae10aff54cc6bf1c4f4c6396c))

## [3.0.2](https://github.com/maevsi/sqitch/compare/3.0.1...3.0.2) (2023-10-28)


### Bug Fixes

* schedule release ([5e95aa5](https://github.com/maevsi/sqitch/commit/5e95aa5f700fcefa04ff0e5c1506d1b02198ef08))

## [3.0.1](https://github.com/maevsi/sqitch/compare/3.0.0...3.0.1) (2023-10-14)


### Bug Fixes

* schedule release ([8cca5bd](https://github.com/maevsi/sqitch/commit/8cca5bd23f0b74f4764a5dced5538ef02aa7bb08))

## [3.0.0](https://github.com/maevsi/sqitch/compare/2.1.0...3.0.0) (2023-10-02)


### ⚠ BREAKING CHANGES

* **upload:** extract policy

### Features

* **upload:** extract policy ([36345ca](https://github.com/maevsi/sqitch/commit/36345ca7ae14e73f460c498810439644e481ff03))


### Bug Fixes

* **upload:** show for profile pictures ([dc2d592](https://github.com/maevsi/sqitch/commit/dc2d59233eb108100aa8ae1d4580de16d31971bb))

## [2.1.0](https://github.com/maevsi/sqitch/compare/2.0.0...2.1.0) (2023-09-26)


### Features

* **authenticate:** readd token check ([a17edf6](https://github.com/maevsi/sqitch/commit/a17edf6e98dc94551f2f659cb0e05e243cc24ce1))

## [2.0.0](https://github.com/maevsi/sqitch/compare/1.17.11...2.0.0) (2023-09-26)


### ⚠ BREAKING CHANGES

* **contact:** use `E.164` phone number format
* **email:** shorten and loosen format
* **docker:** mount entrypoint
* remove email address case restriction

### Features

* **contact:** use `E.164` phone number format ([92ac35d](https://github.com/maevsi/sqitch/commit/92ac35d22795f5ec8a1861c94a151bf76c735949))
* **docker:** mount entrypoint ([2572193](https://github.com/maevsi/sqitch/commit/25721933e677297ddf2af6d3f19e0ca0190887ab))
* **email:** shorten and loosen format ([9e6c62b](https://github.com/maevsi/sqitch/commit/9e6c62b8bf592bec1c657215b3f7ffc930217fc0))
* remove email address case restriction ([41e7eee](https://github.com/maevsi/sqitch/commit/41e7eeebff7482361f648a6e7ace53deaeab328f))
* **sql:** use uuids instead of ids ([277ec7f](https://github.com/maevsi/sqitch/commit/277ec7f759075395aaf507f45b1d294092b35c31))

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
