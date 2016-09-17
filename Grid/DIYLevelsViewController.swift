//
//  DIYLevelsViewController.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/31.
//  Copyright © 2016年 Nero. All rights reserved.
//

import UIKit
import CoreData

class DIYLevelsViewController: UITableViewController {
  
  
  let CellIdentifier = "Cell"
  
  var levels = [Level]()
  
  var fetchedResultsController: NSFetchedResultsController<AnyObject>!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
    self.tableView.tableFooterView = UIView()
    self.levels = SceneManager.sharedInstance.fetchAllLevels()
    
    let levelFetchRequset = NSFetchRequest(entityName: "Level")
    let dateScort = NSSortDescriptor(key: "date", ascending: false)
    levelFetchRequset.sortDescriptors = [dateScort]
    fetchedResultsController = NSFetchedResultsController(fetchRequest: levelFetchRequset, managedObjectContext: SceneManager.sharedInstance.managedContext, sectionNameKeyPath: nil, cacheName: nil)
    do {
      try fetchedResultsController.performFetch()
    } catch let error as NSError {
      print("Error: \(error.localizedDescription)")
    }
//    tableView.reloadData()
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return levels.count
//    let sectionInfo = fetchedResultsController.sections![section]
//    return sectionInfo.numberOfObjects
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath) as! DIYLevelTableViewCell
    let level = levels[(indexPath as NSIndexPath).row]
    cell.levelName.text = level.name
    if (indexPath as NSIndexPath).row % 2 == 1 {
      cell.backgroundColor = UIColor(red: 90/255.0, green: 164/255.0, blue: 253/255.0, alpha: 1)
      cell.levelName.textColor = UIColor.white
    }else {
      cell.backgroundColor = UIColor.white
      cell.levelName.textColor = UIColor.black

    }
    cell.contentView.backgroundColor = UIColor.clear
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let level = levels[(indexPath as NSIndexPath).row]
    let nodes: [Dictionary<String, String>] = level.nodes!.map{ node in
//      $0 as! Node
      let node = node as! Node
      return ["name": node.name!, "position": node.position!,
        "zRotation": String(describing: node.zRotation!), "type": node.type!]
    }
    let scene = LevelEditPlayScene.editSceneFromNodesData(nodes, sceneType: .selfPlay(level.name, levelObjectId: "\(level.objectID)"))
    scene!.scaleMode = .aspectFill
    SceneManager.sharedInstance.presentingView.presentScene(scene)
    self.dismiss(animated: true, completion: nil)
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == UITableViewCellEditingStyle.delete {
      let levelToMove = levels[(indexPath as NSIndexPath).row]
      levels = levels.filter{ $0 != levelToMove }
      SceneManager.sharedInstance.managedContext.delete(levelToMove)
      do {
        try SceneManager.sharedInstance.managedContext.save()
      }catch let error as NSError {
        print("Could not save: \(error)")
      }
    }
    tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
  }
  
  override var prefersStatusBarHidden : Bool {
    return true
  }
  
  @IBAction func doneButton(_ sender: UIBarButtonItem) {
    self.dismiss(animated: true, completion: nil)
  }
  
  func configureCell(_ cell: DIYLevelTableViewCell, indexPath: IndexPath) {
    let level = fetchedResultsController.object(at: indexPath) as! Level
    cell.levelName.text = level.name
  }
}
