//
//  EditProfileVC.swift
//  Hayi
//
//  Created by Muhammad zain ul Abideen on 21/08/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import UIKit

class EditProfileVC: UIViewController {
  
  @IBOutlet weak var collectionView: UICollectionView!
  
  override func viewDidLoad() {
  
    super.viewDidLoad()
    let nib  = UINib(nibName: "TextFieldCell", bundle: nil)
    collectionView.register(nib, forCellWithReuseIdentifier: "TextFieldCell")
    
    let nibCell  = UINib(nibName: "UserProfileCell", bundle: nil)
    collectionView.register(nibCell, forCellWithReuseIdentifier: "UserProfileCell")
    
    let nibCell1  = UINib(nibName: "skillsAndIntresetCell", bundle: nil)
    collectionView.register(nibCell1, forCellWithReuseIdentifier: "skillsAndIntresetCell")
    
    collectionView.register(UINib(nibName: "HeaderCollectionView", bundle: nil), forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderCollectionView")
    
    self.title = "Edit Profile"
     navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
    
  }
}

extension EditProfileVC:  UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    switch section {
    case 0:
      return 1
    case 1:
      return 3
    case 2:
      return 8
    case 3:
      return 4
    default:
      return 0
    }
  }
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 4
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let  reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderCollectionView", for: indexPath)  as! HeaderCollectionView
    if indexPath.section == 0 {
      reusableview.configureCell(title: "")
    }else if indexPath.section == 1 {
      reusableview.configureCell(title: "Biography")
    } else if indexPath.section == 2 {
      reusableview.configureCell(title: "Interest")
    }else if indexPath.section == 3 {
      reusableview.configureCell(title: "Skills")
    }
    else {
      reusableview.configureCell(title: "Household Members")
    }
    
    return reusableview
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    if indexPath.section == 0 {
      let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "UserProfileCell", for: indexPath) as! UserProfileCell
      return cell
    } else if indexPath.section == 1 {
      let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "TextFieldCell", for: indexPath) as! TextFieldCell
      return cell
    }  else if indexPath.section == 2 {
      let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "skillsAndIntresetCell", for: indexPath) as! skillsAndIntresetCell
      return cell
    }
    else {
      let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "skillsAndIntresetCell", for: indexPath) as! skillsAndIntresetCell
      return cell
      
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    if indexPath.section == 0 {
      let width = view.frame.width
      return CGSize.init(width: width, height: 180)
    } else if indexPath.section == 1 {
      let width = view.frame.width
      return CGSize.init(width: width, height: 70)
    }
    else {
      let width = view.frame.width/4 - 10
      return CGSize.init(width: width, height: 70)
    }
    
  }
  
}
