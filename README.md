# NavHelper

The main purpose of the library is to handle the view presentation of the app.

## Installation

### Swift Package Manager

1. In Xcode File/Swift Package/Add Package Dependency
2. Add the following link to the Search field of Choose Package repository window of Xcode:

	```
	https://github.com/BalazsSzamody/NavHelper
	```
3. Select version
4. Select package component.
5. Finish

## Usage

#### 1. Import `NavHelper`

#### 2. Create project specific `ViewControllerDetails`
```Swift
enum VCDetails: ViewControllerDetails {
    case root
    case second
    case customViews
    case tappableView
    case radioButtons
    
    var storyboard: String {
        switch self {
        case .root,
             .second,
             .customViews,
             .tappableView,
             .radioButtons:
            return "Main"
        }
    }
    
    var type: UIViewController.Type? {
        switch self {
        case .customViews:
            return CustomViewsViewController.self
        case .tappableView:
            return TappableTextViewController.self
        case .radioButtons:
            return RadioButtonsViewController.self
        case .root:
            return RootViewController.self
        case .second:
            return SecondViewController.self
        }
    }
}
```

#### 3. Create class

```Swift
class NavHelperImp: NavHelper {
    var rootViewController: UIViewController?
    // Add project specific properties and initializer
}
```

#### 4. Extend `UIViewController`

```Swift
extension UIViewController: NavHelperUsing {
    public var navHelper: NavHelper {
        NavHelperImp()
    }
}
```

#### 5. Add project specific extensions (optional)

```Swift
extension NavHelper {
    func presentWebView(sender: UIViewController, urlLink: String, title: String?, dismiss: (() -> Void)?) {
        let webVC = WebViewController()
        webVC.data = urlLink
        webVC.title = title
        webVC.dismissCompletion = dismiss
        sender.present(webVC, animated: true, completion: nil)
    }
}

extension NavHelperUsing where Self: UIViewController {
    func presentWebView(urlLink: String, title: String?, dismiss: (() -> Void)?) {
        navHelper.presentWebView(sender: self, urlLink: urlLink, title: title, dismiss: dismiss)
    }
}
```

#### 6. Add project specific `NavHelperStoryboardResolveDelegate` if default isn't suitable (optional)

#### 7. Use `NavHelperUsing` methods in `UIViewControllers` for initiating app navigation

