# Aiakos
Aiskos is an iOS framework for transformation and (de)serialization between JSON and model objects

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## Features

- [x] Automatic (de)serialization between model objects and JSON data with custom options.
- [x] Automatic archive/unarchive of model objects.

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
> Due to Swift 2.1 reflection API's poor function, you need to make properties **non-optional**, otherwise Aiakos could not find the unwrapped type of your optional properties. So just make your properties non-optional and give each of them an initial value.

### (de)Serializing from/to JSON data

Just make your model object inherit from AiaModel, that's it :)
> All these property types are allowed: **String(NSString), NSNumber, AiaModel, [String], [NSNumber], [AiaModel], [String: String], [String: NSNumber], [String: AiaModel]**.If you use property of type **[AiaModel]** or **[String: AiaModel]**, be sure to override **modelContainerPropertyAnnotation** in your model type.

```swift
import Aiakos

class MyModel: AiaModel {
    var args: [String: String] = [:]
    var origin: NSString = ""
    var version: NSNumber = 0
    
    var subModels: [MySubModel] = []
    var modelDic: [String: MySubModel] = [:]
    
    override class var modelContainerPropertyAnnotation: [String: AiaModelContainerPropertyType]? {
        return [
            "subModels": .ArrayOfModel(MySubModel.self),
            "modelDic": .DictionaryOfModel(MySubModel.self)
        ]
    }
}
```
If you want to make a custom mapping between property names and JSON keys, conform your model to **AiaJSONCustomPropertyMapping**. Only properties whose name returned by **customPropertyMapping** will be (de)serialized from/to JSON data.
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
(De)serialize JSON by using **AiaConverter**'s class methods (for detailed list of methods, check **AiaConverter**'s API):
```swift
import Aiakos

func test() {
    Alamofire.request(.GET, "https://api.github.com/users/mralexgray/repos")
        .response { (request, response, data, error) -> Void in
            do {
                let models = try AiaConverter.modelArrayOfType(MyModel.self, fromJSONArrayData: data!) // deserializing
                
                let recreatedData = try AiaConverter.jsonArrayDataFromModelArray(models) // serializing
            } catch {
                print(error)
            }
    }
}
```
## Persistence

Aiakos doesn't automatically persist your objects for you. However, `AiaModel`
does conform to `<NSCoding>`, so model objects can be archived to disk using
`NSKeyedArchiver`. **Caution: Here AiaJSONCustomPropertyMapping is also used to map property names.**
