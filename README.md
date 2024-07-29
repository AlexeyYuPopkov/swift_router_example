# iOS Navigation: A Compact Router Approach

In iOS navigation APIs, whether using `UIKit` or `SwiftUI`, the current screen is typically responsible for creating the subsequent screen. This approach has several disadvantages:

- **Increased Complexity and Violation of the Single Responsibility Principle (SRP):** The screen (view controller or view) now handles not only its primary responsibility of managing the UI and user interactions but also the navigation logic, including creating other screens with their dependencies. This dual responsibility increases complexity, making the screen harder to understand at a glance.

- **Limited Reusability:** When a screen is responsible for its navigation, it becomes challenging to reuse that screen in different contexts where different navigation behavior is needed. This reduces the flexibility and reusability of the screen across the app.

- **Tight Coupling:** This approach creates tight coupling between screens, as each screen needs to know about the subsequent screens it can navigate to. This can lead to a fragile architecture where changes in one screen might necessitate changes in others.

The existing approach to mitigate these issues is the Coordinator pattern, which significantly improves the architecture of iOS applications. However, it often introduces a lot of boilerplate code and can be hard to read. Additionally, understanding a complex navigation scenario involving multiple screens across several levels may require reviewing the code of multiple coordinators, which can be time-consuming.

The approach described below is, in my opinion, more straightforward and requires less boilerplate code. It has been thoroughly tested and is used in several iOS applications based on `UIKit`. As for `SwiftUI`, it leverages APIs introduced in iOS 16 and later, making its adoption a topic of discussion.

Let's dive in. The approach that I am using is based on the idea that screens with transitions to other screens should include a closure to describe these transitions:


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
        case onFeature1(UIViewController, /* parameters */)
        case onFeature2(UIViewController, /* parameters */)
    }
}
```

In this example, to perform a transition to another screen, we call the `onRoute` closure with the relevant `Route` case. If necessary, this case can include any parameters needed by the next screen. Notably, `ViewController` does not contain any navigation logic and does not know anything about the screens it transitions to.


Now, let's dive into the `Router` implementation. The [video](https://alexeyyupopkov.github.io/swift_router_example/router_example.mov) demonstrates the behavior we aim to achieve.

Let's start with the `SceneDelegate`:

```swift
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
	// 1
        let router = HomeRouter()
	// 2        
        let vc = router.initialScreen()
	// 3
        window.rootViewController = vc
        self.window = window
        window.makeKeyAndVisible()
    }
}
```

Here we are:
1. Creating an instance of `HomeRouter`, which is responsible for managing navigation.
2. Using the router to get the initial view controller that should be displayed.
3. Setting the `rootViewController` of the window to the initial view controller.

Next, let's implement `HomeRouter`:

```swift
final class HomeRouter {
    // 1
    func initialScreen() -> UIViewController {
        let vc = createInitialScreen()
        let nc = UINavigationController(rootViewController: vc)
        return nc
    }
}

extension HomeRouter {
    private func createInitialScreen() -> UIViewController {
        // 2
        let vc = HomeVC(nibName: nil, bundle: nil)
        // 3
        vc.onRoute = {
            switch $0 {
            case .pushTestScreenUIKit(let sender):
                self.pushTestScreenUIKit(sender)
            case .presentTestScreenUIKit(let sender):
                self.presentTestScreenUIKit(sender)
            case .onPushTestScreenSwiftUI(let sender):
                self.pushTestScreenSwiftUI(sender)
            case .onPresentTestScreenSwiftUI(let sender):
                self.presentTestScreenSwiftUI(sender)
            }
        }

        return vc
    }
}

// MARK: - Push and Present Test Screen UIKit
// 4
extension HomeRouter {
    private func pushTestScreenUIKit(_ sender: UIViewController) {
        let vc = TestScreenUIKit(nibName: nil, bundle: nil)
        sender.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func presentTestScreenUIKit(_ sender: UIViewController) {
        let vc = TestScreenUIKit(nibName: nil, bundle: nil)
        sender.navigationController?.present(vc, animated: true)
    }
}

// MARK: - Push SwiftUI Test Screen
extension HomeRouter {
    private final class Box {
        weak var vc: UIViewController!
    }
    
