//
//  AppDelegate.swift
//  musicPlayer
//
//  Created by Abhishek Mahajan on 19/08/21.
//

import UIKit
import CoreData
import IQKeyboardManager
import Firebase
import FirebaseMessaging
import GoogleSignIn
import UserNotificationsUI
import UserNotifications
import StoreKit
import FBSDKCoreKit
import MediaPlayer



@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var appMediaPlayer = MPMusicPlayerController.applicationMusicPlayer

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            
         UIApplication.shared.isIdleTimerDisabled = true
        
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().isEnableAutoToolbar = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        Messaging.messaging().isAutoInitEnabled = true
        SocketIOManager.sharedInstance.establishConnection()
        GIDSignIn.sharedInstance().clientID  = "893675029309-mbp3gaqp3ditp0ngi3sbm62dues7uubu.apps.googleusercontent.com"
        setupNotifications(on: application)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            // Code
            // self.appMediaPlayer.setQueue(with: ["284488044"]) // 1444221569
            // self.appMediaPlayer.prepareToPlay { ee in
                print("++++++++++++++++++++++++++++++++++++++++++++++++++++")
               //  print(ee ?? "")
                print("++++++++++++++++++++++++++++++++++++++++++++++++++++")
            /// }
            // self.appMediaPlayer.play()
        }
        
        

//        ///Register for remote notificaitons
//        if #available(iOS 10.0, *) {
//            // For iOS 10 display notification (sent via APNS)
//            UNUserNotificationCenter.current().delegate = self
//
//            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//            UNUserNotificationCenter.current().requestAuthorization(
//                options: authOptions,
//                completionHandler: { _, _ in }
//            )
//        } else {
//            let settings: UIUserNotificationSettings =
//                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
//            application.registerUserNotificationSettings(settings)
//        }
//        application.registerForRemoteNotifications()
       
        ///Fetching the Registration Token
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
            }
        }
        
        // When the app launch after user tap on notification (originally was not running / not in background)
         if(launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] != nil){
            print("app launches by tapping on notification")
         }
        
        ///Restore the user's sign-in state
        GIDSignIn.sharedInstance().restorePreviousSignIn()
//        GIDSignIn.sharedInstance().restorePreviousSignIn { user, error in
//            if error != nil || user == nil {
//              // Show the app's signed-out state.
//            } else {
//              // Show the app's signed-in state.
//            }
//          }
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
                
        return true
    }
    
    

    
    
    ///MARK : - Handle opening of custom urls
    func application(
      _ app: UIApplication,
      open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
      var handled: Bool
        handled = GIDSignIn.sharedInstance().handle(url)
      if handled {
        return true
      }
      // Handle other custom URL types.

      // If not handled by this app, return false.
      return false
    }
    
    
    /// MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Songs")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    /// MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
}

extension AppDelegate:MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        guard let token = fcmToken else {
            return
        }
        print("sending token is \(token)")
        print("///send token to server...")
//        self.sendFCM(token: token)
        Constants.staticString.USER_DEFAULTS.set(token, forKey: Constants.staticString.FCMtoken)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
    /// This function will be called when the app receive notification
    //    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    //
    //        // show the notification alert (banner), and with sound
    //        completionHandler([.list, .sound, .banner,.badge])
    //    }
    
    /// This function will be called right after user tap on the notification
