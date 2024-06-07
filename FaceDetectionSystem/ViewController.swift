//
//  ViewController.swift
//  FaceDetectionSystem
//
//  Created by David Razmadze on 8/27/22. -> https://www.youtube.com/watch?v=3pFOmjO6fsQ
//
//  Following this tutorial: https://medium.com/onfido-tech/live-face-tracking-on-ios-using-vision-framework-adf8a1799233

import UIKit
import AVFoundation
import Vision

/*
 UIKit, iOS uygulamalarda kullanıcı arayüzleri oluşturmak için temel sınıflar ve işlevler sağlayan UIKit çerçevesini içe aktarır. Görüntüler, düğmeler ve etiketler gibi UI öğeleriyle çalışmak için gereklidir.
 
 AVFoundation, kameralar, mikrofonlar ve video yakalama gibi multimedya öğeleriyle çalışmak için araçlar sunan AVFoundation çerçevesini içe aktarır. Bu belirli uygulama için cihazın kamerasına erişmek için bu çerçeveye ihtiyacınız olacaktır.
 
 Vision, nesne algılama, görüntü tanıma ve yüz analizi gibi bilgisayar vizyonu görevleriyle ilgili işlevler sunan Vision çerçevesini içe aktarır. Gösterilen kodda doğrudan kullanılmasa da, daha sonra potansiyel olarak entegre edilebilir.
 */

class ViewController: UIViewController {

  // MARK: - Variables
  
  private var drawings: [CAShapeLayer] = []
    //-> Ekranda şekiller çizmek için kullanılır
  
  private let videoDataOutput = AVCaptureVideoDataOutput()
    //-> cihazın kamerası tarafından yakalanan ham video karelerini almaktan sorumludur.
    
  private let captureSession = AVCaptureSession()
    //-> Bu nesne, video verisini kameradan videoDataOutput'a akışını yönetir
  
  private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    // -> Önizleme katmanını kullanabilmemiz için `captureSession`ın yüklenmesi gerektiğinden `lazy` anahtar sözcüğünü kullanıyoruz
  
    
    
  // Yaşam Döngüsü
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    addCameraInput()
    showCameraFeed()
    
