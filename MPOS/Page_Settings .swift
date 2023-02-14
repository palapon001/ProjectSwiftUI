import SwiftUI
import PhotosUI

struct Settings: View {
    var body: some View {
        NavigationView{
            Form{
                NavigationLink(destination: Store_Setting()) {
                    HStack{
                        Image(systemName: "gear")
                        Text("ตั้งค่า")
                    }
                }
                NavigationLink(destination: About()) {
                    HStack{
                        Image(systemName: "shippingbox.circle.fill")
                        Text("เกี่ยวกับแอพ")
                    }
                }
            }//Form
        }//NavigationView
    }
}

struct Store_Setting: View {
    @AppStorage("storeName") var storeName = ""
    @AppStorage("storeDetail") var storeDetail = ""
    @AppStorage("storeTel") var storeTel = ""
    @AppStorage("storeTax_txt")var storeTax_txt = ""
    @AppStorage("storeTax") var storeTax = 0.00
    @State var showData = true
    @State var showDataEdit = false
    @State private var isPresented: Bool = false
    @State var pickerResult: [UIImage] = []
    @State var imagepath : UIImage = UIImage()
    @State private var imageURLString = ""
    var config: PHPickerConfiguration  {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.filter = .images //videos, livePhotos...
        config.selectionLimit = 1 //0 => any, set 1-2-3 for har limit
        return config
    }
    var body: some View {
        List{
            Button(action: {
                showData.toggle()
                showDataEdit.toggle()
                if let image = pickerResult.first {
                    imageURLString = "fileName"
                    _ =  saveImage(image: image,fileName: imageURLString)
                    print(imageURLString)
                }
            }, label: {
                if showData {
                    Text("แก้ไข")
                }else{
                    Text("เสร็จสิ้น")
                }
            }).tint(showData ? .red : .orange)
            
            if showDataEdit {
                Section(header:Text ("แก้ไขสินค้า") ){
                    Button(action: {
                        isPresented.toggle()
                    }, label: {
                        HStack{
                            Text("เปลี่ยนรูปภาพ")
                            Spacer()
                            Image.init(uiImage: pickerResult.isEmpty ? getSavedImage(named: "fileName") ?? UIImage()  : pickerResult.first  ?? UIImage()  )
                                .resizable()
                                .frame(width: 100, height: 100, alignment: .center)
                                .aspectRatio(contentMode: .fit)
                        }
                    }).sheet(isPresented: $isPresented) {
                        PhotoPicker(configuration: self.config,
                                    pickerResult: $pickerResult,
                                    isPresented: $isPresented)
                    }
                    HStack{
                        Text("ชื่อร้านค้า : ")
                        TextField (" ", text: $storeName)
                    }
                    HStack{
                        Text("รายละเอียด : ")
                        TextField ("", text: $storeDetail)
                    }
                    HStack{
                        Text("เบอร์ : ")
                        TextField ("", text: $storeTel)
                    }
                    HStack{
                        Text("Tax : ")
                        TextField("Tax \(Int(storeTax))%", text: $storeTax_txt)
                            .onChange(of: storeTax_txt) { _ in                         
                                storeTax = Double(storeTax_txt) ?? 0.00
                            }
                    }
                }
            }
            if showData {
                Section(header:Text ("สินค้า")) {
                        Image.init(uiImage:  getSavedImage(named: "fileName") ?? UIImage() )
                            .resizable()
                            .frame(width: 100, height: 100, alignment: .center)
                            .aspectRatio(contentMode: .fit)
                    Text("ชื่อร้านค้า : \(storeName)")
                    Text("รายละเอียดร้านค้า : \(storeDetail)")
                    Text("เบอร์ : \(storeTel)")
                    Text("Tax : \(storeTax_txt)%")
                } 
            }
        }.onLoad{
            if let image = getSavedImage(named: "fileName") {
                //pickerResult.removeAll()
                //pickerResult.append(image)
                imagepath = image
                print(imagepath)
            }
        }
    }
        func saveImage(image: UIImage,fileName : String) -> Bool {
            guard let data = image.jpegData(compressionQuality: 0.1)  else {
                return false
            }
            guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
                return false
            }
            do {
                try data.write(to: directory.appendingPathComponent("\(fileName).png")!)
                imageURLString = "\(fileName)"
                print(imageURLString)
                return true
            } catch {   
                print(error.localizedDescription)
                return false
            }
        }
        
        func getSavedImage(named: String) -> UIImage? {
            if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
                return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
            }
            return nil
        }
        
}

struct About: View {
    var body: some View {
        Text("About").fontWeight(.bold).font(.largeTitle)
        Image("Logo")   
            .resizable()
            .frame(width: 100, height: 100)
        Text("v.1.0 \n Create  By \n Mon Palapon").fontWeight(.thin).font(.largeTitle)
    }
}


