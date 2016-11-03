
    
import UIKit
    
class CheckinVC: UIViewController {
        
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var congratsLabel: UILabel!
    var planName: String?
    var delegate: showCheckInButtonDelegate?

    func tabScreenOnClick(sender:UITapGestureRecognizer) {
        self.dismissViewControllerAnimated(true, completion: nil)
        UIApplication.sharedApplication().statusBarHidden = false
        self.delegate?.showCheckInButton?()
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarHidden = true
        congratsLabel.textColor = ColorScheme.p1Tint
        contentView.backgroundColor = ColorScheme.trackingDoneModalBg
        let blurEffect = UIBlurEffect(style: .Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.frame
            
        self.view.insertSubview(blurEffectView, atIndex: 0)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(CheckinVC.tabScreenOnClick(_:)))
        self.contentView.addGestureRecognizer(gesture)
        // Do any additional setup after loading the view.
    }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        
        override func prefersStatusBarHidden() -> Bool {
            return true
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
