# Aiakos
Aiskos is an iOS framework for transformation and (de)serialization of JSON, XML and native objects

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## Features

- [x] Custom (de)serialization between native objects and JSON data

## Requirements

- iOS 9.1+ 
- Xcode 7.1+
- Currently I only test the framework on iOS, but porting to OSX is really easy (just copy the code, I believe it will work :)

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate Alamofire into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "zetasq/Aiakos"
```

Run `carthage` to build the framework and drag the built `Aiakos.framework` into your Xcode project.

### Manually

If you prefer not to use Carthage, you can integrate Aiakos into your project manually.

## Usage
> Due to Swift 2.1 reflection API's poor function, you need to make properties non-optional, otherwise Aiakos could not find the unwrapped type of your optional properties. So just make your properties non-optional and give each of them an initial value.

### (de)Serializing from/to JSON data

Just make your model object inherit from AiaModel, that's it :)
> All these property types are allowed: String(NSString), NSNumber, AiaModel, [String], [NSNumber], [String: String], [String: NSNumber]. I try to add [AiaModel] and [String: AiaModel], but I can't fetch the associated model type using reflection. I hope this can be fixed by Swift 3.0's more powerful reflection :)

```swift
import Aiakos

class MyModel: AiaModel {
    var args: [String: String] = [:]
    var origin: NSString = ""
    var version: NSNumber = 0
}
```
If you want to make a custom mapping between property names and JSON keys, conform your model to AiaJSONCustomPropertyMapping. Only properties whose name returned by customPropertyMapping will be (de)serialized from/to JSON data.
```swift
import Aiakos

class MySubModel: AiaModel, AiaJSONCustomPropertyMapping {
    var contentLength: String = ""
    var acceptedLanguage: String = ""
    var acceptedEncoding: String = ""
    var xForwardedPort: String = ""
    var xForwardedFor: String = ""

    static var customPropertyMapping: [String: String] {
        return [
            "contentLength": "Content-Length",
            "acceptedLanguage": "Accept-Language",
            "acceptedEncoding": "Accept-Encoding",
            "xForwardedPort": "X-Forwarded-Port",
            "xForwardedFor": "X-Forwarded-For",
        ]
    }
}
```
Deserialize JSON by using AiaConverter's class methods (for detailed list of methods, check AiaConverter's API):
```swift
import Aiakos

func test() {
    Alamofire.request(.GET, "https://api.github.com/users/mralexgray/repos")
        .response { (request, response, data, error) -> Void in
            do {
                let models = try AiaConverter.modelArrayOfType(MyModel.self, fromJSONArrayData: data!)
                print(models)
            } catch {
                print(error)
            }
    }
}
```
