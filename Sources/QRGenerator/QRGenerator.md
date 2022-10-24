# QRGenerator

This package contains a helper method to generate a QR code from a String.

There are four error correction levels:

- .**low** (L) : correct up to 7% data corruption
- .**medium** (M) : correct up to 15% data corruption
- .**quartile** (Q) : correct up to 25% data corruption
- .**high** (H) : correct up to 30% data corruption

## Usage

To generate a QR code from a String:

```swift
import QRGenerator
import UIKit

let message: String = "This is awesome"
if let qrCode = message.generateQRCode(correctionLevel: .medium) {
  // qrCode is a UIImage
  // ...
}

```

To generate a QR code from Data:

```swift
import QRGenerator
import UIKit

let data: Data = "This is awesome data".data(using: .utf8)
if let qrCode = data?.generateQRCode(correctionLevel: .medium) {
  // qrCode is a UIImage
  // ...
}

```

## License

License is released under the EUPL 1.2 license. [See LICENSE](https://github.com/minvws/nl-rdo-app-ios-modules/blob/master/LICENSE.txt) for details.
