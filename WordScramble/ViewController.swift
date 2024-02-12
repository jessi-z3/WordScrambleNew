//
//  ViewController.swift
//  WordScamble
//
//  Created by Jessi Zimmerman on 2/12/24.
//

import UIKit

class ViewController: UITableViewController {
    var allWords = [String]()
    var usedWords = [String]()
    enum Errors{
        case impossible, unoriginal, fake
    }
    var error = Errors.fake
    var errorTitle = String()
    var errorMessage = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsURL){
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        if allWords.isEmpty{
            allWords = ["silkworm"]
        }
        startGame()
    }
    @objc func startGame(){
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
        print("game loaded")
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    @objc func promptForAnswer(){
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        let submitAction = UIAlertAction(title: "Submit", style: .default){ [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else {return}
            self?.submit(answer)
        }
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    func submit(_ answer: String){
        let errorTitle: String
        let errorMessage: String
        
        let lowerAnswer = answer.lowercased()
        if isPossible(word: lowerAnswer){
            if isOriginal(word: lowerAnswer){
                if isReal(word: lowerAnswer){
                    usedWords.insert(answer, at: 0)
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    return
                } else {
                    let error = Errors.fake
                    showErrorMessage(error: error)
                }
            } else {
                let error = Errors.unoriginal
                showErrorMessage(error: error)
            }
        } else {
            let error = Errors.impossible
            showErrorMessage(error: error)
        }
        
    }
    func isPossible(word: String) -> Bool{
        guard var tempWord = title?.lowercased() else {return false}
        for letter in word {
            if let position = tempWord.firstIndex(of: letter){
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        return true
    }
    func isOriginal(word: String) -> Bool{
        let word = word.localizedLowercase
        return !usedWords.contains(word)
    }
    func isReal(word: String) -> Bool{
        if word.distance(from: word.startIndex, to: word.endIndex) <= 2{
            return false
        }
        if word.lowercased() == title?.lowercased(){
            return false
        }
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let mispelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return mispelledRange.location == NSNotFound
    }
    func showErrorMessage(error: Errors){
        switch error{
        case .impossible: errorTitle = "Word not possible.";
            errorMessage = "You cannot make that word from \(title!.lowercased()).";
        case .unoriginal: errorTitle = "Word already used.";
            errorMessage = "You can't use a word that has already been submitted.";
        case .fake: errorTitle = "Word not recognized.";
            errorMessage = "You can't make up words.";
            
        }
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
}

