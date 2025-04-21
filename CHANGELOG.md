# Changelog

## [0.1.0](https://github.com/jq-sh/jq-sh/compare/v0.0.2...v0.1.0) (2025-04-21)


### Features

* add color pallet to bash--script ([a937f84](https://github.com/jq-sh/jq-sh/commit/a937f84c300549e6e228800f84ce08718e5e549d))
* Add column truncation using `%n,m` ([348b5d4](https://github.com/jq-sh/jq-sh/commit/348b5d4f1948ca5a8299c3a8aaa28e4d7f467e6f))
* add filtering to json2table ([aa17b27](https://github.com/jq-sh/jq-sh/commit/aa17b27fe5830d45f1b8c5887e2191fe800d2cc7))
* Add jwt-decode script ([ce62b6f](https://github.com/jq-sh/jq-sh/commit/ce62b6f1ada553048d7f81f2b830657e61ad5a4c))
* Allow adjustable truncation end_size ([0157a1d](https://github.com/jq-sh/jq-sh/commit/0157a1d5de9c1c2896d01581ad9787cfbc8f0eec))
* colorizing timestamps using YEAR|MONTH|DAY|HOUR|MIN as well as SEC ([7f66c06](https://github.com/jq-sh/jq-sh/commit/7f66c06de81cb84fa4c03d99c7fe1dc41f081566))
* multiline strings with a single timestamp ([76f9f16](https://github.com/jq-sh/jq-sh/commit/76f9f16e99868825602b60b1db4b5eb986513ddb))
* Multiple `resources` can be rendered at once ([b1c7d47](https://github.com/jq-sh/jq-sh/commit/b1c7d478e11a5901aa7a5c827246efbb2359359e))
* re-implement colors in jq ([43f8c15](https://github.com/jq-sh/jq-sh/commit/43f8c151f65a0034b6e0d7c4165b9bdfbfeb64d5))
* Render multi-line data in a single line cell ([8ae4875](https://github.com/jq-sh/jq-sh/commit/8ae4875f85bf1bd112e8956efe6b374c0e919163))
* restrict table to specific `max_width` ([2658fe1](https://github.com/jq-sh/jq-sh/commit/2658fe11287a21f2beb07f63d4693b1e9eb5524a))
* unsorted cols by default ([27a7644](https://github.com/jq-sh/jq-sh/commit/27a7644fcd282efeed3f356482b23d17f5dfae74))
* Use all but the excluded cols ([ed86fcd](https://github.com/jq-sh/jq-sh/commit/ed86fcdd56949d88293fc7c817141a7e4d03be72))
* Use bash--script ([a82b647](https://github.com/jq-sh/jq-sh/commit/a82b64721f54b7f648fc3ff2095e575ab7d7e214))


### Bug Fixes

* add some minor backports ([fa30145](https://github.com/jq-sh/jq-sh/commit/fa30145fa8c2f5dcd0f3b27db418a47723ecc156))
* allow exit without_help ([92f33df](https://github.com/jq-sh/jq-sh/commit/92f33df7d8630b3f41092beae4f177fb8e3cfd9d))
* Allow spaces in json2table keys ([2109e33](https://github.com/jq-sh/jq-sh/commit/2109e336ea3d99fb1ec29a9f1583081b7f80bdcc))
* Allow underscore prefixed keys in json2table ([6a6a65e](https://github.com/jq-sh/jq-sh/commit/6a6a65e834ba7ec1c20a7711f7782fea84fcb651))
* color_terms now splits on newlines (again) ([3bc3c76](https://github.com/jq-sh/jq-sh/commit/3bc3c765cbf79d0e075f7851dc7fb1caf2f3dfbf))
* deprecation warnings on github runners ([4e97201](https://github.com/jq-sh/jq-sh/commit/4e97201d7442f57baa9bb036b90b56dd426f3cbf))
* don't blow up when pattern matching on null ([1771693](https://github.com/jq-sh/jq-sh/commit/177169324b2ccac9b21df0fcc8b146050ffc4804))
* handle false & null ([9e31faf](https://github.com/jq-sh/jq-sh/commit/9e31faf72de1979b7439bcab9dc313ddd8f3c822))
* jsont shpecs ([fef3626](https://github.com/jq-sh/jq-sh/commit/fef3626121990100fa5129675e13c3a781e190e8))
* jwt-decode add moar shpecs ([400738a](https://github.com/jq-sh/jq-sh/commit/400738ab38fd3ef6ad477857f31a16c27e6a299d))
* remove unused file ([0a50599](https://github.com/jq-sh/jq-sh/commit/0a505998a7e62ed116af3e42f2f5ee2ed8930141))
* shpecs ([fa9e52a](https://github.com/jq-sh/jq-sh/commit/fa9e52a3ad4fa3ce3f14fe12c448f46ee558985e))
* strip color from eval_cmd ([7744c8a](https://github.com/jq-sh/jq-sh/commit/7744c8a4272fecdced133ee429c878273d60f2d6))
* timestamps in tests ([0d72728](https://github.com/jq-sh/jq-sh/commit/0d72728f01b46d6c44657f1f2c13199d36474161))
* timestamps in utc ([5dcf2fa](https://github.com/jq-sh/jq-sh/commit/5dcf2fab287e06dcd44422d95ecb7e3e2b91d8ef))

### [0.0.2](https://github.com/jq-sh/jq-sh/compare/v0.0.1...v0.0.2) (2022-05-01)


### Bug Fixes

* typo in color screencast ([6185765](https://github.com/jq-sh/jq-sh/commit/618576562444f911dc6278bf95cdf7d3bf1344c5))
