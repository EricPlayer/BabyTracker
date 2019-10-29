//
//  AppDelegate.swift
//  BabyTracker
//
//  Created by Eric on 2019/10/15.
//  Copyright © 2019 fatih. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import SwiftyXMLParser
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var engLang = [Localization]()
    var fchLang = [Localization]()
    var gerLang = [Localization]()
    var ityLang = [Localization]()
    var korLang = [Localization]()
    var babySleepTimers = [SleepModel]()
    var babyLBreastTimers = [SleepModel]()
    var babyRBreastTimers = [SleepModel]()
    var lang = 0, volume = 0
    var parentKey = ""


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if let path = Bundle.main.path(forResource: "lang", ofType: "xml") {
            do {
                let data = try String(contentsOfFile: path, encoding: .utf8)
                //                let myStrings = data.components(separatedBy: .newlines)
                let xml = try! XML.parse(data)
                
                for element in xml.catalog.eng.item {
                    let localization = Localization(key: element.attributes["key"]!, value: element.text!)
                    engLang.append(localization)
                }
                
                for element in xml.catalog.fch.item {
                    let localization = Localization(key: element.attributes["key"]!, value: element.text!)
                    fchLang.append(localization)
                }
                
                for element in xml.catalog.ger.item {
                    let localization = Localization(key: element.attributes["key"]!, value: element.text!)
                    gerLang.append(localization)
                }
                
                for element in xml.catalog.ity.item {
                    let localization = Localization(key: element.attributes["key"]!, value: element.text!)
                    ityLang.append(localization)
                }
                
                for element in xml.catalog.kor.item {
                    let localization = Localization(key: element.attributes["key"]!, value: element.text!)
                    korLang.append(localization)
                }
            } catch {
                print(error)
            }
        }
        
        self.lang = self.getLangType()
        self.volume = self.getVolumeType()
        parentKey = self.getParentKey()
        if parentKey == "" {
            let apiUrl = ApiConfig.serverUrl + ApiConfig.addParent
            Alamofire.request(apiUrl, method: .post, encoding: URLEncoding.default).validate().responseJSON{ response in
                switch response.result {
                case .success:
                    let responseData = response.result.value as! [String: Any]
                    let parentKey = responseData["parent_key"] as! String
                    self.setParentKey(key: parentKey)
                    self.parentKey = parentKey
                case .failure(let error):
                    print("failed to load parentdata: \(error.localizedDescription)")
                }
            }
        }
        
        babySleepTimers.removeAll()
        babyLBreastTimers.removeAll()
        babyRBreastTimers.removeAll()
        GADMobileAds.sharedInstance().start(completionHandler: nil)
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
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "config")
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
    
    // MARK: - Core Data Saving support
    
    func saveContext() {
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
    
    func setLangType(value: Int) {
        
        let managedContext = self.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LangEntity")
        
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do { try managedContext.execute(DelAllReqVar) }
        catch { print(error) }
        
        let projectEntity = NSEntityDescription.entity(forEntityName: "LangEntity", in: managedContext)!
        
        let language = NSManagedObject(entity: projectEntity, insertInto: managedContext)
        language.setValue(value, forKeyPath: "value")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func getLangType() -> Int {
        var result: NSManagedObject? = nil
        
        let managedContext = self.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LangEntity")
        
        do {
            let data = try managedContext.fetch(fetchRequest)
            if data.count > 0 {
                result = data[0] as? NSManagedObject
                return result?.value(forKey: "value") as! Int
            } else {
                return 0
            }
        } catch let error as NSError {
            print("Could not retrieve. \(error), \(error.userInfo)")
        }
        return 0
    }
    
    func setVolumeType(value: Int) {
        
        let managedContext = self.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "VolumeEntity")
        
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do { try managedContext.execute(DelAllReqVar) }
        catch { print(error) }
        
        let projectEntity = NSEntityDescription.entity(forEntityName: "VolumeEntity", in: managedContext)!
        
        let language = NSManagedObject(entity: projectEntity, insertInto: managedContext)
        language.setValue(value, forKeyPath: "value")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func getVolumeType() -> Int {
        var result: NSManagedObject? = nil
        
        let managedContext = self.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "VolumeEntity")
        
        do {
            let data = try managedContext.fetch(fetchRequest)
            if data.count > 0 {
                result = data[0] as? NSManagedObject
                return result?.value(forKey: "value") as! Int
            } else {
                return 0
            }
        } catch let error as NSError {
            print("Could not retrieve. \(error), \(error.userInfo)")
        }
        return 0
    }
    
    func getLocalization(type: Int, key: String) -> String {
        var result = ""
        switch type {
        case 1:
            for localization in self.fchLang {
                if localization.getKey() == key {
                    result = localization.getValue()
                    break
                }
            }
            break
        case 2:
            for localization in self.gerLang {
                if localization.getKey() == key {
                    result = localization.getValue()
                    break
                }
            }
            break
        case 3:
            for localization in self.ityLang {
                if localization.getKey() == key {
                    result = localization.getValue()
                    break
                }
            }
            break
        case 4:
            for localization in self.korLang {
                if localization.getKey() == key {
                    result = localization.getValue()
                    break
                }
            }
            break
        default:
            for localization in self.engLang {
                if localization.getKey() == key {
                    result = localization.getValue()
                    break
                }
            }
            break
        }
        return result
    }
    
    func setParentKey(key: String) {
        
        let managedContext = self.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ParentEntity")
        
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do { try managedContext.execute(DelAllReqVar) }
        catch { print(error) }
        
        let projectEntity = NSEntityDescription.entity(forEntityName: "ParentEntity", in: managedContext)!
        
        let parent = NSManagedObject(entity: projectEntity, insertInto: managedContext)
        parent.setValue(key, forKeyPath: "key")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func getParentKey() -> String {
        var result: NSManagedObject? = nil
        
        let managedContext = self.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ParentEntity")
        
        do {
            let data = try managedContext.fetch(fetchRequest)
            if data.count > 0 {
                result = data[0] as? NSManagedObject
                return result?.value(forKey: "key") as! String
            } else {
                return ""
            }
        } catch let error as NSError {
            print("Could not retrieve. \(error), \(error.userInfo)")
        }
        return ""
    }
}

