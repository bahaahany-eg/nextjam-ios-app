//
//  SceneDelegate.swift
//  musicPlayer
//
//  Created by Abhishek Mahajan on 19/08/21.
//

import UIKit
import NotificationCenter
import StoreKit
import MediaPlayer
import FacebookCore


class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    var callit = false
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        let UD = Constants.staticKeys.USER_DEFAULTS.self
        guard let loggedIn = UD.value(forKey: Constants.staticKeys.LoggedInStatus) as? Bool else { return }
        if loggedIn {
            guard let winScene = (scene as? UIWindowScene) else { return }
            window = UIWindow(windowScene: winScene)
            RouteCoordinator.NavigateToVC(with: "JamSessionVC", Controller: "JamSessionVC", Stroyboard: RouteCoordinator.Main, presentation: .fullScreen, ofType: JamSessionVC()) { [self] vc in
                let navigationController = UINavigationController(rootViewController: vc)
                window?.rootViewController = navigationController
                window?.makeKeyAndVisible()
            }
        }else{
            guard let _ = (scene as? UIWindowScene) else { return }
        }
        
        print("1")
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).os
        print("2")
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        UIApplication.shared.isIdleTimerDisabled = true

        print("3")
        if SKCloudServiceController.authorizationStatus() == .authorized {
            SharedPlayer.shared.currentSongIndex =  SharedPlayer.shared.appMediaPlayer?.indexOfNowPlayingItem


            if SharedPlayer.shared.appMediaPlayer?.nowPlayingItem != nil {
                SharedPlayer.shared.playOne = true
                if SharedPlayer.shared.appMediaPlayer?.playbackState == .playing {
                    // SharedPlayer.shared.setupTimer()
                    SharedPlayer.shared.isNotify = false
                    SharedPlayer.shared.playerViewController?.playButton.setImage(UIImage(systemName:"pause.fill"), for: .normal)
                } else {
                    SharedPlayer.shared.playerViewController?.playButton.setImage(UIImage(systemName:"play.fill"), for: .normal)
                }
            }
        }
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
//        socketOperations()
        print("4")
       // SharedPlayer.shared.timer?.invalidate()
        
        SharedPlayer.shared.isNotify = true
        
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        socketOperations()
        let UserDetails = Constants.staticKeys.USER_DEFAULTS.self
        guard let roomId :String = UserDetails.value(forKey: Constants.staticKeys.roomID) as? String else {return}
        WebLayerUserAPI().fetchSongsListFromServer(roomId: roomId) { data in
            print(data)
//            let data = data.songs
            
        } failure: { error in
            print(error.localizedDescription)
        }

    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
    }
    
    func socketOperations() {
        let UserDetails = Constants.staticKeys.USER_DEFAULTS.self
        guard let  nickname: String = UserDetails.value(forKey: Constants.UserDetails.UserName) as? String else {return}
        guard let  invitationCode: String = UserDetails.value(forKey: Constants.staticKeys.invitationCode) as? String else {return}
        SocketIOManager.sharedInstance.socket.on(clientEvent: .connect) { data, ack in
            SocketIOManager.sharedInstance.connectToServerWithNickName(nickName: nickname, inviteCode: invitationCode) { userList in
                print(userList)
            }
        }
    }
    func isFirstLaunch() -> Bool {
        if !UserDefaults.standard.bool(forKey: "HasLaunched") {
            UserDefaults.standard.set(true, forKey: "HasLaunched")
            UserDefaults.standard.synchronize()
            return true
        }
        return false
    }
    
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }

        
        /*
         Custom Url schema
         let urlStr = url.absoluteString //1
         // Parse the custom URL as per your requirement.
         let component = urlStr.components(separatedBy: "=") // 2
         if component.count > 1, let appId = component.last { // 3
             print(appId)
             let topViewController = self.window?.rootViewController as? UINavigationController
             let currentVC = topViewController?.topViewController as? ViewController
             currentVC?.data.text = "Application Id : " + appId
         }
         */
        
        
        let urlstr = url.absoluteString
        let component = urlstr.components(separatedBy: ":")
//        if component.count > 1, let appId = component.last{
//            print(appId)
//            let 
//        }
        
        
        
        ApplicationDelegate.shared.application(
            UIApplication.shared,
            open: url,
            sourceApplication: nil,
            annotation: [UIApplication.OpenURLOptionsKey.annotation]
        )
    }
}




