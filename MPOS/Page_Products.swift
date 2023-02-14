import SwiftUI

struct List_Order: View {
    @State  var showNavBar : Bool = true
    @State  var showIconCart : Bool = true
    @State  var showData : Bool = true
    @State  var showDetails : Bool = false
    @State  var showCart : Bool = false
    @State  var showingSheet : Bool = false
    @State  var showsearch : Bool = false
    @State  var showr : Bool = false
    @State  var showBill : Bool = false
    @State  var BtnPayment : Bool = true
    @State var total : Double = 0.00
    @State var count : Int = 0
    @State var Vat : Double = 0.00
    @State var Dis : Double = 0.00
    @State var Distxt : String = ""
    @State var Sumtotal : Double = 0.00
    @State var Recieve : Double = 0.00
    @State var Recievetxt : String = ""
    @State var change : Double = 0.00
    @State var search : String = ""
    @State var idAdatatxt : String = ""
    @State var entries = [Items]()
    @State var a_data = [Adata]()
    @State var a_detail = [AdataDetail]()
    @State var tp = [typeProducts]()
    @State var Money : [Int] = [20,50,100,500,1000]
    @ObservedObject var cart = Cart()
    @AppStorage("tapCount")  var OrderCount = 0
    let columnsMax = [GridItem(.flexible()),
                      GridItem(.flexible()),
                      GridItem(.flexible()),
                      GridItem(.flexible()),
                      GridItem(.flexible())
    ]
    let columnsCart = [GridItem(.flexible())]
    let columnsCartMax = [GridItem(.flexible()),
                      GridItem(.flexible()),
                      GridItem(.flexible())
    ]
    let columns = [GridItem(.flexible()),GridItem(.flexible())]
    var body: some View {
        VStack{
            HStack{
                if showNavBar {
                    Button(action: {
                        withAnimation(.easeOut(duration:0.3)){
                            showsearch.toggle()
                        }
                    }, label: {
                        Image(systemName: "magnifyingglass").imageScale(.large)
                            .padding(.init(top: 5, leading: 5, bottom: 5, trailing: 5))
                            .background(
                                Rectangle()
                                    .fill(.bar)
                                    .cornerRadius(15)
                                    .shadow(color: Color.gray
                                        .opacity(0.9),radius: 3,x: 0,y: 0)
                            )
                    }).padding()
                      Spacer()
                        Text("MPOS").padding()
                        Button(action: {
                            showingSheet.toggle()
                        }, label: {
                            Image(systemName: "plus.app.fill").imageScale(.large)
                                .padding(.init(top: 5, leading: 5, bottom: 5, trailing: 5))
                                .background(
                                    Rectangle()
                                        .fill(.bar)
                                        .cornerRadius(15)
                                        .shadow(color: Color.gray
                                            .opacity(0.9),radius: 3,x: 0,y: 0)
                                )
                        })
                        .sheet(isPresented: $showingSheet) {
                            ListProducts()
                        }
                    } 
                    Button(action: { 
                        withAnimation(.easeOut(duration:0.3)){
                            showCart.toggle()
                            showData.toggle()
                            showIconCart.toggle()
                            showNavBar.toggle()
                        }
                    }) {
                        ZStack{
                            if showIconCart {
                                Image(systemName: "cart.fill").imageScale(.large)
                                Text("\(cart.carts.count)")
                                    .tint(.white)
                                    .font(.footnote)
                                    .frame(width: 24, height: 24)
                                    .background(Circle().fill(Color.red))
                                    .scaleEffect(1.0)
                                    .animation(.easeInOut(duration: 2), value: 1.0)
                                    .offset(x: 12, y: -12)
                            }else{
                                Image(systemName: "arrowshape.backward.fill").imageScale(.large)
                            }
                        }
                        .padding(.init(top: 5, leading: 5, bottom: 5, trailing: 5))
                        .background(
                            Rectangle()
                                .fill(.bar)
                                .cornerRadius(15)
                                .shadow(color: Color.gray
                                    .opacity(0.9),radius: 3,x: 0,y: 0)
                        )
                    }.padding()
                    if !showNavBar{
                        Spacer()
                    }
            }
            if showsearch{
                SearchBar(text: $search)
                    .padding(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
            
            if showData{
                ScrollView(.horizontal) {
                    HStack{
                        Button(action: {
                            search = ""
                            print(search)
                        }, label: {
                            Text("ทั้งหมด")
                                .font(.caption)
                                .padding()
                                .background(
                                    Rectangle()
                                        .fill( search != "" ? Color(UIColor.systemBackground) : Color.orange )
                                        .cornerRadius(15)
                                        .shadow(color: Color.gray
                                            .opacity(0.9),radius: 3,x: 0,y: 0)
                                )
                        }) 
                        .padding(.init(top: 10, leading: 10, bottom: 10, trailing: 0))
                        ForEach(tp) { tp in
                            Button(action: {
                                search = tp.tpname
                                print(search)
                            }, label: {
                                Text("\(tp.tpname)")
                                    .font(.caption)
                                    .padding()
                                    .background(
                                        Rectangle()
                                            .fill( search != tp.tpname ? Color(UIColor.systemBackground) : Color.orange )
                                            .cornerRadius(15)
                                            .shadow(color: Color.gray
                                                .opacity(0.9),radius: 3,x: 0,y: 0)
                                    )
                            }) 
                            .padding(.init(top: 10, leading: 10, bottom: 10, trailing: 0))
                        }
                    }
                    .onAppear{
                        if let encodedData = UserDefaults.standard.data(forKey: "tp") {
                            do {
                                tp = try PropertyListDecoder().decode([typeProducts].self , from: encodedData)
                            } catch let error as NSError {
                                NSLog("Unable to decode: error = \(error.localizedDescription)")
                            }
                        }
                    }
                    .frame(maxWidth : .infinity)
                }
                GeometryReader{ geometry in
                    //Text("\(geometry.size.width)")
                    RefreshableScrollView{
                        LazyVGrid(columns:(geometry.size.width > 510 ? columnsMax : columns), spacing: 10) {
                            VStack{
                                Text("Found\n\(entries.filter({ search.isEmpty ? true : $0.Pname.contains(search) || $0.Ptp.contains(search) }).count) Results")
                                    .font(.system(size: 24, weight: .bold, design: .default))
                            }
                            ForEach(Array(entries.filter({ search.isEmpty ? true : $0.Pname.contains(search) || $0.Ptp.contains(search) }).enumerated()), id: \.element ) { index, entry in
                                ZStack{
                                    Button(action: {
                                        self.count += 1
                                        self.total += entry.Pprice
                                        self.Vat = (Store_Setting().storeTax/100)*total
                                        self.Sumtotal = (total+Vat)-Dis
                                        cart.addProduct(item: Items(Pname: entry.Pname, Pdetail: entry.Pdetail, Pprice: entry.Pprice, Pamount: entry.Pamount,qty : 1,Ptp :entry.Ptp,imageFileName: entry.imageFileName, status: false, itemindex: entry.itemidex ))
                                        //print("found \(entries.filter({ search.isEmpty ? true : $0.Pname.contains(search) || $0.Ptp.contains(search) }).count) resalts")
                                        entries.remove(at: index)
                                        entries.insert(Items(Pname: entry.Pname, Pdetail: entry.Pdetail, Pprice: entry.Pprice, Pamount: Int(entry.Pamount) - 1, qty: entry.qty, Ptp: entry.Ptp, imageFileName: entry.imageFileName,status: false, itemindex: entry.itemidex ), at: index )
                                        print("entry.index = \(entry.itemidex)")
                                        //print("amount = \(Int(entry.Pamount - 1))")
                                        UserDefaults.standard.set(try? PropertyListEncoder().encode(entries), forKey: "Bills")
                                    }, label: {
                                        if (entry.Pamount == 0 ) { 
                                            ZStack{
                                                VStack(alignment: .leading){
                                                    Image.init(uiImage:  getSavedImage(named: entry.imageFileName) ?? UIImage() )
                                                        .resizable()
                                                        .frame(width: 100, height: 100)
                                                        .cornerRadius(20)
                                                        .aspectRatio(contentMode: .fit)
                                                    Text("\(entry.Pname)").font(.headline)
                                                    Text("\(entry.Pdetail)").font(.caption)
                                                    Text("จำนวน :\(entry.Pamount)").font(.caption)
                                                    Text("฿\(entry.Pprice,specifier: "%.2f")").font(.title3)
                                                }.frame(width: 100.0, height: 100.0)
                                                    .padding(.init(top: 45, leading: 0, bottom: 30, trailing: 0))
                                                
                                            }
                                        }
                                        else if (entry.Pamount <= 1 ) { 
                                            VStack{
                                                Text("\(entry.Pname)")
                                                Text("last one")
                                            }.frame(width: 100.0, height: 100.0)
                                                .padding(.init(top: 45, leading: 0, bottom: 30, trailing: 0))
                                        }
                                        else{
                                            ZStack{
                                                VStack(alignment: .leading){
                                                    Image.init(uiImage:  getSavedImage(named: entry.imageFileName) ?? UIImage() )
                                                        .resizable()
                                                        .frame(width: 100, height: 100)
                                                        .cornerRadius(20)
                                                        .aspectRatio(contentMode: .fit)
                                                    Text("\(entry.Pname)").font(.headline)
                                                    Text("\(entry.Pdetail)").font(.caption)
                                                    Text("จำนวน :\(entry.Pamount)").font(.caption)
                                                    Text("฿\(entry.Pprice,specifier: "%.2f")").font(.title3)
                                                }.frame(width: 100.0, height: 100.0)
                                                    .padding(.init(top: 45, leading: 0, bottom: 30, trailing: 0))
                                            }
                                        }
                                    })
                                    .disabled(entry.Pamount == 0)
                                    if (entry.Pamount == 0 ) {
                                        Rectangle()
                                            .foregroundColor(Color.black.opacity(0.5))
                                            .cornerRadius(10)
                                        Image("SoldOut")
                                            .resizable()
                                            .frame(width: 100, height: 100)
                                            .cornerRadius(20)
                                            .aspectRatio(contentMode: .fit)
                                    }
                                } 
                            }
                        }
                        .onAppear{
                            if let encodedData = UserDefaults.standard.data(forKey: "Bills") {
                                do {
                                    entries = try PropertyListDecoder().decode([Items].self , from: encodedData)
                                } catch let error as NSError {
                                    NSLog("Unable to decode: error = \(error.localizedDescription)")
                                }
                            }
                        }
                        .padding()
                        .buttonStyle( GrowingButton() )
                        .modifier(CardModifier())
                    }onRefresh: {
                        if let encodedData = UserDefaults.standard.data(forKey: "Bills") {
                            do {
                                entries = try PropertyListDecoder().decode([Items].self , from: encodedData)
                            } catch let error as NSError {
                                NSLog("Unable to decode: error = \(error.localizedDescription)")
                            }
                        }
                    }
                }
            }
                if showCart {
                    HStack{
                        Text("รายการสินค้าที่เลือก").font(.headline)
                        Text("\(count)")
                        Button(action: {
                            for (_, i) in cart.carts.enumerated() {
                                entries.remove(at: i.itemidex)
                                entries.insert(Items(Pname: i.Pname, Pdetail: i.Pdetail, Pprice: i.Pprice, Pamount: Int(i.Pamount-i.qty)+i.qty, qty: i.qty, Ptp: i.Ptp, imageFileName: i.imageFileName,status: i.Status, itemindex: i.itemidex ), at: i.itemidex )
                                UserDefaults.standard.set(try? PropertyListEncoder().encode(entries), forKey: "Bills")
                            }
                            cart.carts.removeAll()
                            self.count = 0
                            self.total = 0
                            self.Vat = 0
                            self.Dis = 0
                            self.Sumtotal = 0
                        }, label: {
                            Text("ล้าง")
                                .tint(.white)
                                .padding(.init(top: 5, leading: 5, bottom: 5, trailing: 5))
                                .frame(width : 60)
                                .background(
                                    Rectangle()
                                        .fill(.red)
                                        .cornerRadius(5)
                                        .shadow(color: Color.gray
                                            .opacity(0.9),radius: 3,x: 0,y: 0)
                                )
                        }).padding()
                    }
                    if(cart.carts.isEmpty) {
                        VStack {
                            Spacer()
                            Text("ไม่พบรายการสินค้า")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                    } else {
                        GeometryReader{ geometry in
                            ScrollView{
                                LazyVGrid(columns: (geometry.size.width > 510 ? columnsCartMax : columnsCart ), spacing: 10) {
                                    ForEach(Array(cart.carts.enumerated()), id: \.element) { index ,i in 
                                        HStack(alignment: .center) {
                                            Image.init(uiImage:  getSavedImage(named: i.imageFileName) ?? UIImage() )
                                                .resizable()
                                                .frame(width: 80, height: 80)
                                                .cornerRadius(20)
                                                .aspectRatio(contentMode: .fit)
                                                .padding(.all, 20)
                                            
                                            VStack(alignment: .leading) {
                                                Text("\(i.Pname)")
                                                    .font(.system(size: 18, weight: .bold, design: .default))
                                                Text("\(i.Pdetail)")
                                                    .font(.system(size: 14, weight: .bold, design: .default))
                                                Text("฿\(i.Pprice,specifier: "%.2f")")
                                                    .font(.system(size: 16, weight: .bold, design: .default))
                                                    .padding(.top)
                                                
                                            }.padding(.trailing, 20)
                                            Spacer()
                                            VStack{
                                                Button {
                                                    self.count += 1
                                                    self.total += i.Pprice
                                                    self.Vat = (Store_Setting().storeTax/100)*total
                                                    self.Sumtotal = (total+Vat)-Dis
                                                    cart.addProduct(item: Items(Pname: i.Pname, Pdetail: i.Pdetail, Pprice: i.Pprice, Pamount: i.Pamount,qty : 1 ,Ptp: i.Ptp,imageFileName: i.imageFileName,status: i.Status, itemindex: i.itemidex))
                                                    entries.remove(at: i.itemidex)
                                                    entries.insert(Items(Pname: i.Pname, Pdetail: i.Pdetail, Pprice: i.Pprice, Pamount: Int(i.Pamount) - (i.qty+1), qty: i.qty, Ptp: i.Ptp, imageFileName: i.imageFileName,status: i.Status, itemindex: i.itemidex ), at: i.itemidex )
                                                    //print("entry.index = \(i.itemidex)")
                                                    //print("amount = \(Int(entry.Pamount - 1))")
                                                    UserDefaults.standard.set(try? PropertyListEncoder().encode(entries), forKey: "Bills")
                                                } label: {
                                                    Image(systemName: "plus.square.fill").imageScale(.large)
                                                }.disabled(i.qty >= i.Pamount ? true:false)
                                                
                                                Text("\(i.qty)")
                                                    .font(.system(size: 16, weight: .bold, design: .default))
                                                    .padding(.init(top: 3, leading: 0, bottom: 3, trailing: 0))
                                                Button {
                                                    self.count -= 1
                                                    self.total -= i.Pprice
                                                    self.Vat -= (Store_Setting().storeTax/100)*i.Pprice
                                                    self.Sumtotal = (total+Vat)-Dis
                                                    if total == 0 {
                                                        Sumtotal = 0
                                                    }
                                                    if i.qty == 1 {
                                                        entries.remove(at: i.itemidex)
                                                        entries.insert(Items(Pname: i.Pname, Pdetail: i.Pdetail, Pprice: i.Pprice, Pamount: Int(i.Pamount-i.qty) + 1, qty: i.qty, Ptp: i.Ptp, imageFileName: i.imageFileName,status: i.Status, itemindex: i.itemidex ), at: i.itemidex )
                                                        //print("entry.index = \(i.itemidex)")
                                                        //print("amount = \(Int(entry.Pamount - 1))")
                                                        UserDefaults.standard.set(try? PropertyListEncoder().encode(entries), forKey: "Bills")
                                                        cart.carts.remove(at:cart.carts.firstIndex(of: i )!)
                                                    }else{
                                                        cart.outProduct(item: Items(Pname: i.Pname, Pdetail: i.Pdetail, Pprice: i.Pprice, Pamount: i.Pamount,qty : 1,Ptp: i.Ptp, imageFileName: i.imageFileName, status: true, itemindex: i.itemidex))
                                                        
                                                        entries.remove(at: i.itemidex)
                                                        entries.insert(Items(Pname: i.Pname, Pdetail: i.Pdetail, Pprice: i.Pprice, Pamount: Int(i.Pamount-i.qty) + 1, qty: i.qty, Ptp: i.Ptp, imageFileName: i.imageFileName,status: i.Status, itemindex: i.itemidex ), at: i.itemidex )
                                                        //print("entry.index = \(i.itemidex)")
                                                        //print("amount = \(Int(entry.Pamount - 1))")
                                                        UserDefaults.standard.set(try? PropertyListEncoder().encode(entries), forKey: "Bills")
                                                    }
                                                    
                                                } label: {
                                                    Image(systemName: "minus.square.fill").imageScale(.large)
                                                }// btn minus
                                            }
                                            VStack{
                                                Button { 
                                                    self.count -= i.qty
                                                    self.total -= i.Pprice * Double(i.qty)
                                                    self.Vat -= (Store_Setting().storeTax/100)*(i.Pprice * Double(i.qty))
                                                    self.Sumtotal = (total+Vat)-Dis
                                                    if total == 0 {
                                                        Sumtotal = 0
                                                    }
                                                    entries.remove(at: i.itemidex)
                                                    entries.insert(Items(Pname: i.Pname, Pdetail: i.Pdetail, Pprice: i.Pprice, Pamount: Int(i.Pamount-i.qty)+i.qty, qty: i.qty, Ptp: i.Ptp, imageFileName: i.imageFileName,status: i.Status, itemindex: i.itemidex ), at: i.itemidex )
                                                    UserDefaults.standard.set(try? PropertyListEncoder().encode(entries), forKey: "Bills")
                                                    cart.carts.remove(at:cart.carts.firstIndex(of: i )!)
                                                } label: { 
                                                    ZStack{
                                                        Image(systemName: "xmark.circle.fill").imageScale(.large)
                                                            .frame(width: 50, height: 30)
                                                            .background(RoundedRectangle(cornerRadius: 3).fill(Color.red))
                                                            .scaleEffect(1.0)
                                                            .animation(.easeInOut(duration: 2), value: 1.0)
                                                            .offset(x: 10, y: 0)
                                                    }.buttonStyle(.plain)
                                                }
                                                Spacer()
                                            }
                                        }
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .background(.bar)
                                        //Color(red: 32/255, green: 36/255, blue: 38/255)
                                        .modifier(CardModifier())
                                        .padding(.all, 5)
                                    }//ForEach(cart.carts)
                                }//LazyVGrid
                            }//scrollview
                        }
                    }
                    Spacer()
                    Button(action: {
                        withAnimation(.easeOut(duration:0.3)){
                            showDetails.toggle()
                        }
                    }, label: {
                        if showDetails {
                            Text("ปิด")
                        }else{
                            Text("แสดง ฿\(Sumtotal,specifier: "%.2f")")
                        }
                    })
                    .tint(showDetails ? .red : .orange)
                    .buttonStyle(.borderedProminent)
                    .padding()
                    .disabled(Sumtotal == 0 ? true : false)
                    if showDetails {
                        VStack{
                            HStack{
                                Text("รวมการสั่งซื้อ")
                                Spacer()
                                Text("฿\(total, specifier: "%.2f")")
                            }.padding(.init(top: 20, leading: 15, bottom: 2, trailing: 15))
                            HStack{
                                Text("Vat \(Store_Setting().storeTax_txt).00 %")
                                Spacer()
                                Text("฿\(Vat,specifier: "%.2f")")
                            }.padding(.init(top: 0, leading: 15, bottom: 2, trailing: 15))
                            HStack{
                                Text("ส่วนลด")
                                Spacer()
                                Text("฿")
                                TextField("\(Dis,specifier: "%.2f")", text: $Distxt)
                                    .onChange(of: Distxt) { _ in                         
                                        Dis = Double(Distxt) ?? 0.0
                                    }.frame(width: 50 )
                                    .multilineTextAlignment(.trailing)
                            }.padding(.init(top: 0, leading: 15, bottom: 0, trailing: 15))
                            Divider()
                            HStack{
                                Text("ยอดชำระเงินทั้งหมด").font(.headline)
                                Spacer()
                                Text("฿\(Sumtotal,specifier: "%.2f")").font(.largeTitle)
                            }.padding(.init(top: 0, leading: 15, bottom: 5, trailing: 15))
                            Button(action: {
                                showr.toggle()
                            }, label: {
                                Text("ชำระเงิน")
                                    .font(.title)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .background(
                                        Rectangle()
                                            .fill(.orange)
                                            .cornerRadius(15)
                                            .shadow(color: Color.gray
                                                .opacity(0.9),radius: 3,x: 0,y: 0)
                                    )
                            }).padding(.init(top: 0, leading: 15, bottom: 0, trailing: 15))
                                .sheet(isPresented: $showr) {
                                    Text("ยอดเงิน ฿\(Sumtotal,specifier: "%.2f")").font(.title)
                                    TextField("รับเงิน ฿\(Recieve,specifier: "%.2f")", text: $Recievetxt).font(.title)
                                        .onChange(of: Recievetxt) { _ in                         
                                            Recieve = Double(Recievetxt) ?? 0.0
                                        }
                                        .multilineTextAlignment(.center)
                                    ScrollView(.horizontal){
                                        HStack{
                                            ForEach(0..<Money.count, id: \.self) { index in
                                                Button(action: {
                                                    Recieve = Double(Money[index])
                                                }, label: {
                                                    Text("฿\(Money[index])")
                                                }).tint(.orange)
                                                    .controlSize(.large)
                                                    .buttonStyle(.borderedProminent)
                                            }
                                        }
                                    }.padding()
                                    Button(action: {
                                        change = Recieve - Sumtotal
                                        BtnPayment = false
                                    }, label: {
                                        Text("คำนวณเงินทอน").font(.title).padding()
                                    }).tint(.orange)
                                        .controlSize(.large)
                                        .buttonStyle(.borderedProminent)
                                        .disabled(Recieve >= Sumtotal ? false : true)
                                    Text("฿\(change,specifier: "%.2f")").font(.title)
                                    
                                    Button(action: {
                                        for (_, i) in cart.carts.enumerated() {
                                            a_detail.append(
                                                AdataDetail(
                                                    pname: i.Pname,
                                                    pamount: i.qty,
                                                    pprice: i.Pprice,
                                                    adate: Date.now ,
                                                    orderId : "ORDER\(OrderCount)"))
                                        }
                                        a_data.append(Adata(adate: Date.now, atotal: total, aorderId: "ORDER\(OrderCount)", acount: count, avat: Vat, adis: Dis, asumtotal: Sumtotal, arecieve: Recieve, achange: change))
                                        
                                        UserDefaults.standard.set(try? PropertyListEncoder().encode(a_data), forKey: "adata")
                                        UserDefaults.standard.set(try? PropertyListEncoder().encode(a_detail), forKey: "adetail")
                                        OrderCount += 1
                                        print("\(OrderCount)")
                                        showBill.toggle()
                                    }, label: {
                                        Text("ยืนยันการชำระเงิน").font(.title).padding()
                                    })
                                    .tint(.green)
                                    .controlSize(.large)
                                    .buttonStyle(.borderedProminent)
                                    .disabled(BtnPayment)
                                    .fullScreenCover(isPresented: $showBill) {
                                        BillView
                                        Button("บันทึกใบเสร็จ") {
                                            let image = BillView.snapshot()
                                            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                                            for (_, i) in cart.carts.enumerated() {
                                                entries.remove(at: i.itemidex)
                                                entries.insert(Items(Pname: i.Pname, Pdetail: i.Pdetail, Pprice: i.Pprice, Pamount: Int(i.Pamount-i.qty) , qty: i.qty, Ptp: i.Ptp, imageFileName: i.imageFileName,status: i.Status, itemindex: i.itemidex ), at: i.itemidex )
                                                UserDefaults.standard.set(try? PropertyListEncoder().encode(entries), forKey: "Bills")
                                            }
                                            cart.carts.removeAll()
                                            self.count = 0
                                            self.total = 0
                                            self.Vat = 0
                                            self.Dis = 0
                                            self.Recieve = 0
                                            self.Recievetxt = ""
                                            self.Sumtotal = 0
                                            self.change = 0
                                            BtnPayment = false
                                            withAnimation(.easeOut(duration:0.3)){
                                                showBill = false
                                                showr = false
                                                showCart = false
                                                showData = true
                                                showNavBar = true
                                                showIconCart = true
                                            }
                                        }.padding()
                                    }
                                }
                            Spacer()
                        }//Vstack
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(.bar)
                        //Color(red: 32/255, green: 36/255, blue: 38/255)
                        .modifier(CardModifier())
                        .padding(.all, 5)
                    }
                }
        }
    }
    
        var BillView: some View {
            VStack{
                Text("ORDER\(OrderCount-1)")
                Image.init(uiImage:  getSavedImage(named: "fileName") ?? UIImage() )
                    .resizable()
                    .cornerRadius(20)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                
                VStack(alignment: .leading ,spacing: 6.9){
                    Text("ชื่อร้าน \(Store_Setting().storeName)")
                    Text("บริการ \(Store_Setting().storeDetail)")
                    Text("เบอร์ร้าน \(Store_Setting().storeTel)")
                    Text("วันที่ \(Date.now.formatted(date: .long, time: .shortened))")
                }
                Divider()
                    ForEach(cart.carts) { i in
                        HStack{
                            Text("\(i.Pname)")
                            Spacer()
                            Text("\(i.Pprice,specifier: "%.2f") x \(i.qty)")
                            Spacer()
                            Text("฿\(i.Pprice * Double(i.qty),specifier: "%.2f")")
                        }
                    }
                Divider()
                VStack{
                    HStack{
                        Text("รวมการสั่งซื้อ")
                        Spacer()
                        Text("\(count) items")
                        Spacer()
                        Text("฿\(total, specifier: "%.2f")")
                    }
                    HStack{
                        Text("Vat 7.00 %")
                        Spacer()
                        Text("฿\(Vat,specifier: "%.2f")")
                    }
                    HStack{
                        Text("ส่วนลด")
                        Spacer()
                        Text("฿\(Dis,specifier: "%.2f")")
                    }
                    Divider()
                    HStack{
                        Text("ยอดชำระเงินทั้งหมด")
                        Spacer()
                        Text("\(Sumtotal,specifier: "%.2f")")
                    }
                    HStack{
                        Text("รับเงินสด")
                        Spacer()
                        Text("฿\(Recieve,specifier: "%.2f")")
                    }
                    HStack{
                        Text("เงินทอน")
                        Spacer()
                        Text("฿\(change,specifier: "%.2f")")
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
    
    func delete(at offsets: IndexSet) {
        cart.carts.remove(atOffsets: offsets)
        //UserDefaults.standard.set(try? PropertyListEncoder().encode(cart.carts), forKey: "cart")
    }
}//List_Order


class Cart: ObservableObject {
    @Published var carts = [Items]()
    func addProduct(item: Items) {
        var addNewProduct = true
        for (index, i) in carts.enumerated() {
            if i.Pname == item.Pname {
                carts[index].qty = carts[index].qty + 1
                addNewProduct = false
            }
            print("add : \(item)")
        }
        if addNewProduct {
            carts.append(item)
        }
        //print("Product Add \(item)")
    }
    func outProduct(item: Items) {
        var addNewProduct = true
        for (index, i) in carts.enumerated() {
            if i.Pname == item.Pname {
                carts[index].qty = carts[index].qty - 1
                addNewProduct = false
            }
            print("out \(item)")
        }
        if addNewProduct {
            carts.append(item)
        }
        //print("Product Add \(item)")
    }
}

