import SwiftUI
struct Adata : Identifiable, Codable,Hashable {
    let id: UUID    
    var Adate : Date
    var Atotal : Double
    var AorderID : String
    var Acount : Int 
    var Avat : Double
    var Adis : Double
    var Asumtotal : Double
    var Arecieve : Double
    var Achange : Double
    
    init(adate : Date , atotal : Double ,aorderId : String ,acount :Int ,avat : Double , adis : Double , asumtotal : Double , arecieve : Double ,achange : Double ) {
        id = UUID()
        self.Adate = adate
        self.Atotal = atotal
        self.AorderID = aorderId
        self.Acount = acount
        self.Avat = avat
        self.Adis = adis
        self.Asumtotal = asumtotal
        self.Arecieve = arecieve
        self.Achange = achange
    }
}

struct AdataDetail : Identifiable, Codable,Hashable {
    let id: UUID    
    var pname : String
    var pamount : Int
    var pprice : Double
    var Adate : Date
    var OrderID : String
    
    
    init(pname : String,pamount : Int , pprice : Double ,adate: Date, orderId : String) {
        id = UUID()
        self.pname = pname
        self.pamount = pamount
        self.pprice = pprice
        self.Adate = adate
        self.OrderID = orderId
    }
}

struct Analytics: View {
    //test codable added
    @State var showBill = false
    @State var order_id : String = ""
    @State var adata = [Adata]()
    @State var adetail = [AdataDetail]()
    @State private var searcttxt = ""
    @State private var search: [Adata] = []
    @State var item = [Items]()
    
    var body: some View {
        NavigationView {
            List{
                ForEach(searcttxt == "" ? adata : search) { i in
                    Section(header: Text("\(i.AorderID) \n รายการวันที่ \n \(i.Adate.formatted(date: .long, time: .standard))")) {
                        ForEach(adetail.filter({ $0.OrderID.contains(i.AorderID) })) { j in 
                        //ForEach(adetail) { j in
                            //Text("\(j.OrderID)")
                                    Text("รายการ : \(j.pname) x \(j.pamount)  : \(j.pprice,specifier: "%.2f")  ")
                        }
                        Text("ราคารวม : \(i.Atotal,specifier: "%.2f")")
                        Button(action: {
                            showBill = true
                        }, label: {
                            Text("Show Bill")
                        }).sheet(isPresented: $showBill) {
                            LocalBills(localDate: i.Adate, OrderCount: i.AorderID, count: i.Acount, total: i.Atotal, Vat: i.Avat, Dis: i.Adis, Sumtotal: i.Asumtotal, Recieve: i.Arecieve, change: i.Achange)
                            Button("Save to image") {
                                 
                                let image = LocalBills(localDate: i.Adate).snapshot()
                                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                            }.padding()
                        }
                    }
                }
            }.onAppear {
                    if let encodedData = UserDefaults.standard.data(forKey: "adetail") {
                        do {
                            adetail = try PropertyListDecoder().decode([AdataDetail].self , from: encodedData)
                        } catch let error as NSError {
                            NSLog("Unable to decode: error = \(error.localizedDescription)")
                        }
                    }
                }
            .onAppear {
                if let encodedData = UserDefaults.standard.data(forKey: "adata") {
                    do {
                        adata = try PropertyListDecoder().decode([Adata].self , from: encodedData)
                    } catch let error as NSError {
                        NSLog("Unable to decode: error = \(error.localizedDescription)")
                    }
                }
            }
            .onChange(of: searcttxt) { searchValue in
                if search.isEmpty {
                    search = adata.filter {
                    $0.Adate.formatted(.dateTime.month()) ==
                        "\(searcttxt)" }
                }else{
                    search = adata.filter { $0.AorderID.contains(searchValue)}
                }
            }
            .searchable(text: $searcttxt)
            .navigationBarTitle("รายงานการขาย")
        }
    }
    
    func delete(at offsets: IndexSet) {
        adata.remove(atOffsets: offsets)
    }
    
    func move(from source: IndexSet, to destination: Int) {
        adata.move(fromOffsets: source, toOffset: destination)
    }
    func getMonth(value: Int) -> String {
    let month = Calendar.current.date(byAdding: .month, value: value, to: Date())!
    return month.formatted(.dateTime.month())
    }
}

//Analytics 
struct LocalBills: View {
    @State var localDate : Date
    @State var OrderCount = ""
    @State var count = 0 
    @State var total = 0.00
    @State var Vat = 0.00
    @State var Dis = 0.00
    @State var Sumtotal = 0.00
    @State var Recieve = 0.00
    @State var change = 0.00
    @State var adetail = [AdataDetail]()
    var body: some View {
        VStack{
        VStack{
                Text("\(OrderCount)")
            Image.init(uiImage:  getSavedImage(named: "fileName") ?? UIImage() )
                .resizable()
                .cornerRadius(20)
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
            
                
                VStack(alignment: .leading ,spacing: 6.9){
                    Text("ชื่อร้าน \(Store_Setting().storeName)")
                    Text("บริการ \(Store_Setting().storeDetail)")
                    Text("เบอร์ร้าน \(Store_Setting().storeTel)")
                    Text("วันที่ \(localDate.formatted(date: .long, time: .shortened))")
                }
                Divider()
            //ForEach(adetail) { i in
            ForEach(adetail.filter({ $0.OrderID.contains(OrderCount) })) { i in
                    HStack{
                        Text("\(i.pname)")
                        Spacer()
                        Text("\(i.pprice,specifier: "%.2f") x \(i.pamount)")
                        Spacer()
                        Text("\(i.pprice * Double(i.pamount),specifier: "%.2f")")
                    }
                }
        }.onAppear {
            if let encodedData = UserDefaults.standard.data(forKey: "adetail") {
                do {
                    adetail = try PropertyListDecoder().decode([AdataDetail].self , from: encodedData)
                } catch let error as NSError {
                    NSLog("Unable to decode: error = \(error.localizedDescription)")
                }
            }
        }
                Divider()
                VStack{
                    HStack{
                        Text("Subtotal")
                        Spacer()
                        Text("\(count) items")
                        Spacer()
                        Text("\(total, specifier: "%.2f")")
                    }
                    HStack{
                        Text("Vat 7.00 %")
                        Spacer()
                        Text("\(Vat,specifier: "%.2f")")
                    }
                    HStack{
                        Text("Discount")
                        Spacer()
                        Text("\(Dis,specifier: "%.2f")฿")
                    }
                    Divider()
                    HStack{
                        Text("TOTAL")
                        Spacer()
                        Text("\(floor(Sumtotal),specifier: "%.2f")")
                    }
                    HStack{
                        Text("Recieve")
                        Spacer()
                        Text("\(Recieve,specifier: "%.2f")")
                    }
                    HStack{
                        Text("change")
                        Spacer()
                        Text("\(floor(change),specifier: "%.2f")")
                    }
                }
        }.padding()
            .background(Color(UIColor.systemBackground))
    }
    func getSavedImage(named: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
        }
        return nil
    }
}




