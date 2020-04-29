import UIKit


// Simple Adapter Pattern

protocol Walkable {
    
    func walk()
}

class Dog: Walkable {
    
    func walk() {
        print("Jump")
    }
}

class Cat: Walkable {
    
    func walk() {
        print("Stealth")
    }
}

class Frog {
    
    func leap() {
        print("Leap")
    }
}
// Frog is the Adaptee
extension Frog: Walkable {
    
    func walk() {
        leap()
    }
}

var animals: [Walkable] = [Dog(), Cat(), Frog()]

for animal in animals {
    animal.walk()
}


// -------------------------------------------------------------------------------------//

// Real world app example


class FirebaseService: NSObject {}

extension FirebaseService: UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Firebase
        FirebaseApp.configure()
                
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        return true
    }
}

class YoutubeService: NSObject {}

extension YoutubeService: UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // YoutubeKit - Set your API key here
        YoutubeKit.shared.setAPIKey(API.ytKey)
        
        return true
    }
}

class AppNavigationService: NSObject {
    
    var window: UIWindow?
    
}

extension AppNavigationService: UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        // storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // inisilize OnboardingViewController
        let onboardingVC = storyboard.instantiateViewController(identifier: AppConstant.ONBOARDING_VIEWCONTROLLER,
                                                                   creator: { coder in
                return OnboardingViewController(coder: coder)
        })
        
        window?.rootViewController = onboardingVC
        
        window?.makeKeyAndVisible()
        
        return true
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    

    let services: [UIApplicationDelegate] = [
        FirebaseService(),
        YoutubeService(),
        AppNavigationService()
    ]
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
      
        for service in services {
            
            _ = service.application?(application,
                                     didFinishLaunchingWithOptions: launchOptions)
        }
        return true
    }
}
