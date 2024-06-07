# Face Detection System

Bu proje, iOS cihazları için Swift dilinde gerçekleştirilmiş bir yüz algılama sistemidir. Gerçek zamanlı yüz takibi için Vision çerçevesini kullanır.

## Ekran Görüntüleri
![SS](https://github.com/doguner1/GitImageData/blob/main/AppleVisionFaceDetecting/IMG_0237.PNG?raw=true)
![SS](https://github.com/doguner1/GitImageData/blob/main/AppleVisionFaceDetecting/IMG_0238.jpg?raw=true)


## Genel Bakış

Sistem, David Razmadze tarafından 27 Ağustos 2022 tarihinde oluşturulan [Medium](https://medium.com/onfido-tech/live-face-tracking-on-ios-using-vision-framework-adf8a1799233) ve [YouTube](https://www.youtube.com/watch?v=3pFOmjO6fsQ) üzerindeki öğreticiyi takip ederek geliştirilmiştir.

### Mimari

Mimari, tipik bir iOS uygulama yapısını izler ve aşağıdaki çerçeveleri kullanır:

- **UIKit**: iOS uygulamalarında kullanıcı arayüzleri oluşturmak için temel sınıflar ve işlevler sağlar.
- **AVFoundation**: Kameralar, mikrofonlar ve video yakalama gibi multimedya öğeleriyle çalışmak için araçlar sunar.
- **Vision**: Nesne algılama, görüntü tanıma ve yüz analizi gibi bilgisayar vizyonu görevleriyle ilgili işlevler sunar.

### Amaç

Bu projenin temel amacı, Vision çerçevesini kullanarak iOS cihazlarında gerçek zamanlı yüz takibini göstermektir. Canlı kamera yayınında yüzleri algılamak ve algılanan yüzlerin etrafında yeşil sınırlayıcı kutular çizmek mümkündür.

## Nasıl Kullanılır

Bu yüz algılama sistemi kullanmak için:

1. Bir iOS cihazına gerçek bir kamera olduğundan emin olun. Bu sistem simülatörlerde çalışmaz.
2. Proje deposunu klonlayın veya indirin.
3. Projeyi Xcode'da açın.
4. Projeyi iOS cihazınızda derleyip çalıştırın.
5. Kamera yayını, cihazınızın ekranında algılanan yüzlerin etrafında yeşil sınırlayıcı kutularla görüntülenir.

## Lisans

Bu proje [MIT Lisansı](LICENSE) altında lisanslanmıştır.
