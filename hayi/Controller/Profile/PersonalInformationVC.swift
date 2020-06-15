//
//  PersonalInformationVC.swift
//  Hayi
//
//  Created by Muhammad zain ul Abideen on 20/08/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import UIKit

class PersonalInformationVC: UIViewController {

  @IBOutlet weak var collectionView: UICollectionView!
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let nib  = UINib(nibName: "TextFieldCell", bundle: nil)
    collectionView.register(nib, forCellWithReuseIdentifier: "TextFieldCell")
    let nibCell  = UINib(nibName: "MemberCell", bundle: nil)
    collectionView.register(nibCell, forCellWithReuseIdentifier: "MemberCell")
    
    collectionView.register(UINib(nibName: "HeaderCollectionView", bundle: nil), forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderCollectionView")
    self.title = "Personal Information"
    let searchButton = UIBarButtonItem(title : "Edit",  style: .plain, target: self, action: "didTapSearchButton:")
    navigationItem.rightBarButtonItems = [searchButton]
    
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
     navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
  
  }
    func didTapEditButton(sender: AnyObject){
        
    }
}

extension PersonalInformationVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    switch section {
    case 0:
      return 4
    case 1:
      return 2
    default:
      return 0
    }
  }
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 2
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let  reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderCollectionView", for: indexPath)  as! HeaderCollectionView
    if indexPath.section == 0 {
      reusableview.configureCell(title: "Profile")
    } else {
      reusableview.configureCell(title: "Household Members")
    }
    
    return reusableview
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    if indexPath.section == 0 {
    
      let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "TextFieldCell", for: indexPath) as! TextFieldCell
      return cell
      
    } else {
      let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "MemberCell", for: indexPath) as! MemberCell
      return cell
      
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
  
    if indexPath.section == 0 {
      let width = view.frame.width
      return CGSize.init(width: width, height: 70)
    } else {
      let width = view.frame.width/2 - 20
      return CGSize.init(width: width, height: 70)
    }
    
  }
}
