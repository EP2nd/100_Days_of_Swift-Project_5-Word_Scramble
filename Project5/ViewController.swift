//
//  ViewController.swift
//  Project5
//
//  Created by Edwin Przeźwiecki Jr. on 19/04/2022.
//

import UIKit

class ViewController: UITableViewController {

    var allWords = [String]()
    var usedWords = [String]()
    var lastWord: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh , target: self, action: #selector(startGame))
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
        let defaults = UserDefaults.standard
        
        if let savedWord = defaults.value(forKey: "savedWord") as? String, let savedWords = defaults.value(forKey: "savedWords") as? [String] {
            title = savedWord
            lastWord = savedWord
            usedWords = savedWords
        } else {
            startGame()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    @objc func startGame() {
        title  = allWords.randomElement()
        lastWord = title
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
        save()
    }
    
    @objc func promptForAnswer() {
        let alertController = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        alertController.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak alertController] action in
            guard let answer = alertController?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        alertController.addAction(submitAction)
        
        present(alertController, animated: true)
    }
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false }
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word) && word != title
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        if word.utf16.count >= 3 {
            return misspelledRange.location == NSNotFound
        } else {
            return false
        }
    }
    
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()
        
        /* let errorTitle: String
        let errorMessage: String */
        
        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    usedWords.insert(answer.lowercased(), at: 0)
                    save()
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)

                    return
                }
                showErrorMessage(errorTitle: "The word was too short or not recognised", errorMessage: "You can't just make them up, you know!")
                return
            }
            showErrorMessage(errorTitle: "The word was the same as the keyword or it has been used already", errorMessage: "Be more original!")
            return
        }
        guard let title = title?.lowercased() else { return }
        showErrorMessage(errorTitle: "The word was not possible", errorMessage: "You can't spell that word from \(title)!")
        return
        
        /* let alertController = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true) */
    }
    
    func showErrorMessage(errorTitle: String, errorMessage: String) {
        
        let alertController = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
    
    func save() {
        let defaults = UserDefaults.standard
        
        defaults.set(lastWord, forKey: "savedWord")
        defaults.set(usedWords, forKey: "savedWords")
    }
}
