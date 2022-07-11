How to upgrade? 
====================
If you want to upgrade you sdk to the lastest, please check the following points:

## Version
The latest version is `5.1.0`, you can upgrade sdk by [CocoaPods](https://cocoapods.org/).

For example:

if you use [CocoaPods](https://cocoapods.org/), please make sure you pod repo contains `5.1.0`, you can use `pod search Airwallex` to check it. Otherwise, you should update pod repo before upgrade.


## Fetch updated library

If you already use specific sdk version in Podfile, please modify the line related to Airwallex SDK as follows:

```
pod 'Airwallex', '~> 5.1.0'
```

Otherwise, just use `pod update Airwallex` in terminal to update Airwallex SDK.
