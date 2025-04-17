import SwiftUI

struct Subscription: Identifiable {
    var id = UUID()
    var name: String
    var amount: Double
    var billingCycle: String // Ödeme döngüsü (aylık, yıllık...)
    var nextBillingDate: Date
    var icon: String // SF Symbol
    var color: Color
}

struct SubscriptionsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var subscriptions: [Subscription] = [
        Subscription(
            name: "Netflix",
            amount: 149.99,
            billingCycle: "Aylık",
            nextBillingDate: Calendar.current.date(byAdding: .day, value: 12, to: Date())!,
            icon: "tv.fill",
            color: Color.red
        ),
        Subscription(
            name: "Spotify",
            amount: 59.90,
            billingCycle: "Aylık",
            nextBillingDate: Calendar.current.date(byAdding: .day, value: 8, to: Date())!,
            icon: "music.note",
            color: Color.green
        ),
        Subscription(
            name: "Gym",
            amount: 1500,
            billingCycle: "Aylık",
            nextBillingDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
            icon: "figure.walk",
            color: Color.orange
        ),
        Subscription(
            name: "iCloud+",
            amount: 249.99,
            billingCycle: "Aylık",
            nextBillingDate: Calendar.current.date(byAdding: .day, value: 22, to: Date())!,
            icon: "cloud.fill",
            color: Color.blue
        )
    ]
    
    @State private var showingAddSubscription = false
    @State private var searchText = ""
    @State private var subscriptionToEdit: Subscription? = nil
    @State private var showingDeleteAlert = false
    @State private var subscriptionToDelete: Subscription? = nil
    
    var totalMonthlyAmount: Double {
        subscriptions.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        ZStack {
            AppColors.backgroundDark.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Aylık Toplam Kart
                VStack(spacing: 10) {
                    Text("Aylık Toplam")
                        .font(.subheadline)
                        .foregroundColor(AppColors.secondaryTextDark)
                    
                    Text("₺\(String(format: "%.2f", totalMonthlyAmount))")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(AppColors.textDark)
                    
                    Text("\(subscriptions.count) aktif abonelik")
                        .font(.caption)
                        .foregroundColor(AppColors.secondaryTextDark)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 25)
                .background(AppColors.cardDark)
                
                // Arama Çubuğu
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppColors.secondaryTextDark)
                    
                    TextField("Abonelik Ara", text: $searchText)
                        .foregroundColor(AppColors.textDark)
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Aboneliklerin listesi
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(filteredSubscriptions) { subscription in
                            SubscriptionRow(
                                subscription: subscription,
                                onEdit: {
                                    subscriptionToEdit = subscription
                                },
                                onDelete: {
                                    subscriptionToDelete = subscription
                                    showingDeleteAlert = true
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Aboneliklerim")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddSubscription = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showingAddSubscription) {
            AddSubscriptionView(isPresented: $showingAddSubscription, subscriptions: $subscriptions)
        }
        .sheet(item: $subscriptionToEdit) { subscription in
            EditSubscriptionView(
                subscription: subscription,
                subscriptions: $subscriptions,
                isPresented: Binding(
                    get: { subscriptionToEdit != nil },
                    set: { if !$0 { subscriptionToEdit = nil } }
                )
            )
        }
        .alert("Aboneliği Sil", isPresented: $showingDeleteAlert) {
            Button("İptal", role: .cancel) {}
            Button("Sil", role: .destructive) {
                if let subscriptionToDelete = subscriptionToDelete, 
                   let index = subscriptions.firstIndex(where: { $0.id == subscriptionToDelete.id }) {
                    subscriptions.remove(at: index)
                }
            }
        } message: {
            if let subscription = subscriptionToDelete {
                Text("\(subscription.name) aboneliğini silmek istediğinize emin misiniz?")
            } else {
                Text("Bu aboneliği silmek istediğinize emin misiniz?")
            }
        }
    }
    
    var filteredSubscriptions: [Subscription] {
        if searchText.isEmpty {
            return subscriptions
        } else {
            return subscriptions.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
}

struct SubscriptionRow: View {
    let subscription: Subscription
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var showingOptions = false
    
    var body: some View {
        HStack(spacing: 15) {
            // Icon
            ZStack {
                Circle()
                    .fill(subscription.color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: subscription.icon)
                    .font(.system(size: 20))
                    .foregroundColor(subscription.color)
            }
            
            // Detaylar
            VStack(alignment: .leading, spacing: 4) {
                Text(subscription.name)
                    .font(.headline)
                    .foregroundColor(AppColors.textDark)
                
                Text(subscription.billingCycle)
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryTextDark)
            }
            
            Spacer()
            
            // Aylık ücret ve ödeme tarihi
            VStack(alignment: .trailing, spacing: 4) {
                Text("₺\(String(format: "%.2f", subscription.amount))")
                    .font(.headline)
                    .foregroundColor(AppColors.textDark)
                
                Text(formatDate(subscription.nextBillingDate))
                    .font(.caption)
                    .foregroundColor(
                        daysUntil(subscription.nextBillingDate) < 5
                        ? AppColors.expense
                        : AppColors.secondaryTextDark
                    )
            }
        }
        .padding()
        .background(AppColors.cardDark)
        .cornerRadius(12)
        .contentShape(Rectangle())
        .onTapGesture {
            showingOptions = true
        }
        .actionSheet(isPresented: $showingOptions) {
            ActionSheet(
                title: Text(subscription.name),
                message: Text("Ne yapmak istersiniz?"),
                buttons: [
                    .default(Text("Düzenle"), action: onEdit),
                    .destructive(Text("Sil"), action: onDelete),
                    .cancel(Text("İptal"))
                ]
            )
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: date)
    }
    
    func daysUntil(_ date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: date)
        return components.day ?? 0
    }
}

struct EditSubscriptionView: View {
    let subscription: Subscription
    @Binding var subscriptions: [Subscription]
    @Binding var isPresented: Bool
    
    @State private var name: String
    @State private var amount: String
    @State private var billingCycle: String
    @State private var nextBillingDate: Date
    @State private var icon: String
    @State private var selectedColor: Color
    
    // İkonlar ve abonelik döngüleri için seçenekler
    private let iconOptions = ["tv.fill", "music.note", "cloud.fill", "gamecontroller.fill", "magazine.fill", "mail.fill", "bag.fill", "car.fill", "figure.walk", "fork.knife", "house.fill", "dollarsign.circle.fill", "wifi"]
    private let billingCycleOptions = ["Günlük", "Haftalık", "Aylık", "Yıllık"]
    private let colorOptions: [Color] = [.red, .blue, .green, .orange, .purple, .pink, AppColors.accentYellow, AppColors.primaryBlue, AppColors.expense, AppColors.income]
    
    init(subscription: Subscription, subscriptions: Binding<[Subscription]>, isPresented: Binding<Bool>) {
        self.subscription = subscription
        self._subscriptions = subscriptions
        self._isPresented = isPresented
        
        _name = State(initialValue: subscription.name)
        _amount = State(initialValue: String(format: "%.2f", subscription.amount))
        _billingCycle = State(initialValue: subscription.billingCycle)
        _nextBillingDate = State(initialValue: subscription.nextBillingDate)
        _icon = State(initialValue: subscription.icon)
        _selectedColor = State(initialValue: subscription.color)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.backgroundDark.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Önizleme
                        VStack(spacing: 15) {
                            ZStack {
                                Circle()
                                    .fill(selectedColor.opacity(0.2))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: icon)
                                    .font(.system(size: 40))
                                    .foregroundColor(selectedColor)
                            }
                            
                            Text(name.isEmpty ? "Abonelik İsmi" : name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.textDark)
                            
                            Text(amount.isEmpty ? "₺0.00" : "₺\(amount) / \(billingCycle)")
                                .font(.headline)
                                .foregroundColor(AppColors.secondaryTextDark)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(AppColors.cardDark)
                        .cornerRadius(12)
                        
                        // Form alanları
                        VStack(spacing: 15) {
                            // İsim
                            FormField(title: "Abonelik İsmi", placeholder: "Örn. Netflix", text: $name)
                            
                            // Miktar
                            FormField(title: "Ödeme Tutarı", placeholder: "Örn. 149.99", text: $amount)
                                .keyboardType(.decimalPad)
                            
                            // Ödeme Döngüsü
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Ödeme Döngüsü")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textDark)
                                
                                HStack {
                                    ForEach(billingCycleOptions, id: \.self) { cycle in
                                        Button(action: {
                                            billingCycle = cycle
                                        }) {
                                            Text(cycle)
                                                .font(.subheadline)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 5)
                                                .background(billingCycle == cycle ? selectedColor.opacity(0.2) : Color.gray.opacity(0.1))
                                                .foregroundColor(billingCycle == cycle ? selectedColor : AppColors.secondaryTextDark)
                                                .cornerRadius(5)
                                        }
                                    }
                                }
                                .padding(.horizontal, 5)
                            }
                            
                            // Sonraki Ödeme Tarihi
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Sonraki Ödeme Tarihi")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textDark)
                                
                                DatePicker("", selection: $nextBillingDate, displayedComponents: .date)
                                    .datePickerStyle(GraphicalDatePickerStyle())
                                    .accentColor(selectedColor)
                                    .background(AppColors.cardDark)
                                    .cornerRadius(12)
                            }
                        }
                        .padding()
                        .background(AppColors.cardDark)
                        .cornerRadius(12)
                        
                        // İkon ve Renk Seçimi
                        VStack(spacing: 15) {
                            Text("İkon Seç")
                                .font(.headline)
                                .foregroundColor(AppColors.textDark)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 15) {
                                ForEach(iconOptions, id: \.self) { iconOption in
                                    ZStack {
                                        Circle()
                                            .fill(icon == iconOption ? selectedColor.opacity(0.2) : Color.gray.opacity(0.1))
                                            .frame(width: 50, height: 50)
                                        
                                        Image(systemName: iconOption)
                                            .font(.system(size: 24))
                                            .foregroundColor(icon == iconOption ? selectedColor : AppColors.secondaryTextDark)
                                    }
                                    .onTapGesture {
                                        icon = iconOption
                                    }
                                }
                            }
                            
                            Text("Renk Seç")
                                .font(.headline)
                                .foregroundColor(AppColors.textDark)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 10)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 45))], spacing: 15) {
                                ForEach(colorOptions, id: \.self) { color in
                                    Circle()
                                        .fill(color)
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: selectedColor == color ? 2 : 0)
                                        )
                                        .onTapGesture {
                                            selectedColor = color
                                        }
                                }
                            }
                        }
                        .padding()
                        .background(AppColors.cardDark)
                        .cornerRadius(12)
                    }
                    .padding()
                }
            }
            .navigationTitle("Aboneliği Düzenle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        isPresented = false
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        guard let amountValue = Double(amount) else { return }
                        
                        let updatedSubscription = Subscription(
                            id: subscription.id,
                            name: name,
                            amount: amountValue,
                            billingCycle: billingCycle,
                            nextBillingDate: nextBillingDate,
                            icon: icon,
                            color: selectedColor
                        )
                        
                        if let index = subscriptions.firstIndex(where: { $0.id == subscription.id }) {
                            subscriptions[index] = updatedSubscription
                        }
                        
                        isPresented = false
                    }
                    .foregroundColor(.white)
                    .disabled(name.isEmpty || amount.isEmpty)
                }
            }
        }
    }
}

