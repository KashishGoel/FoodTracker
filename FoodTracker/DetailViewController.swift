//
//  DetailViewController.swift
//  FoodTracker
//
//  Created by Kashish Goel on 2015-07-23.
//  Copyright (c) 2015 Kashish Goel. All rights reserved.
//



import UIKit


class DetailViewController: UIViewController {
    
    var usdaItem:USDAItem?
    
    @IBOutlet weak var textView: UITextView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(DetailViewController.usdaItemDidComplete(_:)), name: NSNotification.Name(rawValue: kUSDAItemCompleted), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
        if usdaItem != nil {
            textView.attributedText = createAttributedString(usdaItem!)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func usdaItemDidComplete(_ notification: Notification) {
        
        print("usdaItemDidComplete in DetailViewController")
        usdaItem = notification.object as? USDAItem
        
        if self.isViewLoaded && self.view.window != nil {
            textView.attributedText = createAttributedString(usdaItem!)
        }
        
    }
    
    @IBAction func eatItBarButtonItemPressed(_ sender: UIBarButtonItem) {
        
    }
    //4 detail text view bod
    func createAttributedString (_ usdaItem: USDAItem!) -> NSAttributedString {
        
        let itemAttributedString = NSMutableAttributedString()
        
        let centeredParagraphStyle = NSMutableParagraphStyle()
        centeredParagraphStyle.alignment = NSTextAlignment.center
        centeredParagraphStyle.lineSpacing = 10.0
        
        let titleAttributesDictionary = [
            NSForegroundColorAttributeName : UIColor.black,
            NSFontAttributeName : UIFont.boldSystemFont(ofSize: 22.0),
            NSParagraphStyleAttributeName : centeredParagraphStyle]
        
        let titleString = NSAttributedString(string: "\(usdaItem.name)\n", attributes: titleAttributesDictionary)
        itemAttributedString.append(titleString)
        
        //helper
        let leftAlignedParagraphStyle = NSMutableParagraphStyle()
        leftAlignedParagraphStyle.alignment = NSTextAlignment.left
        leftAlignedParagraphStyle.lineSpacing = 20.0
        
        //4 type (e.g protein)
        let styleFirstWordAttributesDictionary = [NSForegroundColorAttributeName: UIColor.black, NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18.0),NSParagraphStyleAttributeName:leftAlignedParagraphStyle]
        //2 diff types, not much diff
        let style1AttributesDictionary = [NSForegroundColorAttributeName:UIColor.darkGray, NSFontAttributeName:UIFont.systemFont(ofSize: 18.0), NSParagraphStyleAttributeName: leftAlignedParagraphStyle]
        let style2AttributesDictionary = [NSForegroundColorAttributeName: UIColor.lightGray, NSFontAttributeName: UIFont.systemFont(ofSize: 18.0), NSParagraphStyleAttributeName:leftAlignedParagraphStyle]
        
        
        //adding calcium
        let calciumTitleString = NSAttributedString(string: "Calcium ", attributes: styleFirstWordAttributesDictionary)
        let calciumBodyString = NSAttributedString(string: "\(usdaItem.calcium)%\n", attributes: style1AttributesDictionary)
        itemAttributedString.append(calciumTitleString)
        itemAttributedString.append(calciumBodyString)
        
        //carbo
        let carbohydrateTitleString = NSAttributedString(string: "Carbohydrate ", attributes: styleFirstWordAttributesDictionary)
        let carbohydrateBodyString = NSAttributedString(string: "\(usdaItem.carbohydrate)% \n", attributes: style2AttributesDictionary)
        itemAttributedString.append(carbohydrateTitleString)
        itemAttributedString.append(carbohydrateBodyString)
       
        //chlostererol
        let cholesterolTitleString = NSAttributedString(string: "Cholesterol ", attributes: styleFirstWordAttributesDictionary)
        let cholesterolBodyString = NSAttributedString(string: "\(usdaItem.cholesterol)% \n", attributes: style1AttributesDictionary)
        itemAttributedString.append(cholesterolTitleString)
        itemAttributedString.append(cholesterolBodyString)
        
        // Energy
        let energyTitleString = NSAttributedString(string: "Energy ", attributes: styleFirstWordAttributesDictionary)
        let energyBodyString = NSAttributedString(string: "\(usdaItem.energy)% \n", attributes: style2AttributesDictionary)
        itemAttributedString.append(energyTitleString)
        itemAttributedString.append(energyBodyString)
        
        // Fat Total
        let fatTotalTitleString = NSAttributedString(string: "FatTotal ", attributes: styleFirstWordAttributesDictionary)
        let fatTotalBodyString = NSAttributedString(string: "\(usdaItem.fatTotal)% \n", attributes: style1AttributesDictionary)
        itemAttributedString.append(fatTotalTitleString)
        itemAttributedString.append(fatTotalBodyString)
        
        // Protein
        let proteinTitleString = NSAttributedString(string: "Protein ", attributes: styleFirstWordAttributesDictionary)
        let proteinBodyString = NSAttributedString(string: "\(usdaItem.protein)% \n", attributes: style2AttributesDictionary)
        itemAttributedString.append(proteinTitleString)
        itemAttributedString.append(proteinBodyString)
        
        // Sugar
        let sugarTitleString = NSAttributedString(string: "Sugar ", attributes: styleFirstWordAttributesDictionary)
        let sugarBodyString = NSAttributedString(string: "\(usdaItem.sugar)% \n", attributes: style1AttributesDictionary)
        itemAttributedString.append(sugarTitleString)
        itemAttributedString.append(sugarBodyString)
        
        // Vitamin C
        let vitaminCTitleString = NSAttributedString(string: "Vitamin C ", attributes: styleFirstWordAttributesDictionary)
        let vitaminCBodyString = NSAttributedString(string: "\(usdaItem.vitaminC)% \n", attributes: style2AttributesDictionary)
        itemAttributedString.append(vitaminCTitleString)
        itemAttributedString.append(vitaminCBodyString)
        
        return itemAttributedString
    }
    
    
    
}
