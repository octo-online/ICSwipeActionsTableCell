
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        window = UIWindow()
        let vc = ICDemoTableViewController()
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
        
        return true
    }

}

