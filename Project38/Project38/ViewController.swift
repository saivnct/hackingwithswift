//
//  ViewController.swift
//  Project38
//
//  Created by Giang Bb on 10/30/18.
//  Copyright © 2018 Giang Bb. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController,NSFetchedResultsControllerDelegate {

    //We’re going to create the NSPersistentContainer as a property
    var container: NSPersistentContainer!
    
//    var commits = [Commit]() //You can get an idea of what work needs to be done by deleting the commits property: we don't need it any more, because the fetched results controller stores our results.
    
    var commitPredicate: NSPredicate? //predicate is a filter: you specify the criteria you want to match, and Core Data will ensure that only matching objects get returned
    
    var fetchedResultsController: NSFetchedResultsController<Commit>! //Optimizing Core Data Performance using NSFetchedResultsController
    //NSFetchedResultsController. It takes over our existing NSFetchRequest to load data, replaces our commits array with its own storage, and even works to ensure the user interface stays in sync with changes to the data by controlling the way objects are inserted and deleted
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(changeFilter))

        
        //load data model into a managed object context for reading and writing
        //To set up the basic Core Data system, we need to write code that will do the following:
        //1. Load our data model we just created from the application bundle and create a NSManagedObjectModel object from it.
        //2. Create an NSPersistentStoreCoordinator object, which is responsible for reading from and writing to disk.
        //3. Set up a URL pointing to the database on disk where our actual saved objects live. This will be an SQLite database named Project38.sqlite.
        //4. Load that database into the NSPersistentStoreCoordinator so it knows where we want it to save. If it doesn't exist, it will be created automatically
        //5. Create an NSManagedObjectContext and point it at the persistent store coordinator.
        
        //Beautifully, brilliantly, all five of those steps are exactly what NSPersistentContainer does for us. So what used to be 15 to 20 lines of code is now summed up in just six – add this to viewDidLoad() now:
        container = NSPersistentContainer(name: "Project38")    //creates the persistent container, and must be given the name of the Core Data model file we created earlier: “Project38”
        container.loadPersistentStores { storeDescription, error in //Loads the saved database if it exists, or creates it otherwise
            
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy //This instructs Core Data to allow updates to objects: if an object exists in its data store with message A, and an object with the same unique constraint ("sha" attribute) exists in memory with message B, the in-memory version "trumps" (overwrites) the data store version

            
            //If any errors come back here you’ll know something has gone fatally wrong, but if it succeeds then you can be guaranteed the data has loaded and you’re ready to continue
            if let error = error {
                print("Unresolved error \(error)")
            }
        }
        
        
        performSelector(inBackground: #selector(fetchCommits), with: nil)
        loadSavedData()
    }
    
