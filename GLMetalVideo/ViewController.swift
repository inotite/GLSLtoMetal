//
//  ViewController.swift
//  GLMetalVideo
//
//  Created by com on 7/5/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

let filters = [
    "Bounce",
    "BowTieHorizontal",
    "BowTieVertical",
    "ButterflyWaveScrawler",
    "CircleCrop",
    "ColourDistance",
    "CrazyParametricFun",
    "CrossZoom",
    "Directional",
    "DoomScreenTransition",
    "Dreamy",
    "DreamyZoom",
    "FilmBurn",
    "GlitchDisplace",
    "GlitchMemories",
    "GridFlip",
    "InvertedPageCurl",
    "LinearBlur",
    "Mosaic",
    "PolkaDotsCurtain",
    "Radial",
    "SimpleZoom",
    "StereoViewer",
    "Swirl",
    "TVStatic",
    "WaterDrop",
    "ZoomInCircles",
    "angular",
    "burn",
    "cannabisleaf",
    "circle",
    "circleopen",
    "colorphase",
    "crosshatch",
    "crosswarp",
    "cube",
    "directionalwarp",
    "directionalwipe",
    "displacement",
    "doorway",
    "fade",
    "fadecolor",
    "fadegrayscale",
    "flyeye",
    "heart",
    "hexagonalize",
    "kaleidoscope",
    "luma",
    "luminance_melt",
    "morph",
    "multiply_blend",
    "perlin",
    "pinwheel",
    "pixelize",
    "polar_function",
    "randomsquares",
    "ripple",
    "rotate_scale_fade",
    "squareswire",
    "squeeze",
    "swap",
    "undulatingBurnOut",
    "wind",
    "windowblinds",
    "windowslice",
    "wipeDown",
    "wipeLeft",
    "wipeRight",
    "wipeUp"
]

class ViewController: UIViewController {
    
    @IBOutlet weak var filterChoice: UISegmentedControl!
    @IBOutlet weak var mergeVideos: UIButton!
    @IBOutlet weak var filterPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        filterPicker.delegate = self
        filterPicker.dataSource = self
    }
    
    @IBAction func mergeVideos(_ sender: Any) {
        guard let url1 = Bundle.main.url(forResource: "movie1", withExtension: "mov") else {
            print("Impossible to find the video.")
            return
        }
        
        guard let url2 = Bundle.main.url(forResource: "movie2", withExtension: "mov") else {
            print("Impossible to find the video.")
            return
        }
        
        // Export to file
        let dirPaths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        let docsURL = dirPaths[0]
        
        let path = docsURL.path.appending("/mergedVideo.mp4")
        let exportURL = URL.init(fileURLWithPath: path)
        
        var videoMerger = VideoMerger(url1: url1, url2: url2, export: exportURL, vc: self)
        
//        switch filterChoice.selectedSegmentIndex {
//        case 0:
//            videoMerger.transtion_function = "transition_circle"
//            break
//        case 1:
//            videoMerger.transtion_function = "transition_displacement"
//            break
//        case 2:
//            videoMerger.transtion_function = "transition_linearblur"
//            break
//        case 3:
//            videoMerger.transtion_function = "transition_glitchmemories"
//            break
//        default:
//            videoMerger.transtion_function = "transition_colorphase"
//            break
//        }
        mergeVideos.isEnabled = false
        
        let idx: Int = filterPicker.selectedRow(inComponent: 0)
        
        videoMerger.transtion_function = "transition_" + filters[idx].lowercased()
        
//        let alert = UIAlertController(title: "Did you bring your towel?", message: videoMerger.transtion_function, preferredStyle: .alert)
//        
//        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
//        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
//        
//        self.present(alert, animated: true)
        
        videoMerger.startRendering()
        
    }
    
    func openPreviewScreen(_ videoURL:URL) -> Void {
        DispatchQueue.main.async {
            self.mergeVideos.isEnabled = true
        }
        
        let player = AVPlayer(url: videoURL)
        let playerController = AVPlayerViewController()
        playerController.player = player
        
        present(playerController, animated: true, completion: {
            player.play()
        })
    }
}

extension ViewController: UIPickerViewDelegate {
    
}

extension ViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return filters.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return filters[row]
    }
}
