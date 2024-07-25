# iOS Navigation: A Compact Router Approach

In iOS navigation APIs, whether using `UIKit` or `SwiftUI`, the current screen is typically responsible for creating the subsequent screen. Here are some of them:

- The screen (view controller or view) now handles not only its primary responsibility of managing the UI and user interactions but also the navigation logic. This makes the screen more complex and harder to understand at a glance.

- When a screen is responsible for its navigation, it becomes challenging to reuse that screen in different contexts where different navigation behavior is needed. This reduces the flexibility and reusability of the screen across the app.

- Violates the Single Responsibility Principle. The screen should be responsible making layout not for creation another screen with its dependencies. Therefore, there are difficulties with unit testing this screen, in isolation from the rest

There already exist an approach without these cons. It is Coordinator pattern, significant step to achve better architecture of iOS applications. But, as for me, it has a lot of boilerplate code and hard readable. Moreover to understand a complex navigation scenario involving multiple screens across several levels, one needs to review the code of multiple coordinators, which can be time-consuming.

The approach described below is, in my opinion, more straightforward and requires less boilerplate code. It has been thoroughly tested and is used in several iOS applications based on `UIKit`. As for `SwiftUI`, it leverages APIs introduced in iOS 16 and later, making its adoption a topic of discussion.

Let's dive in. My approach is based on the idea that screens with transitions to other screens should include a closure to describe these transitions:


```swift
protocol OnRouteProtocol {
    associatedtype Route
    var onRoute: ((Route) -> Void)? { get set }
}
```

Here's an example of how to use this:

```swift
final class ViewController: UIViewController, OnRouteProtocol {
    var onRoute: ((Route) -> Void)?

    // ... layout is ommited

    @objc func onFeature1ButtonAction(sender: UIButton) {
        onRoute?(.onFeature1(self))
    }

    @objc func onFeature2ButtonAction(sender: UIButton) {
        onRoute?(.onFeature2(self))
    }
}

extension ViewController {
    enum Route {
        case onFeature1(ViewController)
        case onFeature2(ViewController)
    }
}
```

Note that `ViewController` does not contain any navigation logic and does not know anything about the screens it transitions to.

Now, let's dive into the `Router` implementation.


