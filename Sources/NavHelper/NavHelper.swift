import UIKit

public protocol ViewControllerDetails {
    var storyboard: String { get }
    var type: UIViewController.Type? { get }
}

extension ViewControllerDetails {
    public var id: String {
        guard let type = type else {
            return ""
        }
        return String(describing: type)
            .components(separatedBy: ".")
            .last ?? ""
    }
}

public protocol NavHelperStoryboardResolveDelegate: AnyObject {
    func resolveViewController<VCType>(name: String, withType type: VCType.Type?, from bundle: Bundle?) -> VCType? where VCType: UIViewController
}

public protocol NavHelper: NavHelperStoryboardResolveDelegate {
    typealias Details = ViewControllerDetails
    
    var delegate: NavHelperStoryboardResolveDelegate? { get }
    
    var rootViewController: UIViewController? { get set }
    
    // get the viewcontroller from Storyboard using identifier:
    func viewControllerFromStoryboard<VCType>(_ name: String, withType type: VCType.Type?) -> VCType? where VCType: UIViewController
    
    @discardableResult
    func setRootViewController<PresenteeType>(_ rootAppUIVc: Details, type: PresenteeType.Type?, beforeLoad: ((PresenteeType?) -> Void)?) -> PresenteeType? where PresenteeType: UIViewController
    
    func showRootTabBarViewControllerWithIndex(index: Int, pageIndex: Int?, prepare: ((UIViewController) -> Void)?)

    //Add application navhelper specific funcs below:
    @discardableResult
    func present<PresenteeType>(_ presentee: Details,type: PresenteeType.Type?, over presenter: UIViewController, animated flag: Bool, beforeLoad:((PresenteeType) -> Void)?, completion: (() -> Void)?) -> PresenteeType? where PresenteeType: UIViewController
    
    @discardableResult
    func show<PresenteeType>(_ presenteeAppUIVc: Details, type: PresenteeType.Type?, presenter: UIViewController, beforeLoad:((PresenteeType) -> Void)?) -> PresenteeType? where PresenteeType: UIViewController
    
    func dismiss(_ vc: UIViewController, animated flag: Bool, completion: (() -> Void)?)
    func pop(_ vc: UIViewController, animated flag: Bool)
    func pop(_ vc: UIViewController, to viewController: UIViewController, animated flag: Bool)
    func popToRoot(_ vc:UIViewController, animated flag: Bool)
    
    // Function used to pop to the root controller and then push the desired controller in one push animation
    // having the effect of pushing directly to the desired controller
    func popToRoot<PresenteeType>(_ vc: UIViewController, type: PresenteeType.Type?, andShow presenteeAppUIVc: Details, beforeLoad: ((PresenteeType) -> Void)?) where PresenteeType: UIViewController
    
    // Function used to pop to the root controller and then push the desired controller in one pop animation
    // having the effect of popping directly to the desired controller in the stack (when in fact a new
    // instance of that controller has been added)
    func popToRoot(_ vc: UIViewController, andShowUsingPopAnimation presenteeAppUIVc: Details, beforeLoad: ((UIViewController) -> Void)?)
}

public extension NavHelper {
    
    weak var delegate: NavHelperStoryboardResolveDelegate? {
        return self
    }
    
    func setRootViewController(_ rootAppUIVc: Details) {
        setRootViewController(rootAppUIVc, type: rootAppUIVc.type, beforeLoad: nil)
    }
    
    func showRootTabBarViewControllerWithIndex(index: Int, pageIndex: Int?) {
        showRootTabBarViewControllerWithIndex(index: index, pageIndex: pageIndex, prepare: nil)
    }
    
    func viewControllerFromStoryboard<VCType>(_ name: String, withType type: VCType.Type?) -> VCType? where VCType: UIViewController {
        return delegate?.resolveViewController(name: name, withType: type, from: nil)
    }
    
    @discardableResult
    func setRootViewController<PresenteeType>(_ rootAppUIVc: Details, type: PresenteeType.Type?, beforeLoad: ((PresenteeType?) -> Void)?) -> PresenteeType? where PresenteeType : UIViewController {
        guard let topOptimalWindow = UIApplication.shared.delegate?.window,
            let topWindow = topOptimalWindow,
            let type = type else {
                return nil
        }
        
        func setViewController(_ vc: PresenteeType?) {
            beforeLoad?(vc)
            topWindow.rootViewController = vc
            self.rootViewController = vc
        }
        
        let presentedViewController = topWindow.rootViewController?.presentedViewController
        //If the root view controller is presenting a navigation controller, it doesn't get deallocated when updating the root view controller for the window
        let vc = viewControllerFromStoryboard(rootAppUIVc.storyboard, withType: type)
        if presentedViewController is UINavigationController {
            presentedViewController?
                .dismiss(animated: false, completion: {
                    setViewController(vc)
                })
        } else {
            setViewController(vc)
        }
        
        return vc
    }
    
    func showRootTabBarViewControllerWithIndex(index: Int, pageIndex: Int?, prepare: ((UIViewController) -> Void)?) {
        fatalError("Not implemented")
    }
    
    //Add application navhelper specific funs below:
    @discardableResult
    func present<PresenteeType>(_ presentee: Details, type: PresenteeType.Type?, over presenter: UIViewController, animated flag: Bool, beforeLoad: ((PresenteeType) -> Void)?, completion: (() -> Void)?) -> PresenteeType? where PresenteeType : UIViewController {
        guard let vc = viewControllerFromStoryboard(presentee.storyboard, withType: presentee.type) as? PresenteeType else {
            return nil
        }

        beforeLoad?(vc)
        
        presenter.present(vc, animated: flag, completion: completion)
        return vc
    }
    