//        func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//            let application = UIApplication.shared
//            print("inside the notification didReceive method")
//            guard response.actionIdentifier == UNNotificationDefaultActionIdentifier else { return }
//    
//            let content = response.notification.request.content
//            print("Body \(content.body)")
//            print("Title \(content.title)")
//            print("UserInfo \(content.userInfo)")
//    
//            if(application.applicationState == .active){
//                print("user tapped the notification bar when the app is in foreground")
//            }
//            if(application.applicationState == .inactive){
//                print("user tapped the notification bar when the app is in background")
//                /// fetch the latest data from the server...
//                let roomID = Constants.staticString.USER_DEFAULTS.value(forKey: Constants.staticString.roomID) as! String
//                let Host   = Constants.staticString.USER_DEFAULTS.value(forKey: Constants.UserDetails.UserName) as! String
//                let room   = Constants.staticString.USER_DEFAULTS.value(forKey: Constants.staticString.roomName) as! String
//                WebLayerUserAPI().fetchSongsListFromServer(roomId: roomID) { songs in
//                    print(songs)
//                } failure: { Error in
//                    print(Error)
//                }
//
//            }
//            completionHandler()
//        }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print(userInfo)
    }
    
    ///Send FCM Token to server...
    func sendFCM(token:String) -> Bool{
        var status = Bool()
        guard let url =  URL(string: Constants.APIUrls.FCMToken) else { return false }
        WebLayerUserAPI().saveFCMToServer(url: url, parameters: ["fcm_token" : token]) { successResponse in
            print(successResponse)
            status = true
        } failure: { error in
//            return false
            status = false
            print(error)
        }
        return status
    }
}

extension AppDelegate {
    func setupNotifications(on application: UIApplication) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Failed to request autorization for notification center: \(error.localizedDescription)")
                return
            }
            guard granted else {
                print("Failed to request autorization for notification center: not granted")
                return
            }
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
    }
}

extension AppDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        let bundleID = Bundle.main.bundleIdentifier
        print("Bundle ID: \(token) \(String(describing: bundleID))")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let application = UIApplication.shared
        defer { completionHandler() }
        guard response.actionIdentifier == UNNotificationDefaultActionIdentifier else { return }
        
        let content = response.notification.request.content
        print("Title: \(content.title)")
        print("Body: \(content.body)")
        
        if(application.applicationState == .active){
            print("user tapped the notification bar when the app is in foreground")
            if (content.title == "New room created"){
                guard let room_name = content.userInfo["room_name"] as? String else {return}
                guard let room_id = content.userInfo["room_id"] as? String else {return}
                guard let HostProfile = content.userInfo["host_profile_image"] as? String else {return}
                guard let HostName = content.userInfo["host_username"] as? String else {return}
                guard let inviteCode = content.userInfo["invite_code"] as? String else {return}
                self.moveToRoom(roomName: room_name,roomId:room_id, HostName:HostName, HostProfile:HostProfile,inviteCode:inviteCode)
            } else if (content.title == "New song added") {
                self.addSogns()
            }
        }
        if(application.applicationState == .inactive){
            print("user tapped the notification bar when the app is in background")
            if (content.title == "New room created"){
                guard let room_name = content.userInfo["room_name"] as? String else {return}
                guard let room_id = content.userInfo["room_id"] as? String else {return}
                guard let HostProfile = content.userInfo["host_profile_image"] as? String else {return}
                guard let HostName = content.userInfo["host_username"] as? String else {return}
                guard let inviteCode = content.userInfo["invite_code"] as? String else {return}
                self.moveToRoom(roomName: room_name,roomId:room_id,  HostName:HostName, HostProfile:HostProfile,inviteCode:inviteCode)
            } else if (content.title == "New song added") {
                self.addSogns()
            }
        }
        
        if let userInfo = content.userInfo as? [String: Any],
           let aps = userInfo["aps"] as? [String: Any] {
            print("aps: \(aps)")
        }
    }
    
    func moveToRoom(roomName: String,roomId:String,  HostName:String, HostProfile:String,inviteCode:String){
        let vc = RouteCoordinator.NavigateToVC(with: "RoomPlayListVC", Controller: "RoomPlayListVC", Stroyboard: RouteCoordinator.Room, presentation: .fullScreen) as! RoomPlayListVC
        vc.fromNotification = true
        vc.AsGuest = true
        vc.roomName = roomName
        vc.invitationCode = inviteCode
//        vc.HostName = HostName
        vc.RoomID = roomId
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .fullScreen
        
        UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: false)
    }
    
    func addSogns(){
        let UserDetails = Constants.staticString.USER_DEFAULTS.self
        guard let roomId :String = UserDetails.value(forKey: Constants.staticString.roomID) as? String else {return}
        WebLayerUserAPI().fetchSongsListFromServer(roomId: roomId) { data in
            print(data)
            let data = data.songs
            
        } failure: { error in
            print(error.localizedDescription)
        }
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}