    getCameraFrames()
    captureSession.startRunning()
  }
  
  /// The account for when the container's `view` changes.
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    previewLayer.frame = view.frame
      /*
       cihazın yönü veya görünüm denetleyicisinin görünümü değiştiğinde
       önizleme katmanının her zaman doğru şekilde görüntülenmesini sağlar.
       */
  }
  
    
    
    
  // Yardımcı İşlevler
  
  private func addCameraInput() {//Bu, kamera akışının uygulama tarafından alınmasını ve işlenmesini sağlar.
    
      guard let device = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera, .builtInDualCamera, .builtInWideAngleCamera], mediaType: .video, position: .back).devices.first else {
      fatalError("No camera detected. Please use a real camera, not a simulator.")//Cihazda kamera bulamadığında döneceği hata
    }
      /*
       Bazı Kamera seçenekleri:
       
       AVCaptureDevice.DeviceType.builtInWideAngleCamera: Geniş açılı bir kamera.
       AVCaptureDevice.DeviceType.builtInTelephotoCamera: Telefoto (yakınlaştırma) özellikli kamera.
       AVCaptureDevice.DeviceType.builtInUltraWideCamera: Ultra geniş açılı kamera.
       AVCaptureDevice.DeviceType.builtInDualCamera: İki kameranın birleşimi (geniş açılı ve telefoto gibi).
       AVCaptureDevice.DeviceType.builtInTripleCamera: Üç kameranın birleşimi (geniş açılı, ultra geniş açılı ve telefoto gibi).
       AVCaptureDevice.DeviceType.builtInTrueDepthCamera: TrueDepth (yüz tanıma, derinlik algılama) özelliğine sahip kamera.
       
       --> position: .front ile ön kamera açılır, position: .back ise arka kamera
       */
    
    let cameraInput = try! AVCaptureDeviceInput(device: device)
    captureSession.addInput(cameraInput)
  }
    
    
  
  private func showCameraFeed() { //kamera akışını cihazın ekranında görüntüleme işlemini gerçekleştirir.
    previewLayer.videoGravity = .resizeAspectFill //--> görünümüne sığdırılmasını ve kenarların doldurulmasını sağlar.
    view.layer.addSublayer(previewLayer)
    previewLayer.frame = view.frame //--> görünümünün çerçevesine (view.frame) eşitler.
  }
    
    
  
  private func getCameraFrames() { //Bu, kamera akışından gelen her kareyi işlevsel hale getirir.
    videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString): NSNumber(value: kCVPixelFormatType_32BGRA)] as [String: Any]
      /*
       yakalanan video karelerinin pixel formatını ayarlar. Burada, kCVPixelFormatType_32BGRA değeri, her bir piksel için 32 bitlik BGRA (Blue, Green, Red, Alpha) formatı kullanılmasını belirtir.
       */
    
    videoDataOutput.alwaysDiscardsLateVideoFrames = true
      /*
       Bu satır, geç alınan video karelerinin (yakalama oturumuna zamanında ulaşmayanlar)
       yakalama oturumundan atılmasını sağlar. Bu, işleme sırasında karelerin eskimiş olmasını önler.
       */
    
    videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_frame_processing_queue"))
    
    captureSession.addOutput(videoDataOutput)
    
    guard let connection = videoDataOutput.connection(with: .video), connection.isVideoOrientationSupported else {
      return
    }
    
    connection.videoOrientation = .portrait
      /*
       Bu satır, video yönünü portre moduna ayarlar.
       Bu, yakalanan karelerin cihazın portre konumuna göre
       yönlendirilmesini sağlar.
       */
  }//Buradaki fonksiyonun özeti, gelen her kare işlenmek üzere kullanılabilir hale getirmek
    
    
    
    
  
  private func detectFace(image: CVPixelBuffer) { //Bu metod bir CVPixelBuffer nesnesini alır ve içindeki yüzleri algılamaya çalışır
      //Algılanan yüzler varsa, bunlar işleme ve çizim için işlevlere iletilir. Yüz algılanmazsa, çizimler temizlenir.
      
    let faceDetectionRequest = VNDetectFaceLandmarksRequest { vnRequest, error in
      DispatchQueue.main.async {
          /*
           Bu blok, tamamlama bloğunun içeriğini ana iş parçacığında yürütülmesini sağlar.
           Yüz çizimlerini güncellemek gibi kullanıcı arayüzü işlemleri için
           ana iş parçacığını kullanmanız gerekir
           */
          
        if let results = vnRequest.results as? [VNFaceObservation], results.count > 0 {
          self.handleFaceDetectionResults(observedFaces: results)
        } else { //--> Yüz algılmaz ise çizimler temizlenir
          self.clearDrawings()
        }
      }
    }
    
    let imageResultHandler = VNImageRequestHandler(cvPixelBuffer: image, orientation: .leftMirrored, options: [:])
    try? imageResultHandler.perform([faceDetectionRequest])
      /*
       cvPixelBuffer: İşlenecek video karesi.
       orientation: .leftMirrored: Görüntünün yönünü belirtir (burada ayna görüntüsü gibi sola yansıtılmış).
       options: İsteğe bağlı olarak Vision isteğine geçirilebilecek ek seçenekler (bu örnekte boş bir sözlük kullanılıyor).
       */
  }
    
    
    
    
  
  private func handleFaceDetectionResults(observedFaces: [VNFaceObservation]) { //Algılanan yüzlerin verilerini (observedFaces parametresi) işleyerek ekran üzerine yeşil çerçeveler çizer.
    clearDrawings()
    
    // Create the boxes
    let facesBoundingBoxes: [CAShapeLayer] = observedFaces.map({ (observedFace: VNFaceObservation) -> CAShapeLayer in
      
      let faceBoundingBoxOnScreen = previewLayer.layerRectConverted(fromMetadataOutputRect: observedFace.boundingBox)
      let faceBoundingBoxPath = CGPath(rect: faceBoundingBoxOnScreen, transform: nil)
      let faceBoundingBoxShape = CAShapeLayer()
      
      // Kutu şeklinin (çizgilerin) özelliklerini ayarlama
      faceBoundingBoxShape.path = faceBoundingBoxPath
      faceBoundingBoxShape.fillColor = UIColor.clear.cgColor
      faceBoundingBoxShape.strokeColor = UIColor.green.cgColor
      
      return faceBoundingBoxShape
    })
    
    // Çizgiyi ekrana yansıtma
    facesBoundingBoxes.forEach { faceBoundingBox in
      view.layer.addSublayer(faceBoundingBox) //-->Bu, yüz çerçevesinin ekran üzerinde görüntülenmesini sağlar.
      drawings = facesBoundingBoxes
    }
  }
  
  private func clearDrawings() {
    drawings.forEach({ drawing in drawing.removeFromSuperlayer() })
  }
  
}





//AVCaptureVideoDataOutputSampleBufferDelegate

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
  
  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    
    guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
      debugPrint("Unable to get image from the sample buffer")
      return
    }
    
    detectFace(image: frame)
  }
  
}
