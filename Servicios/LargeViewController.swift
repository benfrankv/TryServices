//
//  LargeViewController.swift
//  Servicios
//
//  Created by Ben Frank V on 15/06/18.
//  Copyright © 2018 Ben Frank V. All rights reserved.
//

import UIKit
enum RequestType {
    case get
    case post
}

class LargeViewController: UIViewController {
    
    @IBOutlet weak var txtfldo_URL: UITextField!
    @IBOutlet weak var txtview_Request: UITextView!
    @IBOutlet weak var txto_Response: UITextView!
    @IBOutlet weak var requestHeightConstraint: NSLayoutConstraint!
    
    
    var requestType: RequestType = .get
    var url = URL(string: "")
    var getText = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        requestHeightConstraint.constant = 0
        let tapGesture = UITapGestureRecognizer(target: self, action:     #selector(tapGestureHandler))
        view.addGestureRecognizer(tapGesture)
        //txtfldo_Response.text = getText
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        
    }
    
    @objc func tapGestureHandler() {
        view.endEditing(true)
    }
    
    @IBAction func btna_Paste(_ sender: Any) {
       if let urlstr = UIPasteboard.general.string {
            txtfldo_URL.insertText(urlstr)
        }
    }
    
    @IBAction func valueChangedRequestType(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            requestType = .get
            requestHeightConstraint.constant = 0
            
        case 1:
            requestType = .post
            requestHeightConstraint.constant = 250
        default: break
        }
    }
    
    @IBAction func sendRequest(_ sender: UIButton) {
        switch requestType {
        case .get: pruebaGET()
        case .post: pruebaPOST()
        }
    }
    
    fileprivate func pruebaPOST() {
        if txtfldo_URL.text != "" {
            var parameters = parseParameters()
            // TODO: Meterle logica para identificar si es un array o un dictionary
            url = URL(string: txtfldo_URL.text!)
            //guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else { return }
	//
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {return}
            request.httpBody = httpBody
            
            let session = URLSession.shared
            session.dataTask(with: request) { (data, response, error) in
                if let response = response {
                    print(response)
                }
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        let dataAsString = String(data: data, encoding: .utf8)
                        DispatchQueue.main.async {
                            self.txto_Response.text = "Obteniendo"
                            self.txto_Response.text = "\(dataAsString!)"
                            
                        }
                    } catch {print(error)}
                }
                }.resume()
        }
    }
    
    func parseParameters() -> Any? {
        if txtfldo_URL.text!.isEmpty {
            txto_Response.text = "Favor de introducir la URL"
            return nil
        }
        guard let jsonString = txtview_Request.text else { return nil }
        
        var string = jsonString.replacingOccurrences(of: "\\/", with: "/")
        print("\n\n\n")
        dump(string)
        string = string.trimmingCharacters(in: .newlines)
        print("\n\n\n")
        dump(string)
        while let rangeToReplace = string.range(of: "\n") {
            string.replaceSubrange(rangeToReplace, with: "")
        }
        dump(string)
        print("\n\n\n")
        guard let data = string.data(using: .utf8) else { return nil }
        do {
            if let jsonArray = try JSONSerialization.jsonObject(
                with: data,
                options : .allowFragments
                ) as? [Dictionary<String,Any>]
            {
                return jsonArray
            } else if let jsonDict = try JSONSerialization.jsonObject(
                with: data,
                options : .allowFragments
                ) as? Dictionary<String,Any>
            {
                return jsonDict
            } else {
                return nil
            }
        } catch {
            dump(error)
            return nil
        }
    }
    
    func pruebaGET() {
        if txtfldo_URL.text != "" {
            url = URL(string: txtfldo_URL.text!)
            let session = URLSession.shared
            session.dataTask(with: url!) {(data, response, error) in
                if let response = response {
                    print(response)
                }
                if let data = data {
                    DispatchQueue.main.async {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String,String>
                            print(json)
                            //self.txto_Response.text = json
                        } catch {print(error)}
                    }
                    
                }
            }.resume()
            /*URLSession.shared.ses.dataTask(with: url!){ (data, response,err) in
                guard let data = data else {return}
                let dataAsString = String(data: data, encoding: .utf8)
                DispatchQueue.main.async {
                    
                    self.txtfldo_Response.text = "Obteniendo"
                    self.getText = dataAsString!
                    
                }*/
            }
        }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
