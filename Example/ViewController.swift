
import UIKit

class ViewController: UIViewController, /*UITableViewDataSource,*/ UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet var countItem: UIBarButtonItem!

    let textCellIdentifier = "TableCell";
    let notificationFacade = MRLocalNotificationFacade.defaultInstance()
    
    var selectedIndex: NSIndexPath?
    
    @IBAction func reloadData() {
        tableView.reloadData()
    }
    
    @IBAction func registerAction(sender: AnyObject) {
        let min = [
            notificationFacade.buildAction("minimal-background", title: "background", destructive: true, backgroundMode: false, authentication: true),
            notificationFacade.buildAction("minimal-foreground", title: "foreground", destructive: false, backgroundMode: false, authentication: true)
        ]
        let def = [
            notificationFacade.buildAction("default-background-0", title: "background", destructive: true, backgroundMode: false, authentication: true),
            notificationFacade.buildAction("default-background-1", title: "foreground", destructive: false, backgroundMode: false, authentication: true),
            notificationFacade.buildAction("default-foreground-0", title: "background", destructive: true, backgroundMode: false, authentication: true),
            notificationFacade.buildAction("default-foreground-1", title: "foreground", destructive: false, backgroundMode: false, authentication: true) ]
        let categoryAll = notificationFacade.buildCategory("all", minimalActions: min, defaultActions: def)
        let categoryDefault = notificationFacade.buildCategory("default", minimalActions: nil, defaultActions: def)
        let categoryMinimal = notificationFacade.buildCategory("minimal", minimalActions: min, defaultActions: nil)
        let categories = NSMutableSet()
        categories.addObject(categoryAll)
        categories.addObject(categoryMinimal)
        categories.addObject(categoryDefault)
        notificationFacade.registerForNotificationWithBadges(true, alerts: true, sounds: true, categories: categories as Set<NSObject>);
        if (!notificationFacade.isRegisteredForNotifications()) {
            print("touch ↺ button after enabling notifications for reloading table view")
        }
    }
    
    @IBAction func removeNotificationAction(sender: AnyObject) {
        let index = selectedIndex?.indexAtPosition(1)
        if (index != nil) {
            let notifications = notificationFacade.scheduledNotifications()
            if (notifications.count > index) {
                let notification = notifications[index!] as! UILocalNotification
                notificationFacade.cancelNotification(notification)
                selectedIndex = nil
                self.reloadData()
            }
        }
    }
    
    // MARK:  UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let count = notificationFacade.scheduledNotifications().count
        countItem.title = "count: \(count)"
        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> TableCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier) as! TableCell
        let notifications = notificationFacade.scheduledNotifications()
        let notification = notifications[indexPath.row] as! UILocalNotification
        cell.setUp(notification)
        return cell
    }
    
    // MARK:  UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if (selectedIndex == indexPath) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            selectedIndex = nil
        } else {
            selectedIndex = indexPath
        }
    }
    
    // MARK:  UIViewController
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.reloadData()
    }
    
    // MARK:  NSObject

    override func awakeFromNib() {
        super.awakeFromNib();
        // Add observer
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadData), name: "reloadData", object: nil)
        // Set email for support
        notificationFacade.setContactSupportURLWithEmailAddress("support@example.com", subject: nil, body: nil)
        // Add some logs
        notificationFacade.onDidReceiveNotification = { (notification, pointer) -> Void in
            print("notification received")
        }
        notificationFacade.onDidCancelNotificationAlert = { (notification) -> Void in
            print("notification alert cancelled")
        }
        notificationFacade.onDidCancelErrorAlert = { (error) -> Void in
            print("error alert cancelled")
        }
        notificationFacade.setNotificationHandler({ (identifier, notification) -> Void in
            print(identifier)
            }, forActionWithIdentifier:"minimal-foreground");
        notificationFacade.setNotificationHandler({ (identifier, notification) -> Void in
            print(identifier)
            }, forActionWithIdentifier:"minimal-background");
        notificationFacade.setNotificationHandler({ (identifier, notification) -> Void in
            print(identifier)
            }, forActionWithIdentifier:"default-background0");
        notificationFacade.setNotificationHandler({ (identifier, notification) -> Void in
            print(identifier)
            }, forActionWithIdentifier:"default-foreground1");
        notificationFacade.setNotificationHandler({ (identifier, notification) -> Void in
            print(identifier)
            }, forActionWithIdentifier:"default-foreground1");
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}

