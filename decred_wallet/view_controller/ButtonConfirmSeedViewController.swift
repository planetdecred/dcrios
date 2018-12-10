//
//  ButtonConfirmSeedViewController.swift
//  Decred Wallet
//
//  Created by Philipp Maluta on 12/6/18.
//  Copyright © 2018 The Decred developers. All rights reserved.
//

import UIKit

class ButtonConfirmSeedViewController: UIViewController, SeedCheckupProtocol {
    var seedToVerify: String?
    var selectedSeedWords:[Int] = []
    var allWords: [String] = []
    
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet var vActiveCellView: SeedCheckActiveCellView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allWords = loadSeedWordsList()
    }
    
    @IBAction func onConfirm(_ sender: Any) {
        performSegue(withIdentifier: "createPasswordSegue", sender: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
 
    private func loadSeedWordsList() -> [String]{
        let seedWordsPath = Bundle.main.path(forResource: "wordlist", ofType: "txt")
        let seedWords = try? String(contentsOfFile: seedWordsPath ?? "")
        return seedWords?.split{$0 == "\n"}.map(String.init) ?? []
    }
}

extension ButtonConfirmSeedViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell =  tableView.cellForRow(at: indexPath)
        if cell?.isSelected ?? false{
            return 100
        }else{
            return 80
        }
    }
}

extension ButtonConfirmSeedViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 33
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "tripleSeedCell", for: indexPath) as? SeedConfirmTableViewCell
        cell?.setup(num: indexPath.row, seedWords: breakdownByThree(row: indexPath.row), selected:pickSelected(row: indexPath.row))
        return cell!
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    private func breakdownByThree(row:Int) -> [String]{
        let seed = seedToVerify?.split{$0 == " "}.map(String.init)
        
        var suggestionsWithFake: [String] = ["","",""]
        let trueSeedIndex = Int.random(in: 0...2)
        let trueSeed = seed?[row]
        suggestionsWithFake[trueSeedIndex] = trueSeed ?? "dummy"
        let fakeWordsSet = allWords.filter({
            return ($0.lowercased().hasPrefix((String(trueSeed!.first!)).lowercased()))
        })
        
        let fakes = [fakeWordsSet[Int.random(in: 0...(fakeWordsSet.count) - 1)], fakeWordsSet[Int.random(in: 0...(fakeWordsSet.count)-1)]]
        var fakeIndex = 0
        for i in 0...2 {
            if i != trueSeedIndex {
                suggestionsWithFake[i] = fakes[fakeIndex]
                fakeIndex += 1
            }
        }
        return  suggestionsWithFake
    }
    
    private func pickSelected(row: Int) -> Int{
        if selectedSeedWords.count > row {
            return selectedSeedWords[row]
        } else {
            return -1
        }
    }
}
