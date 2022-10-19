# FileGen

FileGen makes creating, composing, generating, and writing file contents easy.

## Basics

Create a basic file like this:

```swift
let file = File(name: "test.txt", contents: "Hello, World!")
```

And then save it to a directory like this:

```swift
let directory = URL(fileURLWithPath: "/tmp")
try file.write(into: directory)
```

> /tmp/test.txt
> ``` 
> Hello, World! 
> ```

## Beyond the Basics

### Builder Syntax

Use builder syntax to build up your files:

```swift
let file = File("queen.txt") {
    for _ in 1...3 {        
        "Dum..."
    }
    "Another one bites the dust!"
}
```

> queen.txt
> ```
> Dum...
> Dum...
> Dum...
> Another one bites the dust!
> ```

### Lists

Create formatted lists from an array of items:

```swift
let fruits = ["🍎", "🍑", "🍊", "🍉"]
let file = File("shopping.txt") {
    List(fruits) { fruit in
        "- \(fruit)"
    }
}
```

> shopping.txt
> ```
> - 🍎 
> - 🍑
> - 🍊
> - 🍉
> ```

### Interpolation

Use interpolation to dynamically generate and insert content

```swift
enum Statics: InterpolationKey {} 
let methods = ["GET", "POST", "UPDATE", "DELETE"]
let file = File("HTTPMethods.swift") {
    """
    import Foundation
    
    enum HTTPMethods {
        \(Statics.self)
    }
    """
}.value(for: Statics.self) {
    List(methods, separatedBy: "\n") { method in
        """
        /// HTTP Method: `\(method)`
        static let \(method.lowercased()) = "\(method)" 
        """
    }
}
```

> HTTPMethods.swift
> 
> ```
> import Foundation
> 
> enum HTTPMethods {
>     /// HTTP Method: `GET`
>     static let get = "GET"
>
>     /// HTTP Method: `POST`
>     static let post = "POST"
>
>     /// HTTP Method: `UPDATE`
>     static let update = "UPDATE"
>
>     /// HTTP Method: `DELETE`
>     static let delete = "DELETE"
> }
> ```

### Future Features

- Read an existing file and append to or update its contents
