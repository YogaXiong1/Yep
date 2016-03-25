//
//  YepTabBarController.swift
//  Yep
//
//  Created by kevinzhow on 15/3/28.
//  Copyright (c) 2015年 Catch Inc. All rights reserved.
//

import UIKit
import RealmSwift

var detailViewColumnWidth: CGFloat  = 0
var primaryViewColumnWidth: CGFloat = 0
var masterSelectedTap: Int = 0

class YepTabBarController: UITabBarController {
    
    var detailViewController:DetailViewController?
    
    
    enum Tab: Int {
        
        case Conversations
        case Contacts
        //case Feeds
        case Discover
        case Profile
        
        var title: String {
            
            switch self {
            case .Conversations:
                return NSLocalizedString("Chats", comment: "")
            case .Contacts:
                return NSLocalizedString("Contacts", comment: "")
                /*case .Feeds:
                 return NSLocalizedString("Feeds", comment: "")*/
            case .Discover:
                return NSLocalizedString("Discover", comment: "")
            case .Profile:
                return NSLocalizedString("Profile", comment: "")
            }
        }
    }
    
    private var previousTab = Tab.Conversations
    
    private var checkDoubleTapOnFeedsTimer: NSTimer?
    private var hasFirstTapOnFeedsWhenItIsAtTop = false {
        willSet {
            if newValue {
                let timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(YepTabBarController.checkDoubleTapOnFeeds(_:)), userInfo: nil, repeats: false)
                checkDoubleTapOnFeedsTimer = timer
                
            } else {
                checkDoubleTapOnFeedsTimer?.invalidate()
            }
        }
    }
    
    @objc private func checkDoubleTapOnFeeds(timer: NSTimer) {
        
        hasFirstTapOnFeedsWhenItIsAtTop = false
    }
    
    private struct Listener {
        static let lauchStyle = "YepTabBarController.lauchStyle"
    }
    
    deinit {
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            appDelegate.lauchStyle.removeListenerWithName(Listener.lauchStyle)
        }
        
        println("deinit YepTabBar")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible
        
        delegate = self
        view.backgroundColor = UIColor.whiteColor()
        
        
        // 将 UITabBarItem 的 image 下移一些，也不显示 title 了
        /*
         if let items = tabBar.items as? [UITabBarItem] {
         for item in items {
         item.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
         item.title = nil
         }
         }
         */
        
        // Set Titles
        
        if let items = tabBar.items {
            for i in 0..<items.count {
                let item = items[i]
                item.title = Tab(rawValue: i)?.title
            }
        }
        
        // 处理启动切换
        
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            appDelegate.lauchStyle.bindListener(Listener.lauchStyle) { [weak self] style in
                if style == .Message {
                    self?.selectedIndex = 0
                }
            }
        }
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let columnWidth = self.splitViewController?.primaryColumnWidth {
            primaryViewColumnWidth = columnWidth
            detailViewColumnWidth  = UIScreen.mainScreen().bounds.width - columnWidth
        }
    }
    
    func showProfile() {
        
        print("\(self.tabBarController)___self.navigationController__\(((UIApplication.sharedApplication().delegate as! AppDelegate).window?.rootViewController as! UISplitViewController).childViewControllers[0].childViewControllers[masterSelectedTap])")
        
        if let nav = ((UIApplication.sharedApplication().delegate as! AppDelegate).window?.rootViewController as! UISplitViewController).childViewControllers[0].childViewControllers[masterSelectedTap] as? YepNavigationController {
            let profile = ProfileViewController()
            nav.pushViewController(profile, animated: true)
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showDetailView" {
            
            if let detailNav = segue.destinationViewController as? YepNavigationController,
                detail = detailNav.topViewController,
                index  = detailNav.viewControllers.indexOf(detail),
                tab = Tab(rawValue: selectedIndex) {
                
                var detailControllersStack = detailNav.viewControllers
                
                switch tab {
                case .Conversations:
                    break
                case .Contacts:
                    break
                case .Discover:
                    
                    let detailVC = DetailViewController()
                    detailControllersStack[index] = detailVC
                    detailNav.setViewControllers(detailControllersStack, animated: true)
                    
                case .Profile:
                    
                    let feedsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("FeedsViewController") as! FeedsViewController
                    detailControllersStack[index] = feedsVC
                    detailNav.setViewControllers(detailControllersStack, animated: true)
                    if let user = ((sender as? Box<User>)?.value), profileUser: ProfileUser = .UserType(user), feedsVC = detailControllersStack[index] as? FeedsViewController {
                        feedsVC.profileUser = profileUser
                        feedsVC.setupFeedsForProfileUser(user: profileUser)
                    }
                }
            }
        }
        
        //        if segue.identifier == "showProfile" {
        //            let vc = segue.destinationViewController as! ProfileViewController
        //
        //            if let user = sender as? User {
        //                vc.profileUser = ProfileUser.UserType(user)
        //
        //            } else {
        //                if let withFriend = conversation?.withFriend {
        //                    if withFriend.userID != YepUserDefaults.userID.value {
        //                        vc.profileUser = ProfileUser.UserType(withFriend)
        //                    }
        //                }
        //            }
        //
        //            switch conversation.type {
        //            case ConversationType.OneToOne.rawValue:
        //                vc.fromType = .OneToOneConversation
        //            case ConversationType.Group.rawValue:
        //                vc.fromType = .GroupConversation
        //            default:
        //                break
        //            }
        
        //        }
        /*
         var isTabBarVisible: Bool {
         return self.tabBar.frame.origin.y < CGRectGetMaxY(view.frame)
         }
         
         func setTabBarHidden(hidden: Bool, animated: Bool) {
         
         guard isTabBarVisible == hidden else {
         return
         }
         
         let height = self.tabBar.frame.size.height
         let offsetY = (hidden ? height : -height)
         
         let duration = (animated ? 0.25 : 0.0)
         
         UIView.animateWithDuration(duration, animations: {
         let frame = self.tabBar.frame
         self.tabBar.frame = CGRectOffset(frame, 0, offsetY);
         }, completion: nil)
         */
    }
}

