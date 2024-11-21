//
//  ViewController.swift
//  cw_1
//
//  Created by Кирилл Титов on 21.11.2024.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var collectionView: UICollectionView!
    var segmentedControl: UISegmentedControl!
    var addImageButton: UIButton!
    var progressView: UIProgressView!
    var statusLabel: UILabel!
    var startButton: UIButton!
    var cancelButton: UIButton!
    var computationManager: ComputationManager!

    
    var images: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadStaticImages()
    }
    
    // MARK: - Setup UI
    func setupUI() {
        view.backgroundColor = .white
        
        // UISegmentedControl
        segmentedControl = UISegmentedControl(items: ["Параллельно", "Последовательно"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl)
        
        // UICollectionView
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)
        
        // Add Image Button
        addImageButton = UIButton(type: .system)
        addImageButton.setTitle("Добавить изображение", for: .normal)
        addImageButton.addTarget(self, action: #selector(addImage), for: .touchUpInside)
        addImageButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addImageButton)
        
        // Progress View
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progress = 0.0
        view.addSubview(progressView)
        
        // Status Label
        statusLabel = UILabel()
        statusLabel.text = "Вычисления не начаты"
        statusLabel.textAlignment = .center
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.numberOfLines = 0
        statusLabel.lineBreakMode = .byWordWrapping
        view.addSubview(statusLabel)

        // Start Button
        startButton = UIButton(type: .system)
        startButton.setTitle("Начать вычисления", for: .normal)
        startButton.addTarget(self, action: #selector(startComputation), for: .touchUpInside)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(startButton)
        
        // Cancel Button
        cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Отмена", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelComputation), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cancelButton)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            // Segmented Control
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Add Image Button (Центрируем по горизонтали)
            addImageButton.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 50),  // Добавляем отступ сверху
            addImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),  // Центрируем по горизонтали
            
            // Collection View
            collectionView.topAnchor.constraint(equalTo: addImageButton.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: progressView.topAnchor, constant: -10),
            
            // Progress View
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            progressView.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -10),
            
            // Status Label
            statusLabel.bottomAnchor.constraint(equalTo: progressView.topAnchor, constant: -10),
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Start Button
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            // Cancel Button
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
    }


    
    // MARK: - UICollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        
        let originalImage = images[indexPath.row]
        cell.configureCell(with: originalImage)
        cell.startLoading() // Индикатор запускается перед обработкой
        
        if segmentedControl.selectedSegmentIndex == 0 {
            // Параллельный режим
            DispatchQueue.global(qos: .userInitiated).async {
                if let filteredImage = ImageProcessor.applyRandomFilter(to: originalImage) {
                    DispatchQueue.main.async {
                        cell.configureCell(with: filteredImage)
                        cell.stopLoading() // Индикатор останавливается после обработки
                    }
                } else {
                    DispatchQueue.main.async {
                        cell.stopLoading()
                        self.showError(message: "Не удалось применить фильтр.")
                    }
                }
            }
        } else {
            // Последовательный режим
            let queue = OperationQueue()
            queue.maxConcurrentOperationCount = 1
            queue.addOperation {
                if let filteredImage = ImageProcessor.applyRandomFilter(to: originalImage) {
                    OperationQueue.main.addOperation {
                        cell.configureCell(with: filteredImage)
                        cell.stopLoading() // Индикатор останавливается после обработки
                    }
                } else {
                    OperationQueue.main.addOperation {
                        cell.stopLoading()
                        self.showError(message: "Не удалось применить фильтр.")
                    }
                }
            }
        }
        
        return cell
    }


    
    func loadStaticImages() {
        for i in 1...10 { // Замените на количество ваших изображений
            if let image = UIImage(named: "image\(i)") { // Убедитесь, что названия совпадают, например: image1, image2...
                images.append(image)
            }
        }
        collectionView.reloadData() // Обновляем коллекцию после добавления
    }
    
    func showError(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    
    // MARK: - Button Actions
    @objc func addImage() {
        showImagePicker()
    }
    
    @objc func startComputation() {
        if computationManager == nil {
            computationManager = ComputationManager(viewController: self)
        }
        computationManager.startComputation()
    }
    
    @objc func cancelComputation() {
        computationManager?.cancelComputation()
    }


    
    @objc func segmentChanged() {
        collectionView.reloadData()
    }
    
    func updateStatus(message: String) {
            DispatchQueue.main.async {
                self.statusLabel.text = message
            }
        }
        
    func updateProgress(progress: Float) {
            DispatchQueue.main.async {
                self.progressView.progress = progress
            }
        }
    
    
    // MARK: - Image Picker
    func showImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            images.append(selectedImage)
            collectionView.reloadData()
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
