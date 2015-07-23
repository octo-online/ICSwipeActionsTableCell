# ICSwipeActionsTableCell

[![CocoaPods](https://img.shields.io/cocoapods/v/ICSwipeActionsTableCell.svg)](https://github.com/imaginary-cloud/ICSwipeActionsTableCell) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

This is a simple Swift class that lets you add as many additional buttons to a table view cell as you like :-)
It's written in Swift 2.0 and takes full advantage of it's features, making it super simple tu use.

Here are the steps:

## Install with CocoaPods or Carthage

###[CocoaPods](http://cocoapods.org) 

Podfile

```ruby
use_frameworks!

pod 'ICSwipeActionsTableCell'
```

###[Carthage](https://github.com/Carthage/Carthage) 

Add the following line to your Cartfile:

```
github "imaginary-cloud/ICSwipeActionsTableCell" >= 0.1
```
And run `carthage update` to build the dynamic framework.

## How to use
You just subclass you own cell with ICSwipeActionsTableCell:

```swift
class ICDemoTableViewCell: ICSwipeActionsTableCell
```

Provide the button titles you want to show:
```swift
cell.buttonsTitles = ["MORE", "DELETE"] 
```

And the delegate to forward the calbacks:
```swift
cell.delegate = self
```

You're done with the basic setup, but if you want more then that you can go much further:

It uses differen tuple types to set multiple parameters on the buttons for ex:
```swift
cell.buttonsTitles = [(title:"FROG", color:UIColor.greenColor(), textColor:UIColor.whiteColor())] 
cell.buttonsTitles = [(title:"FROG", color:UIColor.greenColor()), (title:"LION", color:UIColor.yellowColor())] 
```
It'll automatically check for the provided type so all you have to worry about is choosing one you like.

You can also change default buttons side margins
```swift
cell.buttonsSideMargins = 5
```

If you want all buttons to be the same width, set buttonsEqualSize flag true.
```swift
cell.buttonsEqualSize = true
```
![alt tag](http://i.imgur.com/LpO7FQu.png)

Stay tuned! This library is not left here on it's own. More features and customisations will come! Please submit issues with you suggestions :-)

## Support

Supports iOS 8 and above. Xcode 7.0 is required to build the latest code written in Swift 2.0

## License

Copyright © 2015 ImaginaryCloud, imaginarycloud.com. This library is licensed under the MIT license.