// MARK: - UITabBarControllerDelegate

extension YepTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        
        guard
            //            let tab = Tab(rawValue: selectedIndex),
            let nvc = viewController as? UINavigationController else {
                return false
        }
        
        if let _ =  nvc.topViewController as? ProfileViewController {
        }
        
        /*if case .Feeds = tab {
         if let vc = nvc.topViewController as? FeedsViewController {
         guard let feedsTableView = vc.feedsTableView else {
         return true
         }
         if feedsTableView.yep_isAtTop {
         if !hasFirstTapOnFeedsWhenItIsAtTop {
         hasFirstTapOnFeedsWhenItIsAtTop = true
         return false
         }
         }
         }
         }*/
        
        return true
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        
        guard
            let nvc = viewController as? YepNavigationController, let tab = Tab(rawValue: selectedIndex) else {
                return
        }
        
        if tab != .Contacts {
            NSNotificationCenter.defaultCenter().postNotificationName(YepConfig.Notification.switchedToOthersFromContactsTab, object: nil)
        }
        
        // 不相等才继续，确保第一次 tap 不做事
        
        if tab != previousTab {
            previousTab = tab
        }
        
        masterSelectedTap = selectedIndex
        
        switch tab {
            
        case .Conversations:
//            if let vc = nvc.topViewController as? ConversationsViewController {
//                if !vc.conversationsTableView.yep_isAtTop {
//                    vc.conversationsTableView.yep_scrollsToTop()
//                }
//                
//            }
            break
            
        case .Contacts:
            break
            
            /*case .Feeds:
             if let vc = nvc.topViewController as? FeedsViewController {
             if !vc.feedsTableView.yep_isAtTop {
             vc.feedsTableView.yep_scrollsToTop()
             
             } else {
             if !vc.feeds.isEmpty && !vc.pullToRefreshView.isRefreshing {
             vc.feedsTableView.setContentOffset(CGPoint(x: 0, y: -150), animated: true)
             hasFirstTapOnFeedsWhenItIsAtTop = false
             }
             }
             }*/
            
        case .Discover:

            performSegueWithIdentifier("showDetailView", sender: nil)
            
        case .Profile:

            if let
                myUserID = YepUserDefaults.userID.value,
                realm = try? Realm(),
                me = userWithUserID(myUserID, inRealm: realm) {
                
                performSegueWithIdentifier("showDetailView", sender: Box(me))
            }
        }
        //        }
        
        /*
         if selectedIndex == 1 {
         if let nvc = viewController as? UINavigationController, vc = nvc.topViewController as? ContactsViewController {
         syncFriendshipsAndDoFurtherAction {
         dispatch_async(dispatch_get_main_queue()) { [weak vc] in
         vc?.updateContactsTableView()
         }
         }
         }
         }
         */
    }
}

