//
//  MainScreenVC.swift
//  Hayi
//
//  Created by Muhammad zain ul Abideen on 18/08/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import UIKit
import SwiftyGif

/// Represents the possible Firebase App IDs that we want to toggle based on build type (development vs production).
enum FirebaseAppId: String {
    case dev = "1:113090359810:ios:8a4a3cb25cea1bbbeb2d1b"
    case prod = "1:896884315218:ios:bc5717b7d5c4498d947b8b"
    
    var environment: String {
        switch self {
        case .dev:
            return "dev"
        case .prod:
            return "prod"
        }
    }
}

/// Represents the GoogleService-Info.plist contained in the app bundle.
struct GoogleServiceInfo: Decodable {
    let appId: String
    
    private enum CodingKeys: String, CodingKey {
        case appId = "GOOGLE_APP_ID"
    }
}

class MainScreenVC: UIViewController {

  @IBOutlet weak var gifImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.gifImageView.updateConstraints()
        do {
            let gif = try UIImage(gifName: "hayi-gif.gif")
            self.gifImageView.setGifImage(gif)
            
        } catch {
            print(error)
        }
        
        //gifImageView.contentMode = .scaleAspectFit
        self.setupFirebaseAppIdLabel()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func didReceiveMemoryWarning() {
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
    }
    
    @IBAction func Neighoubourhood(_ sender: Any) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let vc = storyboard.instantiateViewController(withIdentifier: "Step1VC") as? Step1VC
        {
            self.navigationController?.pushViewController(vc, animated: true)
        }
       // self.performSegue(withIdentifier: "home", sender: self)
        
    }
    
    
    @IBAction func signIn(_ sender: Any) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "SignInViewController") as?   SignInViewController
            
        {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
  override func viewWillAppear(_ animated: Bool) {
    self.tabBarController?.tabBar.isHidden = true
    self.navigationController?.setNavigationBarHidden(true, animated: true)
    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

//
  }

  override func viewWillDisappear(_ animated: Bool) {
    self.navigationController?.setNavigationBarHidden(false, animated: true)
    self.tabBarController?.tabBar.isHidden = false
    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

  }
  
  // MARK: - Private
  
  private func setupFirebaseAppIdLabel() {
      guard let googleServiceInfoPlistPath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else {
          fatalError("Couldn't locate GoogleService-Info.plist")
      }
      
      do {
          let plistData = try Data.init(contentsOf: URL(fileURLWithPath: googleServiceInfoPlistPath))
          
          let plistDecoder = PropertyListDecoder()
          let googleServiceInfo = try plistDecoder.decode(GoogleServiceInfo.self, from: plistData)
          
          let rawAppId = googleServiceInfo.appId
          guard let appId = FirebaseAppId(rawValue: rawAppId) else {
              fatalError("Invalid appId: \(rawAppId)")
          }
          
          print("Googl-Plist=== \(buildAppIdStatusText(from: appId))")
      } catch {
          fatalError("\(error)")
      }
  }
  
  private func buildAppIdStatusText(from appId: FirebaseAppId) -> String {
      return "Firebase AppId:" + "\n" + appId.rawValue + "\n" + "(\(appId.environment))"
  }


}
