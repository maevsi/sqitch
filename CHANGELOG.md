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
