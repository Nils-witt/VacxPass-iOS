//
//  ViewController.swift
//  VacxPass
//
//  Created by Nils Witt on 24.06.21.
//

import UIKit
import PassKit

class ViewController: UIViewController {

    var certificate: String = "";
    var pass: PKPass?;
    
    @IBOutlet weak var sendToServerButton: UIButton!
    @IBOutlet weak var addToWalletButton: PKAddPassButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    @IBAction func scannerButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "segueMainToScanner", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let dest = segue.destination as? ScannerViewController else { return }
        dest.parentController = self;
    }
    
    func setDataFromScanner(data: String){
        self.certificate = data;
        self.sendToServerButton.isHidden = false;
    }

    @IBAction func sendToServerClicked(_ sender: Any) {
        let apiUrl = "https://vacxpass.nils-witt.de/generate"
        let json: [String: Any] = ["passToken": self.certificate];
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)

        let url = URL(string: apiUrl)!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"

        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            print("DATA RECIEVED")
            if let httpResponse = response as? HTTPURLResponse {
                print("error \(httpResponse.statusCode)")
            }
            do{
                self.pass = try PKPass(data: data)
                DispatchQueue.main.async {
                    self.addToWalletButton.isHidden = false;
                }
            } catch {
                
            }
        }
        task.resume()
    }
    
    @IBAction func addToWalletClicked(_ sender: Any) {
        guard let pass = self.pass else {
            return
        }
        
        let vc = PKAddPassesViewController(pass: pass)! as PKAddPassesViewController
        DispatchQueue.main.async {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
}

