//
//  ViewController.swift
//  Project10
//
//  Created by iMac on 25.02.2021.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    var people = [Person]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
        
        let defaults = UserDefaults.standard
        
        if let savedPeople = defaults.object(forKey: "people") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                people = try jsonDecoder.decode([Person].self, from: savedPeople)
            } catch {
                print("Failed to load people!")
            }
        }    
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.editedImage] as? UIImage else { return }
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            let imageName = UUID().uuidString
            let imagePath = getDocumentDirectory().appendingPathComponent(imageName)
            try? jpegData.write(to: imagePath)
            
            let person = Person(name: "Unknown", image: imageName)
            people.append(person)
            collectionView.reloadData()
            save()
        }
        
        
        dismiss(animated: true)
        
    }
    
    func getDocumentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    @objc func addNewPerson() {
        
        let picker = UIImagePickerController()
        //Если хотим использовать камеру - только для реальных устройств:
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        }
        
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
        
    }
    
    
    func changeName(alertAction: UIAlertAction, indexPath: IndexPath) {
        
        let ac = UIAlertController(title: "Enter new name", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] (action) in
            
            guard let newName = ac?.textFields?[0].text else {return}
            
            let person = self?.people[indexPath.item]
            person?.name = newName
            self?.collectionView.reloadData()
            self?.save()
        }
        
        ac.addAction(submitAction)
        
        present(ac, animated: true)
    }
    
    func deletePerson(alertAction: UIAlertAction, indexPath: IndexPath) {
        
        people.remove(at: indexPath.item)
        collectionView.reloadData()
        save()
    }
    
    
    //MARK: UICollectionViewController
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "person", for: indexPath) as? PersonCell else {
            
            fatalError("Unable to dequeue PersonCell!")
        }
        
        let person = people[indexPath.item]
        
        cell.name.text = person.name
        
        let pathToImage = getDocumentDirectory().appendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: pathToImage.path)
        
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        return cell

    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let ac = UIAlertController(title: "Options", message: "Do you want to rename the person or delete them?", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Change name", style: .default, handler: { [weak self] (action) in
            self?.changeName(alertAction: action, indexPath: indexPath)
        }))
        
        ac.addAction(UIAlertAction(title: "Delete person", style: .cancel, handler: { [weak self] (action) in
            self?.deletePerson(alertAction: action, indexPath: indexPath)
        }))
        
        present(ac, animated: true)
    }
    
    //MARK: UserDefaults
    func save() {
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(people) {
            let defaults = UserDefaults.standard
            defaults.set(savedData,forKey: "people")
        } else {
            print("Failed to save people!")
        }
    }
    
    


}

