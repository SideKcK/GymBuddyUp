//
//  SearchUserViewController.swift
//  GymBuddyUp
//
//  Created by Yi Huang on 2016/10/17.
//  Copyright © 2016年 You Wu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import Alamofire
import AlamofireImage

class SearchUserViewController: UIViewController {
    private let ref:FIRDatabaseReference! = FIRDatabase.database().reference().child("user_info")
    private var listenerHandle: FIRDatabaseHandle = 0
    var tableView: UITableView!
    var searchController: UISearchController!
    var usersFound = [User]()
    var hidden = false
    static let searchField = "screen_name"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cancelBarButton = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: #selector(onCancelCallback))
        self.navigationItem.setLeftBarButtonItem(cancelBarButton, animated: true)
        setupViews()
        setupVisual()
        
        // Do any additional setup after loading the view.
    }
    
    func setupViews() {
        // myself
        title = "Search"
        self.edgesForExtendedLayout = UIRectEdge.None
        self.extendedLayoutIncludesOpaqueBars = true
        definesPresentationContext = true

        // Add tableView
        tableView = UITableView(frame: view.bounds)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(UINib(nibName: "BuddyCardCell", bundle: nil), forCellReuseIdentifier: "BuddyCardCell")
        tableView.backgroundColor = ColorScheme.s3Bg
        tableView.separatorColor = UIColor.clearColor()
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        
        view.addSubview(tableView)
        
        // Add a search bar
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.scopeButtonTitles = []
        tableView.tableHeaderView = searchController.searchBar
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.searchBarStyle = UISearchBarStyle.Prominent

        
        // Customize the appearance of the search bar
        
        searchController.searchBar.placeholder = "Search new friends by username"
        searchController.searchBar.autocapitalizationType = .None
        searchController.searchBar.autocorrectionType = .No
        searchController.searchBar.backgroundColor = UIColor.clearColor()
        searchController.searchBar.showsScopeBar = false
        searchController.searchBar.delegate = self
    }
    
    
    func doSearch(text: String) {
        Log.info("keyword = \(text)")
        usersFound.removeAll()
        let searchField = SearchUserViewController.searchField
        let query = ref.queryOrderedByChild(searchField).queryEqualToValue(text)
        listenerHandle = query.observeEventType(FIRDataEventType.ChildAdded) { (snapshot: FIRDataSnapshot) in
            let user = User(snapshot: snapshot)
            UserCache.sharedInstance.cache[user.userId] = user
            self.usersFound.append(user)
            self.tableView.reloadData()
        }
    }
    
    func setupVisual() {
        view.backgroundColor = ColorScheme.s3Bg
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        if hidden == false {
            return UIStatusBarAnimation.Fade
        } else {
            return UIStatusBarAnimation.Slide
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        print("\nstatus Bar Changed to hidden = \(hidden)\n")
        return hidden
    }
    
    func onCancelCallback() {
        Log.info("cancel button clicked")
        self.dismissViewControllerAnimated(true) { 
            Log.info("dismissed")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SearchUserViewController: BuddyCardCellAddFriend {
    func buddyCardCell(buddyCardCell: BuddyCardCell, selectedUserId: String) {
        Log.info("sending friend request")
        Friend.sendFriendRequest(selectedUserId) { (error: NSError?) in
            if (error == nil) {
                Log.info("friend request sent successfully")
                UserCache.sharedInstance.cache[selectedUserId]?.canBeFriend = false
                let index = self.tableView.indexPathForCell(buddyCardCell)
                self.tableView.reloadRowsAtIndexPaths([index!], withRowAnimation: .None)
                
            }
        }
    }
}

extension SearchUserViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        return true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        
        ref.removeObserverWithHandle(listenerHandle)
        Log.info("cancel")
    }
    
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        Log.info("going to get specific user info")
        if let typedText = searchBar.text {
            doSearch(typedText)
        }
    }
}

extension SearchUserViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15.0
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        Log.info("going to display header")
        if section == 0 {
            view.hidden = true
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BuddyCardCell", forIndexPath: indexPath) as! BuddyCardCell
        let index = indexPath.row
        let buddy = usersFound[index]
        let asyncIdentifer = buddy.userId
        cell.addButton.enabled = buddy.canBeFriend
        cell.asyncIdentifer = asyncIdentifer
        if let user = UserCache.sharedInstance.cache[asyncIdentifer] {
            if let photoURL = user.photoURL where user.cachedPhoto == nil {
                let request = NSMutableURLRequest(URL: photoURL)
                cell.profileView.af_setImageWithURLRequest(request, placeholderImage: UIImage(named: "selfie"), filter: nil, progress: nil, imageTransition: UIImageView.ImageTransition.None, runImageTransitionIfCached: false) { (response: Response<UIImage, NSError>) in
                    if asyncIdentifer == cell.asyncIdentifer {
                        cell.profileView.image = response.result.value
                        user.cachedPhoto = response.result.value
                    }
                }
            } else {
                cell.profileView.image = user.cachedPhoto
            }
        }
        cell.delegate = self
        cell.nameLabel.text = buddy.screenName
        cell.goalLabel.hidden = true
        cell.gymLabel.hidden = true
        cell.showAddButton()
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersFound.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.selected = false
    }

}

