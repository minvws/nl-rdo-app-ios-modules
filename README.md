# RDO Modules

This package contains:

- [Luhn Check](/Sources/LuhnCheck/LuhnCheck.md) for validating tokens
- [QRGenerator](/Sources/QRGenerator/QRGenerator.md) to assist creating a QR-code
- [OpenIDConnect](/Sources/OpenIDConnect/OpenIDConnect.md) to assist connecting to OpenID
- HTTP Security (todo)

## Installation

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding RDO Modules as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/minvws/nl-rdo-app-ios-modules.git", .upToNextMajor(from: "1.0.0"))
]
```

## Contribution

The development team works on the repository in a private fork (for reasons of compliance with existing processes) and shares its work as often as possible. 

If you plan to make non-trivial changes, we recommend to open an issue beforehand where we can discuss your planned changes. This increases the chance that we might be able to use your contribution (or it avoids doing work if there are reasons why we wouldn't be able to use it).

Git commits must be signed https://docs.github.com/en/github/authenticating-to-github/signing-commits

## License

License is released under the EUPL 1.2 license. [See LICENSE](https://github.com/minvws/nl-rdo-app-ios-modules/blob/master/LICENSE.txt) for details.





