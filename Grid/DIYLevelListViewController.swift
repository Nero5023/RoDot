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
  
  var fetchedResultsController: NSFetchedResultsController<AnyObject>!
  let CellIdentifier = "Cell"
  
  override func viewDidLoad() {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
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
  
  func configureCell(_ cell: DIYLevelTableViewCell, indexPath: IndexPath) {
    let level = fetchedResultsController.object(at: indexPath) as! Level
    cell.levelName.text = level.name
    if (indexPath as NSIndexPath).row % 2 == 1 {
      cell.backgroundColor = UIColor(red: 90/255.0, green: 164/255.0, blue: 253/255.0, alpha: 1)
      cell.levelName.textColor = UIColor.white
    }else {
      cell.backgroundColor = UIColor.white
      cell.levelName.textColor = UIColor.black
      
    }
    cell.contentView.backgroundColor = UIColor.clear
  }
  
  override var prefersStatusBarHidden : Bool {
    return true
  }
  
  @IBAction func close(_ sender: UIBarButtonItem) {
    self.dismiss(animated: true, completion: nil)
  }
}



extension DIYLevelListViewController: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    if fetchedResultsController == nil {
      return 0
    }
    if let sceesions = fetchedResultsController.sections {
      return sceesions.count
    }else {
      return 0
    }
  }
  
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
  
  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath)
    -> UITableViewCell {
      
      let cell =
        tableView.dequeueReusableCell(
          withIdentifier: CellIdentifier, for: indexPath)
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
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let level = fetchedResultsController.object(at: indexPath) as! Level
    let nodes: [Dictionary<String, String>] = level.nodes!.map{ node in
      //      $0 as! Node
      let node = node as! Node
      return ["name": node.name!, "position": node.position!,
        "zRotation": String(node.zRotation!), "type": node.type!]
    }
    let scene = LevelEditPlayScene.editSceneFromNodesData(nodes, sceneType: .selfPlay(level.name, levelObjectId: "\(level.objectID)"))
    scene!.scaleMode = .aspectFill
    SceneManager.sharedInstance.presentingView.presentScene(scene)
    self.dismiss(animated: true, completion: nil)
  }
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == UITableViewCellEditingStyle.delete {
      let levelToMove = fetchedResultsController.object(at: indexPath) as! Level
      SceneManager.sharedInstance.managedContext.delete(levelToMove)
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
  
  func controllerWillChangeContent(_ controller:
    NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.beginUpdates()
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    
    switch type {
    case .insert:
      tableView.insertRows(at: [newIndexPath!],
                                       with: .automatic)
    case .delete:
      tableView.deleteRows(at: [indexPath!],
                                       with: .automatic)
    case .update:
      let cell = tableView.cellForRow(at: indexPath!)
        as! DIYLevelTableViewCell
      configureCell(cell, indexPath: indexPath!)
    case .move:
      tableView.deleteRows(at: [indexPath!],
                                       with: .automatic)
      tableView.insertRows(at: [newIndexPath!],
                                       with: .automatic)
    }
  }
  
  func controllerDidChangeContent(_ controller:
    NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.endUpdates()
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    
    let indexSet = IndexSet(integer: sectionIndex)
    
    switch type {
    case .insert:
      tableView.insertSections(indexSet,
                               with: .automatic)
    case .delete:
      tableView.deleteSections(indexSet,
                               with: .automatic)
    default :
      break
    }
  }
  
}