    @discardableResult
    func show<PresenteeType>(_ presenteeAppUIVc: Details, type: PresenteeType.Type?, presenter: UIViewController, beforeLoad: ((PresenteeType) -> Void)?) -> PresenteeType? where PresenteeType : UIViewController {
        guard let vc = viewControllerFromStoryboard(presenteeAppUIVc.storyboard, withType: presenteeAppUIVc.type) as? PresenteeType else {
            return nil
        }
        
        beforeLoad?(vc)
        presenter.show(vc, sender: presenter)
        return vc
    }
    
    func dismiss(_ vc: UIViewController, animated flag: Bool = true, completion: (() -> Void)? = nil) {
        vc.dismiss(animated: flag, completion: completion)
    }
    
    func pop(_ vc: UIViewController, animated flag: Bool) {
        vc.navigationController?.popViewController(animated: flag)
    }
    
    func pop(_ vc: UIViewController, to viewController: UIViewController, animated flag: Bool) {
        vc.navigationController?.popToViewController(viewController, animated: flag)
    }
    
    func popToRoot(_ vc: UIViewController, animated flag: Bool) {
        vc.navigationController?.popToRootViewController(animated: flag)
    }
    
    // Function used to pop to the root controller and then push the desired controller in one push animation
    // having the effect of pushing directly to the desired controller
    func popToRoot<PresenteeType>(_ vc: UIViewController, type: PresenteeType.Type?, andShow presenteeAppUIVc: Details, beforeLoad: ((PresenteeType) -> Void)?) where PresenteeType: UIViewController {
        guard let vcToShow = viewControllerFromStoryboard(presenteeAppUIVc.storyboard, withType: presenteeAppUIVc.type) as? PresenteeType, let firstVC = vc.navigationController?.viewControllers.first else {
            return
        }
        beforeLoad?(vcToShow)
        // Insert the new controller just after the root controller
        let newVcStack = [firstVC, vcToShow]
        // Set the view controller stack as the newVcStack and push
        vc.navigationController?.setViewControllers(newVcStack, animated: true)
    }
    
    // Function used to pop to the root controller and then push the desired controller in one pop animation
    // having the effect of popping directly to the desired controller in the stack (when in fact a new
    // instance of that controller has been added)
    func popToRoot(_ vc: UIViewController, andShowUsingPopAnimation presenteeAppUIVc: Details, beforeLoad: ((UIViewController) -> Void)?) {
        guard let vcToShow = viewControllerFromStoryboard(presenteeAppUIVc.storyboard, withType: presenteeAppUIVc.type), var newVcStack = vc.navigationController?.viewControllers else {
            return
        }
        beforeLoad?(vcToShow)
        
        // Insert the new instance of the controller just after the root controller
        newVcStack.insert(vcToShow, at: 1)
        // Set the view controller stack as the newVcStack
        vc.navigationController?.viewControllers = newVcStack
        // Pop to the view controller
        vc.navigationController?.popToViewController(vcToShow, animated: true)
    }
}

public extension NavHelper {
    func resolveViewController<VCType>(name: String, withType type: VCType.Type?, from bundle: Bundle?) -> VCType? where VCType: UIViewController {
        let storyboard = UIStoryboard(name: name, bundle: bundle)
        guard let id = type?.id else {
            return nil
        }
        return storyboard
                .instantiateViewController(withIdentifier: id) as? VCType
    }
}

extension UIViewController: Identifiable {
    public static var id: String {
        return String(describing: self)
        .components(separatedBy: ".")
        .last ?? UUID().uuidString
    }
    
    public var id: String {
        Self.id
    }
}

public protocol NavHelperUsing: AnyObject {
    var navHelper: NavHelper { get }
}

public extension NavHelperUsing where Self: UIViewController {
    @discardableResult
    func present<PresenteeType>(_ vc: ViewControllerDetails, type: PresenteeType.Type? = nil, animated: Bool = true, beforeLoad: ((PresenteeType) -> Void)? = nil, completion: (() -> Void)? = nil) -> PresenteeType? where PresenteeType: UIViewController {
        return navHelper.present(vc, type: type, over: self, animated: animated, beforeLoad: beforeLoad, completion:  completion)
    }
    
    @discardableResult
    func show<PresenteeType>(_ presenteeAppUIVc: ViewControllerDetails, type: PresenteeType.Type? = nil, beforeLoad:((PresenteeType) -> Void)? = nil) -> PresenteeType? where PresenteeType: UIViewController {
        return navHelper.show(presenteeAppUIVc, type: type, presenter: self, beforeLoad: beforeLoad)
    }
    
    @discardableResult
    func setRootViewController<PresenteeType>(_ rootAppUIVc: ViewControllerDetails, type: PresenteeType.Type, beforeLoad: ((PresenteeType?) -> Void)? = nil) -> PresenteeType? where PresenteeType: UIViewController {
        return navHelper.setRootViewController(rootAppUIVc, type: type, beforeLoad: beforeLoad)
    }
    
    func pop(animated: Bool = true) {
        navHelper.pop(self, animated: animated)
    }
    
    func pop(to vc: UIViewController, animated: Bool = true) {
        navHelper.pop(self, to: vc, animated: animated)
    }
    
    func popToRoot(animated: Bool = true) {
        navHelper.popToRoot(self, animated: animated)
    }
    
    func popToRoot<PresenteeType>(type: PresenteeType.Type, andShow presenteeAppUIVc: ViewControllerDetails, beforeLoad: ((PresenteeType) -> Void)?) where PresenteeType: UIViewController {
        navHelper.popToRoot(self, type: type, andShow: presenteeAppUIVc, beforeLoad: beforeLoad)
    }
    
    func dismiss(completion: (() -> Void)? = nil) {
        dismiss(animated: true, completion: completion)
    }
}
