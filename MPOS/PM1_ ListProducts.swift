import SwiftUI
import PhotosUI

struct Items : Identifiable,Hashable, Codable ,Equatable {
    let id: UUID    
    var Pname: String
    var Pdetail : String
    var Pprice : Double
    var Pamount : Int
    var qty : Int
    var Ptp : String
    var imageFileName : String
    var itemidex : Int
    var Status : Bool
        
    init(Pname: String, Pdetail: String,Pprice: Double,Pamount:Int,qty:Int,Ptp:String,imageFileName : String,status : Bool ,itemindex : Int) {
        id = UUID()
        self.Pname = Pname
        self.Pdetail = Pdetail
        self.Pprice = Pprice
        self.Pamount = Pamount
        self.qty = qty
        self.Ptp = Ptp
        self.imageFileName = imageFileName
        self.Status = status
        self.itemidex = itemindex
        }
    }
    
    struct ListProducts: View {
        //test codable added
        @State var showingSheet = false
        @State var name : String = ""
        @State var detail : String = ""
        @State var amount : Int = 0
        @State private var text = ""
        @State var amountTxT: String = ""
        @State var price : Double = 0.00
        @State var priceTxT: String = ""
        @State var select = ""
        @State var entries = [Items]()
        @State var tp = [typeProducts]()
        @State var search: [Items] = []
        @State private var isPresented: Bool = false
        @State var pickerResult: [UIImage] = []
        @State private var filenameString = ""
        var config: PHPickerConfiguration  {
            var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
            config.filter = .images //videos, livePhotos...
            config.selectionLimit = 1 //0 => any, set 1-2-3 for har limit
            return config
        }
        var body: some View {
            NavigationView {
                List{
                    Section(header:Text ("สินค้า")) {
                        Button(action: {
                            isPresented.toggle()
                        }, label: {
                            HStack{
                                Text("เลือกรูปภาพ")
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
                        TextField ("ชื่อสินค้า", text: $name)
                        TextField ("รายละเอียด", text: $detail)
                        TextField("ราคา", text: $priceTxT)
                            .onChange(of: priceTxT) { _ in                         
                                price = Double(priceTxT) ?? 0.0
                            }
                        TextField("จำนวน", text: $amountTxT )
                        .onChange(of: amountTxT) { _ in                         
                        amount = Int(amountTxT) ?? 0
                        }
                        Picker("ประเภทสินค้า", selection: $select) {
                            Button(action: {
                                showingSheet.toggle()
                            }, label: {
                                Text("เพิ่มประเภท")
                            })
                            .buttonStyle(.borderedProminent)
                            .sheet(isPresented: $showingSheet) {
                                Categories()
                            }
                            ForEach(tp, id: \.self) { i in
                                Text(i.tpname).tag(i.tpname)
                            }
                        }
                        .onAppear {
                            if let encodedData = UserDefaults.standard.data(forKey: "tp") {
                                do {
                                    tp = try PropertyListDecoder().decode([typeProducts].self , from: encodedData)
                                } catch let error as NSError {
                                    NSLog("Unable to decode: error = \(error.localizedDescription)")
                                }
                            }
                        }
                        Button(action: {
                            if pickerResult.isEmpty {
                                filenameString = randomString(length: 10)
                                _ =  saveImage(image: pickerResult.first  ?? UIImage(),fileName: filenameString)
                                print(filenameString)
                            }else{
                                if let image = pickerResult.first {
                                    filenameString = randomString(length: 10)
                                    _ =  saveImage(image: image,fileName: filenameString)
                                    print(filenameString)
                                }
                            }
                            
                            entries.append(
                                Items(Pname: name, Pdetail: detail, Pprice: price, Pamount: amount,qty:0,Ptp: select,imageFileName: filenameString, status: false, itemindex: entries.count))
                            UserDefaults.standard.set(try? PropertyListEncoder().encode(entries), forKey: "Bills")
                        }) {
                            Text("เพิ่มสินค้า")
                        }.disabled(self.name.isEmpty)
                    }
                    ForEach(text == "" ?  Array(entries.enumerated()) : Array(search.enumerated()) , id: \.element) { index , i in
                        NavigationLink(destination: ProductDetail(name: "\(i.Pname)", detail: "\(i.Pdetail)", amount: i.Pamount, amountTxT: "\(i.Pamount)", price: i.Pprice, priceTxT: "\(i.Pprice)",imageFileName : i.imageFileName, entries: entries,index : index ,select: i.Ptp)) {
                            HStack{
                            Text("ชื่อสินค้า : \(i.Pname)")
                                Spacer()
                            Image.init(uiImage:  getSavedImage(named: i.imageFileName ) ?? UIImage() )
                                .resizable()
                                .frame(width: 100, height: 100, alignment: .center)
                                .aspectRatio(contentMode: .fit)
                            }
                        }
                    }.onDelete(perform: delete)
                        .onMove(perform: move) 
                }
                .onAppear {
                    if let encodedData = UserDefaults.standard.data(forKey: "Bills") {
                        do {
                            entries = try PropertyListDecoder().decode([Items].self , from: encodedData)
                        } catch let error as NSError {
                            NSLog("Unable to decode: error = \(error.localizedDescription)")
                        }
                    }
                }.onChange(of: text) { searchValue in
                    search = entries.filter { $0.Pname.contains(searchValue)}
                }
                .toolbar {
                    EditButton()
                }
                .searchable(text: $text)
                .navigationBarTitle("Products")
            }
        }
        func getSavedImage(named: String) -> UIImage? {
            if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
                return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
            }
            return nil
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
                filenameString = "\(fileName)"
                print(filenameString)
                return true
            } catch {   
                print(error.localizedDescription)
                return false
            }
        }
        
        func randomString(length: Int) -> String {
            let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            return String((0..<length).map{ _ in letters.randomElement()! })
        }
        
        func delete(at offsets: IndexSet) {
            entries.remove(atOffsets: offsets)
            UserDefaults.standard.set(try? PropertyListEncoder().encode(entries), forKey: "Bills")
        }
        
        func move(from source: IndexSet, to destination: Int) {
            entries.move(fromOffsets: source, toOffset: destination)
        }
    }

struct ProductDetail: View {
    @State var showingSheet = false
    @State var name : String = ""
    @State var detail : String = ""
    @State var amount : Int = 0
    @State var amountTxT: String = ""
    @State var price : Double = 0.00
    @State var priceTxT: String = ""
    @State var imageFileName = ""
    @State var entries = [Items]()
    @State var tp = [typeProducts]()
    @State var index = 0
    @State var select = ""
    @State private var isPresented: Bool = false
    @State var pickerResult: [UIImage] = []
    @State private var filenameString = ""
    var config: PHPickerConfiguration  {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.filter = .images //videos, livePhotos...
        config.selectionLimit = 1 //0 => any, set 1-2-3 for har limit
        return config
    }
    var body: some View {
        Form{
            Section(header:Text ("สินค้า")) {
                Button(action: {
                    isPresented.toggle()
                }, label: {
                    HStack{
                        Text("เปลี่ยนรูปภาพ")
                        Spacer()
                    Image.init(uiImage: pickerResult.isEmpty ? getSavedImage(named: imageFileName ) ?? UIImage()  : pickerResult.first  ?? UIImage()  )
                        .resizable()
                        .frame(width: 100, height: 100, alignment: .center)
                        .aspectRatio(contentMode: .fit)
                    }
                }).sheet(isPresented: $isPresented) {
                    PhotoPicker(configuration: self.config,
                                pickerResult: $pickerResult,
                                isPresented: $isPresented)
                }
                TextField ("ชื่อ สินค้า", text: $name)
                TextField ("รายละเอียด", text: $detail)
                TextField("ราคา", text: $priceTxT)
                    .onChange(of: priceTxT) { _ in                         
                        price = Double(priceTxT) ?? 0.0
                    }
                TextField("จำนวน", text: $amountTxT )
                    .onChange(of: amountTxT) { _ in                         
                        amount = Int(amountTxT) ?? 0
                    }
                Picker("ประเภทสินค้า", selection: $select) {
                    Button(action: {
                        showingSheet.toggle()
                    }, label: {
                        Text("เพิ่มประเภท")
                    }).sheet(isPresented: $showingSheet) {
                        Categories()
                    }
                    .buttonStyle(.borderless)
                    ForEach(tp, id: \.self) { i in
                        Text(i.tpname).tag(i.tpname)
                    }
                }.onAppear {
                    if let encodedData = UserDefaults.standard.data(forKey: "tp") {
                        do {
                            tp = try PropertyListDecoder().decode([typeProducts].self , from: encodedData)
                        } catch let error as NSError {
                            NSLog("Unable to decode: error = \(error.localizedDescription)")
                        }
                    }
                }
            }
            Button(action: {
                print(index)
                entries.remove(at: index)
                if let image = pickerResult.first {
                    _ =  saveImage(image: image,fileName: imageFileName)
                    print(imageFileName)
                }
                entries.insert(Items(Pname: name, Pdetail: detail, Pprice: price, Pamount: amount,qty: 0 , Ptp: select,imageFileName: imageFileName, status: false, itemindex: Int(index) ), at: index )
                UserDefaults.standard.set(try? PropertyListEncoder().encode(entries), forKey: "Bills")
            }, label: {
                Text("edit")
            })
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
            filenameString = "\(fileName)"
            //print(filenameString)
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