//    func loadSavedData() {
//        let request = Commit.createFetchRequest()
//        let sort = NSSortDescriptor(key: "date", ascending: false)
//        request.sortDescriptors = [sort]
//        request.predicate = commitPredicate
//
//        do {
//            commits = try container.viewContext.fetch(request)
//            print("Got \(commits.count) commits")
//            tableView.reloadData()
//        } catch {
//            print("Fetch failed")
//        }
//    }
    
    //We now need to rewrite our loadSavedData() method so that the existing NSFetchRequest is wrapped inside a NSFetchedResultsController. We want to create that fetched results controller only once, but retain the ability to change the predicate when the method is called again
    func loadSavedData() {
        if fetchedResultsController == nil {
            let request = Commit.createFetchRequest()
//            let sort = NSSortDescriptor(key: "date", ascending: false)
//            request.sortDescriptors = [sort]
            let sort = NSSortDescriptor(key: "author.name", ascending: true)
            request.sortDescriptors = [sort]
            request.fetchBatchSize = 20 //only 20 objects are loaded at a time
            
//            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: container.viewContext, sectionNameKeyPath: "author.name", cacheName: nil)
            fetchedResultsController.delegate = self
        }
        
        fetchedResultsController.fetchRequest.predicate = commitPredicate
        
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            print("Fetch failed")
        }
        //when you use NSFetchedResultsController, you need to use it everywhere: that means it tells you how many sections and rows you have, it keeps track of all the objects, and it is the single source of truth when it comes to inserting or deleting objects
        //You can get an idea of what work needs to be done by deleting the commits property: we don't need it any more, because the fetched results controller stores our results.
    }
    
    
    //We'll be adding the getNewestCommitDate() method shortly, but what it will return is a date formatted as an ISO-8601 string. This date will be set to one second after our most recent commit, and we can send that to the GitHub API using its "since" parameter to receive back only newer commits
    func getLastedCommitDateLocal() -> String {
        let formatter = ISO8601DateFormatter()
        
        let newest = Commit.createFetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        newest.sortDescriptors = [sort]
        newest.fetchLimit = 1
        
        if let commits = try? container.viewContext.fetch(newest) {
            if commits.count > 0 {
                return formatter.string(from: commits[0].date.addingTimeInterval(1))
            }
        }
        
        return formatter.string(from: Date(timeIntervalSince1970: 0)) //If no valid date is found, the method returns a date from the 1st of January 1970, which will reproduce the same behavior we had before introducing this date chang
    }
    
    @objc func fetchCommits() {
        let lastedCommitDateLocal = getLastedCommitDateLocal()
        
        if let data = try? String(contentsOf: URL(string: "https://api.github.com/repos/apple/swift/commits?per_page=100&since=\(lastedCommitDateLocal)")!) {
            // give the data to SwiftyJSON to parse
            let jsonCommits = JSON(parseJSON: data)
            
            // read the commits back out
            let jsonCommitArray = jsonCommits.arrayValue
            
            print("Received \(jsonCommitArray.count) new commits.")
            
            DispatchQueue.main.async { [unowned self] in
                for jsonCommit in jsonCommitArray {
                    let commit = Commit(context: self.container.viewContext)    //creates a Commit object inside the managed object context given to us by the NSPersistentContainer we created
                    self.configure(commit: commit, usingJSON: jsonCommit)
                }
                
                self.saveContext()
                self.loadSavedData()
            }
        }
    }
    
    func configure(commit: Commit, usingJSON json: JSON) {
        commit.sha = json["sha"].stringValue
        commit.message = json["commit"]["message"].stringValue //if "commit" or "message" don't exist, or if they do exist but actually contains an integer for some reason, we'll get back an empty string – it makes JSON parsing extremely safe while being easy to read and write
        commit.url = json["html_url"].stringValue
        
        let formatter = ISO8601DateFormatter()
        commit.date = formatter.date(from: json["commit"]["committer"]["date"].stringValue) ?? Date()
        
        var commitAuthor: Author!
        
        // see if this author exists already
        let authorRequest = Author.createFetchRequest()
        authorRequest.predicate = NSPredicate(format: "name == %@", json["commit"]["committer"]["name"].stringValue)
        
        if let authors = try? container.viewContext.fetch(authorRequest) { //used try? for fetch() this time, because we don't really care if the request failed: it will still fall through and get caught by the if commitAuthor == nil check later on
            if authors.count > 0 {
                // we have this author already
                commitAuthor = authors[0]
            }
        }
        
        if commitAuthor == nil {
            // we didn't find a saved author - create a new one!
            let author = Author(context: container.viewContext)
            author.name = json["commit"]["committer"]["name"].stringValue
            author.email = json["commit"]["committer"]["email"].stringValue
            commitAuthor = author
        }
        
        // use the author, either saved or new
        commit.author = commitAuthor
    }
    
    //We'll be calling this func whenever we've made changes that should be saved to disk
    func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("An error occurred while saving: \(error)")
            }
        }
    }
    
    @objc func changeFilter() {
        let ac = UIAlertController(title: "Filter commits…", message: nil, preferredStyle: .actionSheet)
        
        // 1
        ac.addAction(UIAlertAction(title: "Show only fixes", style: .default) { [unowned self] _ in
            //The CONTAINS part will ensure this predicate matches only objects that contain a string somewhere in their message – in our case, that's the text "fix". The [c] part is predicate-speak for "case-insensitive", which means it will match "FIX", "Fix", "fix" and so on. Note that we need to use self. twice inside the closure to make capturing explicit
            self.commitPredicate = NSPredicate(format: "message CONTAINS[c] 'fix'")
            self.loadSavedData()
        })
        // 2
        ac.addAction(UIAlertAction(title: "Ignore Pull Requests", style: .default) { [unowned self] _ in
            //BEGINSWITH works just like CONTAINS except the matching text must be at the start of a string
            self.commitPredicate = NSPredicate(format: "NOT message BEGINSWITH 'Merge pull request'")
            self.loadSavedData()
        })
        // 3
        ac.addAction(UIAlertAction(title: "Show only recent", style: .default) { [unowned self] _ in
            //we're going to request only commits that took place 43,200 seconds ago, which is equivalent to half a day
            let twelveHoursAgo = Date().addingTimeInterval(-43200)
            self.commitPredicate = NSPredicate(format: "date > %@", twelveHoursAgo as NSDate) //As you can see, we’ve hit the NSDate vs Date problem again: Core Data wants to work with the old type, so we typecast using as
            self.loadSavedData()
        })
        // 4
        ac.addAction(UIAlertAction(title: "Show all commits", style: .default) { [unowned self] _ in
            //we're just going to set commitPredicate to be nil so that all commits are shown again
            self.commitPredicate = nil
            self.loadSavedData()
        })
        //5
        ac.addAction(UIAlertAction(title: "Show only Joe's commits", style: .default) { [unowned self] _ in
            //By using author.name the predicate will perform two steps: it will find the "author" relation for our commit, then look up the "name" attribute of the matching object
            self.commitPredicate = NSPredicate(format: "author.name == 'Joe Groff'")
            self.loadSavedData()
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultsController.sections![section].name
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // we can read the sections array, each of which contains an array of NSFetchedResultsSectionInfo objects describing the items in that section
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Commit", for: indexPath)
        
//        let commit = commits[indexPath.row]
        let commit = fetchedResultsController.object(at: indexPath)
        cell.textLabel!.text = commit.message
        
        cell.detailTextLabel!.text = "By \(commit.author.name) on \(commit.date.description)"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
//            vc.detailItem = commits[indexPath.row]
            vc.detailItem = fetchedResultsController.object(at: indexPath)
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //1) pulls out the Commit object that the user selected to delete,
            //2) removes it from the managed object context,
            //3) removes it from the commits array,
            //4) deletes it from the table view, then
            //5) saves the context.
            //Remember: you must call saveContext() whenever you want your changes to persist
//            let commit = commits[indexPath.row]
            let commit = fetchedResultsController.object(at: indexPath)
            container.viewContext.delete(commit)
//            commits.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
            
            saveContext()
            //when we created our NSFetchedResultsController, we hooked it up to our existing managed object context, and we also made our current view controller its delegate. So when the managed object context detects an object being deleted, it will inform our fetched results controller, which will in turn automatically notify our view controller if needed in didChange method below
        }
    }
    
    // we do need to add one new method that gets called by the fetched results controller when an object changes. We'll get told the index path of the object that got changed
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            
        default:
            break
        }
    }

}