struct AddSubscriptionView: View {
    @Binding var isPresented: Bool
    @Binding var subscriptions: [Subscription]
    
    @State private var name = ""
    @State private var amount = ""
    @State private var billingCycle = "Aylık"
    @State private var nextBillingDate = Date()
    @State private var selectedColor = Color.blue
    @State private var selectedIcon = "star.fill"
    
    let billingOptions = ["Günlük", "Haftalık", "Aylık", "Yıllık"]
    let colorOptions: [Color] = [.blue, .red, .green, .orange, .purple, .pink]
    let iconOptions = ["tv.fill", "music.note", "book.fill", "gamecontroller.fill", "cloud.fill", "creditcard.fill", "figure.walk", "car.fill", "house.fill", "star.fill"]
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.backgroundDark.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Icon & Renk Seçimi
                        VStack {
                            ZStack {
                                Circle()
                                    .fill(selectedColor.opacity(0.2))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: selectedIcon)
                                    .font(.system(size: 40))
                                    .foregroundColor(selectedColor)
                            }
                            .padding(.bottom)
                            
                            // Renk Seçenekleri
                            Text("Renk Seç")
                                .font(.subheadline)
                                .foregroundColor(AppColors.secondaryTextDark)
                            
                            HStack(spacing: 15) {
                                ForEach(colorOptions, id: \.self) { color in
                                    Circle()
                                        .fill(color)
                                        .frame(width: 30, height: 30)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: selectedColor == color ? 2 : 0)
                                        )
                                        .onTapGesture {
                                            selectedColor = color
                                        }
                                }
                            }
                            .padding(.bottom)
                            
                            //Icon Ayartları
                            Text("İkon Seç")
                                .font(.subheadline)
                                .foregroundColor(AppColors.secondaryTextDark)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 15) {
                                ForEach(iconOptions, id: \.self) { icon in
                                    ZStack {
                                        Circle()
                                            .fill(selectedIcon == icon ? selectedColor.opacity(0.2) : Color.gray.opacity(0.1))
                                            .frame(width: 50, height: 50)
                                        
                                        Image(systemName: icon)
                                            .font(.system(size: 24))
                                            .foregroundColor(selectedIcon == icon ? selectedColor : AppColors.secondaryTextDark)
                                    }
                                    .onTapGesture {
                                        selectedIcon = icon
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(AppColors.cardDark)
                        .cornerRadius(12)
                        
                        // Form field
                        VStack(spacing: 15) {
                            FormField(title: "Abonelik Adı", placeholder: "Örn. Netflix", text: $name)
                            
                            FormField(title: "Ücret", placeholder: "Örn. 99.90", text: $amount)
                                .keyboardType(.decimalPad)
                            
                            // Faturalandırma zamanları
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Faturalandırma Sıklığı")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textDark)
                                
                                Picker("Ödeme Döngüsü", selection: $billingCycle) {
                                    ForEach(billingOptions, id: \.self) {
                                        Text($0)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                            }
                            
                            // Takvim
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Sonraki Ödeme Tarihi")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textDark)
                                
                                DatePicker("", selection: $nextBillingDate, displayedComponents: .date)
                                    .datePickerStyle(GraphicalDatePickerStyle())
                                    .accentColor(selectedColor)
                                    .background(AppColors.cardDark)
                                    .cornerRadius(12)
                            }
                        }
                        .padding()
                        .background(AppColors.cardDark)
                        .cornerRadius(12)
                    }
                    .padding()
                }
            }
            .navigationTitle("Yeni Abonelik")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        isPresented = false
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        guard let amountValue = Double(amount) else { return }
                        
                        let newSubscription = Subscription(
                            name: name,
                            amount: amountValue,
                            billingCycle: billingCycle,
                            nextBillingDate: nextBillingDate,
                            icon: selectedIcon,
                            color: selectedColor
                        )
                        
                        subscriptions.append(newSubscription)
                        isPresented = false
                    }
                    .foregroundColor(.white)
                    .disabled(name.isEmpty || amount.isEmpty)
                }
            }
        }
    }
}

struct FormField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(AppColors.textDark)
            
            TextField(placeholder, text: $text)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .foregroundColor(AppColors.textDark)
        }
    }
}

#Preview {
    NavigationView {
        SubscriptionsView()
    }
} 
