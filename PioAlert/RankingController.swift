//
//  RankingController.swift
//  PioAlert
//
//  Created by LiveLife on 31/07/2017.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import UIKit

class RankingController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView:UITableView!
    var players = [PioPlayer]()
    
    @IBOutlet weak var playerPos:UILabel!
    @IBOutlet weak var playerScore:UILabel!
    @IBOutlet weak var playerPromoViews:UILabel!
    @IBOutlet weak var playerPromoOpen:UILabel!
    @IBOutlet weak var playerLikes:UILabel!
    @IBOutlet weak var playerShare:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        players = WebApi.sharedInstance.ranking(limit: 20)
        print("\(players.count) players")
        tableView.reloadData()
        
        let pos = PioUser.sharedUser.rankData["pos"] as! String
        playerPos.text = "Posizione: #"+pos
        
        let score = PioUser.sharedUser.rankData["score"] as! String
        playerScore.text = "Punteggio: "+score
        
        let pView = PioUser.sharedUser.rankData["ads_browsed"] as! String
        playerPromoViews.text = "Promo viste: "+pView
        
        let pOpen = PioUser.sharedUser.rankData["ads_open"] as! String
        playerPromoOpen.text = "Promo aperte: "+pOpen
        
        let likes = PioUser.sharedUser.rankData["likes"] as! String
        playerLikes.text = "Likes: "+likes
        
        let shared = PioUser.sharedUser.rankData["shares"] as! String
        playerShare.text = "Condivisioni: "+shared
        
        
    }
    
    @IBAction func dismissRanking(sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let player = players[indexPath.row]
        
        var cell: ProductCellView!
        cell = tableView.dequeueReusableCell(withIdentifier: "productViewCell", for: indexPath) as! ProductCellView
        
        
        cell.name.text = player.name
        cell.desc.text = "#"+String(player.rank)
        cell.price.text = String(player.score)+" pts"
        Utility.sharedInstance.addShadowToView(view: cell.container, cornerRadius: 3.0)
        
        WebApi.sharedInstance.downloadedFrom(cell.pimage, link: player.imagePath, mode: .scaleAspectFit, shadow: false)
        
        if player.uid == PioUser.sharedUser.uid {
            cell.container.backgroundColor = UIColor(red: 0.988, green: 0.933, blue: 0.753, alpha: 1)
        } else {
            cell.container.backgroundColor = UIColor.white
        }
        
        return cell
        
    }
    
    
}
