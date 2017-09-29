import Foundation
import UIKit
import ObjectiveC

typealias NavigationBlock = ()->()
private var NavigationItemsKey: UInt8 = 0
extension UIViewController {
    var delegateHolder: Array<NavigationItemDelegate> {
        get {
            if let a = (objc_getAssociatedObject(self, &NavigationItemsKey) as? Array<NavigationItemDelegate>) {
                return a
            } else {
                let a = Array<NavigationItemDelegate>()
                objc_setAssociatedObject(self, &NavigationItemsKey, a, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
                return a
            }
        }
        set {
            objc_setAssociatedObject(self, &NavigationItemsKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func setLeftNavigationItem(_ title:String, block: @escaping NavigationBlock) {
        let del = NavigationItemDelegate(leftItemAction: block, rightItemAction: nil)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.plain, target: del, action: #selector(NavigationItemDelegate.excuteAction))
        self.delegateHolder.append(del)
    }
    
    func setLeftNavigationItemImage(_ image: UIImage, block: @escaping NavigationBlock) {
        let del = NavigationItemDelegate(leftItemAction: block, rightItemAction: nil)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: del, action: #selector(NavigationItemDelegate.excuteAction))
        self.delegateHolder.append(del)
    }
    
    func setLeftNavigationItemImageString(_ image: String, block: @escaping NavigationBlock) {
        let del = NavigationItemDelegate(leftItemAction: block, rightItemAction: nil)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: image), style: .plain, target: del, action: #selector(NavigationItemDelegate.excuteAction))
        self.delegateHolder.append(del)
    }
    
    func setRightNavigationItem(_ title:String, block:@escaping NavigationBlock) {
        let del = NavigationItemDelegate(leftItemAction: nil, rightItemAction: block)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.plain, target: del, action: #selector(NavigationItemDelegate.excuteAction))
        self.delegateHolder.append(del)
    }
    
    func setRightNavigationItemImage(_ image: UIImage, block: @escaping NavigationBlock) {
        let del = NavigationItemDelegate(leftItemAction: nil, rightItemAction: block)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: del, action: #selector(NavigationItemDelegate.excuteAction))
        self.delegateHolder.append(del)
    }
    
    
    func setRightNavigationItemImageString(_ image: String, block:@escaping NavigationBlock) {
        let del = NavigationItemDelegate(leftItemAction: nil, rightItemAction: block)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: image), style: .plain, target: del, action: #selector(NavigationItemDelegate.excuteAction))
        self.delegateHolder.append(del)
    }
    
    final class NavigationItemDelegate: NSObject {
        var leftAction: NavigationBlock?
        var rightAction: NavigationBlock?
        
        func excuteAction() {
            if let _ = self.leftAction {
                self.leftAction!()
            }else if let _ = self.rightAction {
                self.rightAction!()
            }
        }
        
        init(leftItemAction aLeftItemAction: NavigationBlock?, rightItemAction aRightItemAction: NavigationBlock?) {
            self.leftAction = aLeftItemAction
            self.rightAction = aRightItemAction
        }
    }
    
    func clearNavBackground() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
}
