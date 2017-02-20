//
//  CollectionViewController.swift
//  NatashaMartinez
//
//  Created by Natasha M on 2/18/17.
//  Copyright © 2017 Martinezpc. All rights reserved.
//

import Foundation
import UIKit
import SwiftSpinner
import Foundation
import CoreData
import Alamofire
import DeviceKit

class CollectionViewController : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var feedCollectionView: UICollectionView!
    
    var filterCategory = AppCategory() 
    var appImgAttribs = [AppImgAttributes]()
    var appPriceAttribs = [AppPrice]()
    var appImgages = [AppImage]()
    var appCategories = [AppCategory]()
    var appEntries = [Entry]()
    var appFeeds = [Feed]()
    var userIsConnected = true
    let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.apple.com")
    
    var totalAppsToShow : String = "";
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.prepareView()
        if self.totalAppsToShow != "" {
            self.retrieveFeed()
        } else {
            self.filterFeed()
        }
    }
    
    func prepareView() {
        self.feedCollectionView.delegate = self
        self.feedCollectionView.dataSource = self
    }
    
    func filterFeed() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Entry")
        
        do {
            self.appEntries.removeAll()
            let results =
                try managedContext.fetch(fetchRequest)
            let appEntriesArray = results as! [Entry]
            for item in appEntriesArray {
                if (item.appCategory?.allObjects.first as! AppCategory).utilities == filterCategory.utilities {
                appEntries.append(item)
                }
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        self.updateViewData()
    }
    
    func retrieveFeed() {
        if !isConnectedToNetwork() {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Entry")
            
            do {
                let results =
                    try managedContext.fetch(fetchRequest)
                    appEntries = results as! [Entry]
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
            self.updateViewData()
            return
        }
        
        SwiftSpinner.show("Recuperando top \(self.totalAppsToShow) apps...")
        
        let getFeedData = GetAppsService(applimit: totalAppsToShow)
        getFeedData.getMainService(completion: { (retrieveData, error, errorNonJson) in
            SwiftSpinner.hide()
            if (error != nil)
            {
                self.userIsConnected = false
                return
            }
            self.userIsConnected = true
            self.parseRetrievedData(retrievedData: retrieveData!)
        })
    }
    
    //pragma Mark -saving to local storage data
    func saveAppImgAttribs(heightV: String) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "AppImgAttributes", in: managedContext)
        
        let appImgAttribute = NSManagedObject(entity: entity!, insertInto: managedContext) as! AppImgAttributes
        appImgAttribute.setValue(heightV, forKey: "height")
        do {
            try managedContext.save()
            appImgAttribs.append(appImgAttribute)
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func saveAppPrice(amountV : String, currencyV: String, labelV: String) -> AppPrice {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "AppPrice", in: managedContext)
        
        let appPriceAttribute = NSManagedObject(entity: entity!, insertInto: managedContext) as! AppPrice
        appPriceAttribute.setValue(amountV, forKey: "amount")
        appPriceAttribute.setValue(currencyV, forKey: "currency")
        appPriceAttribute.setValue(labelV, forKey: "label")
        
        do {
            try managedContext.save()
            appPriceAttribs.append(appPriceAttribute)
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
        return appPriceAttribute
    }
    
    func saveAppImage(appImageAttributes : [AppImgAttributes], labelV: String) -> AppImage {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "AppImage", in: managedContext)
        
        let appImage = NSManagedObject(entity: entity!, insertInto: managedContext) as! AppImage
        appImage.setValue(labelV, forKey: "label")
        for item in appImageAttributes {
            appImage.addToAttributes(item)
        }
        
        do {
            try managedContext.save()
            appImgages.append(appImage)
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
        return appImage
    }
    
    func saveAppCategory(idV : String, schemeV : String, titleV: String, utilitiesV: String) -> AppCategory {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "AppCategory", in: managedContext)
        
        let appCategory = NSManagedObject(entity: entity!, insertInto: managedContext) as! AppCategory
        appCategory.setValue(idV, forKey: "id")
        appCategory.setValue(schemeV, forKey: "scheme")
        appCategory.setValue(titleV, forKey: "title")
        appCategory.setValue(utilitiesV, forKey: "utilities")
        
        do {
            try managedContext.save()
            appCategories.append(appCategory)
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
        return appCategory
    }
    
    func saveEntry(appNameV: String, artistV: String, contentTypeV: String, linkV: String, releaseDateV: String, rightsV: String, summaryV: String, titleV: String, appCategory: AppCategory, appImage: AppImage, appPrice: AppPrice) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Entry", in: managedContext)
        
        let appEntry = NSManagedObject(entity: entity!, insertInto: managedContext) as! Entry
        appEntry.setValue(appNameV, forKey: "appName")
        appEntry.setValue(artistV, forKey: "artist")
        appEntry.setValue(contentTypeV, forKey: "contentType")
        appEntry.setValue(linkV, forKey: "link")
        appEntry.setValue(releaseDateV, forKey: "releaseDate")
        appEntry.setValue(rightsV, forKey: "rights")
        appEntry.setValue(summaryV, forKey: "summary")
        appEntry.setValue(titleV, forKey: "title")
        appEntry.addToAppCategory(appCategory)
        appEntry.addToAppImg(appImage)
        appEntry.addToAppPrice(appPrice)
        
        do {
            try managedContext.save()
            appEntries.append(appEntry)
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func saveAppFeed(rightsV: String, titleV: String, appEntry: [Entry]) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Feed", in: managedContext)
        
        let appFeed = NSManagedObject(entity: entity!, insertInto: managedContext) as! Feed
        appFeed.setValue(titleV, forKey: "title")
        appFeed.setValue(rightsV, forKey: "rights")
        
        for item in appEntry {
            appFeed.addToEntry(item)
        }
        
        do {
            try managedContext.save()
            appFeeds.append(appFeed)
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func parseRetrievedData(retrievedData : NSDictionary) {
        let feedDictionary = retrievedData.object(forKey: "feed") as! NSDictionary
        let entryDictionary = feedDictionary.object(forKey: "entry") as! NSArray
        for i in 0..<entryDictionary.count {
            let thisEntry = entryDictionary[i] as! NSDictionary
            let imageUrl = ((thisEntry.object(forKey: "im:image") as! NSArray).firstObject as! NSDictionary).object(forKey: "label") as! String
            let imageData = (thisEntry.object(forKey: "im:image") as! NSArray)
            for j in 0..<imageData.count {
                let imageHeight = ((imageData[j] as! NSDictionary).object(forKey: "attributes") as! NSDictionary).object(forKey: "height") as! String
                self.saveAppImgAttribs(heightV: imageHeight)
            }
            let appImageObject = self.saveAppImage(appImageAttributes: appImgAttribs, labelV: imageUrl)
            let appCategory = (thisEntry.object(forKey: "category") as! NSDictionary).object(forKey: "attributes") as! NSDictionary
            let appCatId = appCategory.object(forKey: "im:id") as! String
            let appCatScheme = appCategory.object(forKey: "scheme") as! String
            let appCatTitle = appCategory.object(forKey: "label") as! String
            let appCatUtilities = appCategory.object(forKey: "term") as! String
            
            let appCategoryObject = self.saveAppCategory(idV: appCatId, schemeV: appCatScheme, titleV: appCatTitle, utilitiesV: appCatUtilities)
            
            let appPrice = (thisEntry.object(forKey: "im:price") as! NSDictionary)
            let appPriceLabel = appPrice.object(forKey: "label") as! String
            let appPriceAmount = (appPrice.object(forKey: "attributes") as! NSDictionary).object(forKey: "amount") as! String
            let appPriceCurency = (appPrice.object(forKey: "attributes") as! NSDictionary).object(forKey: "currency") as! String
            let appPriceObj = self.saveAppPrice(amountV: appPriceAmount, currencyV: appPriceCurency, labelV: appPriceLabel)
            
            let appSummary = (thisEntry.object(forKey: "summary") as! NSDictionary).object(forKey: "label") as! String
            let appTitle = (thisEntry.object(forKey: "title") as! NSDictionary).object(forKey: "label") as! String
            let appRights = (thisEntry.object(forKey: "rights") as! NSDictionary).object(forKey: "label") as! String
            let releaseDate = ((thisEntry.object(forKey: "im:releaseDate") as! NSDictionary).object(forKey: "attributes") as! NSDictionary).object(forKey: "label") as! String
            let appLink = ((thisEntry.object(forKey: "link") as! NSDictionary).object(forKey: "attributes") as! NSDictionary).object(forKey: "href") as! String
            let contentType = ((thisEntry.object(forKey: "im:contentType") as! NSDictionary).object(forKey: "attributes") as! NSDictionary).object(forKey: "label") as! String
            let artist = (thisEntry.object(forKey: "im:artist") as! NSDictionary).object(forKey: "label") as! String
            let appName = (thisEntry.object(forKey: "im:name") as! NSDictionary).object(forKey: "label") as! String
            
            self.saveEntry(appNameV: appName, artistV: artist, contentTypeV: contentType, linkV: appLink, releaseDateV: releaseDate, rightsV: appRights, summaryV: appSummary, titleV: appTitle, appCategory: appCategoryObject, appImage: appImageObject, appPrice: appPriceObj)
        }
        let feedTitle = (feedDictionary.object(forKey: "title") as! NSDictionary).object(forKey: "label")as! String
        let feedRights = (feedDictionary.object(forKey: "rights") as! NSDictionary).object(forKey: "label")as! String
        self.saveAppFeed(rightsV: feedRights, titleV: feedTitle, appEntry: appEntries)
        
        self.updateViewData()
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.appEntries.count == 0 {
            return 0
        } else {
            return appEntries.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //FeedCollectionListCell
        let thisCell = feedCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let appInfo = appEntries[indexPath.row].appName
        let appImageValues = appEntries[indexPath.row].appImg?.allObjects.first as! AppImage
        let appPriceV = appEntries[indexPath.row].appPrice?.allObjects.first as! AppPrice
        let urlString = "\(appImageValues.label!)"
        
        let device = Device()
        if device.isPhone {
            let cell = feedCollectionView.dequeueReusableCell(withReuseIdentifier: "listCell", for: indexPath) as! FeedCollectionListCell
            if let url = URL(string: urlString){
                getDataFromUrl(url: url) { (data, response, error)  in
                    guard let data = data, error == nil else { print("url not found"); return  }
                    DispatchQueue.main.async() { () -> Void in
                        cell.appImage.contentMode = .scaleAspectFit
                        cell.appImage.image =  UIImage(data: data)
                    }
                }
            }
            cell.appName.text = appInfo
            cell.appDescription.text = appEntries[indexPath.row].summary
            cell.appPrice.text = "\(appPriceV.amount! + appPriceV.currency!)"
            let finalCellFrame : CGRect = cell.frame
            let translation : CGPoint = collectionView.panGestureRecognizer.translation(in: collectionView.superview)
            if (translation.x > 0) {
                cell.frame = CGRect(x: finalCellFrame.origin.x - 1000, y: finalCellFrame.origin.y - 500, width: 0, height: 0)
            } else {
                cell.frame = CGRect(x: finalCellFrame.origin.x + 1000, y: finalCellFrame.origin.y - 500, width: 0, height: 0)
            }
            UIView.animate(withDuration: 0.5, animations: {
                cell.frame = finalCellFrame;
                
            } , completion: nil)
            return cell
            
        } else if device.isPad {
            
            let cell = feedCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FeedCollectionCell
            cell.appName.text = appInfo
            if let url = URL(string: urlString){
                getDataFromUrl(url: url) { (data, response, error)  in
                    guard let data = data, error == nil else { print("url not found"); return  }
                    DispatchQueue.main.async() { () -> Void in
                        cell.appImage.contentMode = .scaleAspectFit
                        cell.appImage.image =  UIImage(data: data)
                    }
                }
            }
            cell.appPrice.text = "\(appPriceV.amount! + appPriceV.currency!)"
            let finalCellFrame : CGRect = cell.frame
            let translation : CGPoint = collectionView.panGestureRecognizer.translation(in: collectionView.superview)
            if (translation.x > 0) {
                cell.frame = CGRect(x: finalCellFrame.origin.x - 1000, y: finalCellFrame.origin.y - 500, width: 0, height: 0)
            } else {
                cell.frame = CGRect(x: finalCellFrame.origin.x + 1000, y: finalCellFrame.origin.y - 500, width: 0, height: 0)
            }
            UIView.animate(withDuration: 0.5, animations: {
                cell.frame = finalCellFrame;
                
            } , completion: nil)
            return cell
        }
        return thisCell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewHeight = collectionView.bounds.height
        let viewWidth = collectionView.bounds.width
        let cellWidth = viewWidth / 4
        var cellHeight = viewHeight.divided(by: CGFloat(appEntries.count))
        if appEntries.count < 5 {
            cellHeight = viewWidth.divided(by: 5)
        }
        let device = Device()
        if device.isPhone {
            return CGSize(width: viewWidth, height: cellHeight)
        } else if device.isPad {
            return CGSize(width: cellWidth, height: cellHeight)
            
        }
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    
    @IBAction func gotoBackView(_ sender: Any) {
        print("backview")
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    
    func updateViewData() {
        
        self.feedCollectionView.reloadData()
        SwiftSpinner.hide()
        
        if !isConnectedToNetwork() {
            displayAlertMessage(viewController: self, message: "Te encuentras sin conexión, observarás datos guardados en caché", sender: self.view)
        }
    }
}


