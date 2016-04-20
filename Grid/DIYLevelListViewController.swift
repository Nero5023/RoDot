//
//  DIYLevelListViewController.swift
//  Grid
//
//  Created by Nero Zuo on 16/4/20.
//  Copyright © 2016年 Nero. All rights reserved.
//

import UIKit
import CoreData

class DIYLevelListViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  
  var fetchedResultsController: NSFetchedResultsController!
  let CellIdentifier = "Cell"
  
  override func viewDidLoad() {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    self.tableView.tableFooterView = UIView()
    
    let levelFetchRequset = NSFetchRequest(entityName: "Level")
    let dateScort = NSSortDescriptor(key: "date", ascending: false)
    levelFetchRequset.sortDescriptors = [dateScort]
    fetchedResultsController = NSFetchedResultsController(fetchRequest: levelFetchRequset, managedObjectContext: SceneManager.sharedInstance.managedContext, sectionNameKeyPath: nil, cacheName: nil)
    fetchedResultsController.delegate = self
    do {
      try fetchedResultsController.performFetch()
    } catch let error as NSError {
      print("Error: \(error.localizedDescription)")
    }
    
  }
  
  func configureCell(cell: DIYLevelTableViewCell, indexPath: NSIndexPath) {
    let level = fetchedResultsController.objectAtIndexPath(indexPath) as! Level
    cell.levelName.text = level.name
    if indexPath.row % 2 == 1 {
      cell.backgroundColor = UIColor(red: 90/255.0, green: 164/255.0, blue: 253/255.0, alpha: 1)
      cell.levelName.textColor = UIColor.whiteColor()
    }else {
      cell.backgroundColor = UIColor.whiteColor()
      cell.levelName.textColor = UIColor.blackColor()
      
    }
    cell.contentView.backgroundColor = UIColor.clearColor()
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  @IBAction func close(sender: UIBarButtonItem) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
}



extension DIYLevelListViewController: UITableViewDataSource {
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    if fetchedResultsController == nil {
      return 0
    }
    if let sceesions = fetchedResultsController.sections {
      return sceesions.count
    }else {
      return 0
    }
  }
  
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    let sectionInfo =
//      fetchedResultsController.sections![section]
    if fetchedResultsController == nil {
      return 0
    }
    if let sessions = fetchedResultsController.sections {
      return sessions[section].numberOfObjects
    }else {
      return 0
    }
  }
  
  func tableView(tableView: UITableView,
                 cellForRowAtIndexPath indexPath: NSIndexPath)
    -> UITableViewCell {
      
      let cell =
        tableView.dequeueReusableCellWithIdentifier(
          CellIdentifier, forIndexPath: indexPath)
          as! DIYLevelTableViewCell
      
      configureCell(cell, indexPath: indexPath)
      
      return cell
  }
  
//  override func motionEnded(motion: UIEventSubtype,
//                            withEvent event: UIEvent?) {
//    
//    if motion == .MotionShake {
//      addButton.enabled = true
//    }
//    
//  }
  
}


extension DIYLevelListViewController: UITableViewDelegate {
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let level = fetchedResultsController.objectAtIndexPath(indexPath) as! Level
    let nodes: [Dictionary<String, String>] = level.nodes!.map{ node in
      //      $0 as! Node
      let node = node as! Node
      return ["name": node.name!, "position": node.position!,
        "zRotation": String(node.zRotation!), "type": node.type!]
    }
    let scene = LevelEditPlayScene.editSceneFromNodesData(nodes, sceneType: .selfPlay(level.name))
    scene!.scaleMode = .AspectFill
    SceneManager.sharedInstance.presentingView.presentScene(scene)
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
  
  func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == UITableViewCellEditingStyle.Delete {
      let levelToMove = fetchedResultsController.objectAtIndexPath(indexPath) as! Level
      SceneManager.sharedInstance.managedContext.deleteObject(levelToMove)
      do {
        try SceneManager.sharedInstance.managedContext.save()
      }catch let error as NSError {
        print("Could not save: \(error)")
      }
//      controller(fetchedResultsController, didChangeObject: levelToMove, atIndexPath: indexPath, forChangeType: .Delete, newIndexPath: nil)
    }
//    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
  }
  
  
}

extension DIYLevelListViewController: NSFetchedResultsControllerDelegate {
  
  func controllerWillChangeContent(controller:
    NSFetchedResultsController) {
    tableView.beginUpdates()
  }
  
  func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
    
    switch type {
    case .Insert:
      tableView.insertRowsAtIndexPaths([newIndexPath!],
                                       withRowAnimation: .Automatic)
    case .Delete:
      tableView.deleteRowsAtIndexPaths([indexPath!],
                                       withRowAnimation: .Automatic)
    case .Update:
      let cell = tableView.cellForRowAtIndexPath(indexPath!)
        as! DIYLevelTableViewCell
      configureCell(cell, indexPath: indexPath!)
    case .Move:
      tableView.deleteRowsAtIndexPaths([indexPath!],
                                       withRowAnimation: .Automatic)
      tableView.insertRowsAtIndexPaths([newIndexPath!],
                                       withRowAnimation: .Automatic)
    }
  }
  
  func controllerDidChangeContent(controller:
    NSFetchedResultsController) {
    tableView.endUpdates()
  }
  
  func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
    
    let indexSet = NSIndexSet(index: sectionIndex)
    
    switch type {
    case .Insert:
      tableView.insertSections(indexSet,
                               withRowAnimation: .Automatic)
    case .Delete:
      tableView.deleteSections(indexSet,
                               withRowAnimation: .Automatic)
    default :
      break
    }
  }
  
}