    private func pushTestScreenSwiftUI(_ sender: UIViewController) {
        let box = Box()
        
        let view = TestScreenSwiftUI(
            isModal: false,
            onRoute: {
                switch $0 {
                case .onPushAnotherTestScreen:
                    self.pushPushAnotherTestScreen(sender: box)
                case .onPresentAnotherTestScreen:
                    self.presentAnotherTestScreen(sender: box)
                case .onBack:
                    break
                }
            }
        )
        
        let vc = UIHostingController(rootView: view)
        
        // 5
        box.vc = vc
        
        sender.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func pushPushAnotherTestScreen(sender: Box) {
        let vc = UIHostingController(rootView: AnotherTestScreenSwiftUI())
        sender.vc.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func presentAnotherTestScreen(sender: Box) {
        let vc = UIHostingController(rootView: AnotherTestScreenSwiftUI())
        sender.vc.present(vc, animated: true)
    }
}

// MARK: - Present SwiftUI Feature
extension HomeRouter {
    private func presentTestScreenSwiftUI(_ sender: UIViewController) {
        // 6
        let router = SwiftUIRouter()
        
        // 7
        let vc = router.initialScreen()
        vc.modalPresentationStyle = .fullScreen
        
        router.onRoute = { [weak vc] in
            switch $0 {
            case .onBack:
                vc?.dismiss(animated: true)
            }
        }
        
        sender.present(vc, animated: true)
    }
}
```

Explanation:

1. **Get the root screen:** Only one public method here, providing the initial view controller.
2. **Assembly of the initial screen:** The router serves as a good place to assemble new screens and set up their dependencies. Alternatively, a separate class with factory methods can be used for screen assembly and dependency injection.
3. **Setting up transitions to other screens:** The router handles transitions based on the `onRoute` cases. It can pass the sender `UIViewController` and any required parameters to the next screen. Note that we do not use `[weak self]` here; the `Router` is captured as a strong reference because the screen implicitly owns it.
4. **Push or present new screens:** The router assembles and sets up dependencies for the new screens, then displays them using the sender's `navigationController`.
5. **`SwiftUI` screen transition:** This demonstrates transitioning to a screen implemented in `SwiftUI`, including a workaround to access the `UIHostingController` sender.
6. **Transition to another `Router`:** This example shows how to transition to another router implemented in the `SwiftUI` style.
7. **Getting the root screen of the new Router:** We can present the initial screen of the new router, but we cannot push it into the navigation stack. This is because `UIKit` and `SwiftUI` navigation stacks cannot be mixed directly; they must be managed separately.

The transition to navigation in `SwiftUI` style is demonstrated below:

```swift
// 1
final class SwiftUIRouter: ObservableObject, OnRouteProtocol {
    enum Route {
        case onBack
    }
    
    var onRoute: ((Route) -> Void)?
    
    @Published var path = NavigationPath()
    
    // 2
    func initialScreen() -> UIViewController {
        return UIHostingController(rootView: InitialView(router: self))
    }
}

extension SwiftUIRouter {
    // 3
    struct InitialView: View {
        @StateObject var router: SwiftUIRouter
        @State var modalView: TestScreenSwiftUI.Route?
        
        var body: some View {
            NavigationStack(path: $router.path) {
                TestScreenSwiftUI(
                    isModal: true,
                    onRoute: {
                    switch $0 {
                    case .onPushAnotherTestScreen:
                        router.path.append($0)
                    case .onPresentAnotherTestScreen:
                        modalView = $0
                    case .onBack:
                        self.router.onRoute?(.onBack)
                    }
                }
                )
                .navigationDestination(for: TestScreenSwiftUI.Route.self, destination: showScreen)
                .sheet(item: $modalView, // or .fullScreenCover
                       onDismiss: { modalView = nil },
                       content: showScreen)
            }
        }
    }
}

extension SwiftUIRouter.InitialView {
    @ViewBuilder func showScreen(_ route: TestScreenSwiftUI.Route) -> some View {
        switch route {
        case .onPushAnotherTestScreen:
            AnotherTestScreenSwiftUI()
        case .onPresentAnotherTestScreen:
            AnotherTestScreenSwiftUI()
        case .onBack:
            fatalError("Impossible case")
        }
    }
}
```

Explanation:

1. Since `SwiftUIRouter` in current example isn't the root router, it have to be able to return control to previous `Router`. Therefore, `OnRouteProtocol` must be implemented to provide the appropriate option. Moreover, `SwiftUIRouter` must be an `ObservableObject` and must have a `NavigationPath` `@Published` `var` to use the `SwiftUI` navigation approach introduced in iOS 16.
2. To transist from `UIKit` API to `SwiftUI` API, initial view should be wrapped in `UIHostingController`
3. The following is a typical implementation of navigation using `SwiftUI` API introduced in iOS 16. 


## Conclusions

The approach outlined here simplifies navigation management in iOS applications by separating navigation logic from UI components, adhering to the Single Responsibility Principle, and reducing boilerplate code. It enhances code readability and maintainability by using closures for handling screen transitions.

For best practices, it's recommended to keep the number of screens managed by a single router balanced—neither too many, which would reduce readability, nor too few, which would unnecessarily increase the number of routers. The router should ideally describe a holistic business scenario, ensuring the code remains understandable and maintainable.

This compact and efficient approach to navigation can significantly enhance the architecture of iOS applications, making them more robust and scalable. For a complete example of this implementation, [click here](https://github.com/AlexeyYuPopkov/swift_router_example).



