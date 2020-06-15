import UIKit
import GoogleMaps
import GooglePlaces
import IQKeyboardManagerSwift
import Alamofire
import Firebase
import UserNotifications
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate,MessagingDelegate {
    
    var window: UIWindow?
    var rootVC : UIViewController?
    var mainTabVC: UITabBarController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        
        GMSPlacesClient.provideAPIKey("AIzaSyBwKkOzJynSHu81XZeBiQeRQKoFwzhKM2M")
        GMSServices.provideAPIKey("AIzaSyBwKkOzJynSHu81XZeBiQeRQKoFwzhKM2M")
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        
        // Register for notification
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        // Server login check
        if UserDefaultsManager.instance.isloggedin() {
            
            //Firebase login Check
            
            if Auth.auth().currentUser == nil {
                // No user is signed in.
                let username = UserDefaultsManager.instance.getValueFor(key: KeyUsername)
                let password = UserDefaultsManager.instance.getValueFor(key: KeyPassword)
                
                
                if username != nil && password != nil {
                    
                    FUser.loginUserWith(email: username!, password: password!) { (error) in
                        
                        if error == nil {
                            self.showDashboardScreen()
                        }
                        else {
                            self.showLoginScreen()
                        }
                    }
                }
                
            }
            else {
                //fetchCurrentUserFromFirestore(userId: FUser.currentId())
                self.showDashboardScreen()
            }
        }
        else {
            
            self.showLoginScreen()
            
        }
        
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if let isBadge = UserDefaults.standard.value(forKey: KeyBadge) as? Bool{
            if isBadge {
                addBadgeOnChatIcon()
            }
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func showDashboardScreen() {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewControlleripad : DashBoardTabBarController = mainStoryboardIpad.instantiateViewController(withIdentifier: "DashBoardTabBarController") as! DashBoardTabBarController
        
        self.mainTabVC = initialViewControlleripad
        
        self.window?.rootViewController = initialViewControlleripad
        
        self.window?.makeKeyAndVisible()
        
        if Messaging.messaging().fcmToken != nil {
            
            self.updateUserFCMTokenFirebase(token: Messaging.messaging().fcmToken!)
            self.updateUserFCMToken(token: Messaging.messaging().fcmToken!)
        }
        
    }
    
    func showLoginScreen() {
        
        self.mainTabVC = nil
        let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewControlleripad : MainScreenVC = mainStoryboardIpad.instantiateViewController(withIdentifier: "MainScreenVC") as! MainScreenVC
        if let navigationController = self.window?.rootViewController as? UINavigationController
        {
            navigationController.pushViewController(initialViewControlleripad, animated: true)
        }
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        
        // Print message ID.
        
        if let messageID = userInfo["aps"] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        
        // Print message ID.
        if let messageID = userInfo["aps"] {
            print("Message ID: \(messageID)")
        }
        
        let dic1 = userInfo["aps"] as? NSDictionary
        
        let dic2 = dic1?["alert"] as? NSDictionary
        
        let title = dic2?["title"] as? String
        if let tit = title {
            if tit == "Hayi notification" {
                
                let data:[String: String] = ["type": "post"]
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newnotification"), object: nil,userInfo: data)
            }
            else {
                self.addBadgeOnChatIcon()
            }
            
            // Print full message.
            print(userInfo)
            
            completionHandler(UIBackgroundFetchResult.newData)
        }
    }
        
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        InstanceID.instanceID().instanceID(handler: { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
                //  self.updateUserFCMToken(token: result.token)
            }
        })
    }
    
    func updateUserFCMToken(token:String) {
        
        let userId = UserDefaults.standard.value(forKey: KeyUserId) as? Int
        
        if userId != nil {
            
            let url = HelperFuntions.UpdateUserFCMToken
            
            let postString = ["userId": userId!, "fcmToken": token] as [String : Any]
            
            let MyHeader = ["content-type": "application/json"]
            
            Alamofire.request(url, method: .post, parameters: postString, encoding: JSONEncoding(options: []), headers: MyHeader).responseJSON{(responseJSON) in
                DispatchQueue.main.async {
                    
                    print("Save FCM Token")
                    
                    switch responseJSON.result{
                        
                    case .success(let data):
                        var statusCode:Int = 0
                        if responseJSON.result.value != nil{
                            
                            statusCode = (responseJSON.response?.statusCode)!
                            print("...HTTP code: \(statusCode)")
                        }
                        print("all reponse data \(data)")
                        
                    case .failure(let error):
                        print(error)
                        //HUD.hide()
                    }
                    
                }
            }
        }
        
    }
    
    func updateUserFCMTokenFirebase(token:String) {
        
        let dict:NSDictionary = [kFCMToken:token]
        
        updateServerUserId(withValues: dict as! [String : Any], completion: {(error)in
            
            if let err = error {
                print(err.localizedDescription)
            }
        })
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = ApplicationDelegate.shared.application(app, open: url, options: options)
        
        // Add any custom logic here.
        
        return handled
    }
}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate {
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        self.sendUserInfoToVC(userInfo: userInfo)
        completionHandler([])
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        self.sendUserInfoToVC(userInfo: userInfo)
        self.addBadgeOnChatIcon()
        completionHandler()
    }
    
    func addBadgeOnChatIcon() {
        let data:[String: String] = ["type": "msg"]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newnotification"), object: nil,userInfo: data)
        
        UserDefaults.standard.set(true, forKey: KeyBadge)
    }
    
    private func sendUserInfoToVC(userInfo: [AnyHashable : Any]) {
        let data = userInfo as NSDictionary
        let objNotify = ParsingDicFunctions().parseNotficationDetail(data)
        self.addBadgeOnChatIcon()
        self.decideChatRoom(objNotify)
    }
    
    private func decideChatRoom(_ objNotification: NotificationDetailDC) {
        if self.mainTabVC?.selectedIndex == 2 {
        }else {
            if UIApplication.shared.applicationState == .active {
                self.showAlert(objNotification)
            }else {
                self.goToCharRoom(objNotification)
            }
        }
    }
    
    private func goToCharRoom(_ objNotification: NotificationDetailDC) {
        self.mainTabVC?.selectedIndex = 2
        if let nVC = self.mainTabVC?.selectedViewController as? UINavigationController {
            if let conversationVC = nVC.visibleViewController as? ConversationsVC {
                conversationVC._isGoingToChatRoom = true
                conversationVC._roomID = objNotification.chatRoomId
                conversationVC.loadRecentChats()
            }
        }
    }
    
    private func showAlert(_ objNotification: NotificationDetailDC) {
        let alert = UIAlertController(title: "\(objNotification.aps.alert.title)", message: objNotification.aps.alert.body, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Chat", style: .default, handler:
            { action in
                switch action.style {
                case .default:
                    self.goToCharRoom(objNotification)
                case .cancel:
                    print("cancel")
                case .destructive:
                    print("destructive")
                }
        }))
        
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}
