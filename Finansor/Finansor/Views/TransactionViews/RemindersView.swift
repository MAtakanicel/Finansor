import SwiftUI

struct Reminder: Identifiable {
    var id = UUID()
    var title: String
    var amount: Double?
    var dueDate: Date
    var notes: String
    var priority: ReminderPriority
    var isCompleted: Bool
    var category: ReminderCategory
    var notificationEnabled: Bool
    var reminderType: ReminderType
}

enum ReminderPriority: String, CaseIterable, Identifiable {
    case low = "Düşük"
    case medium = "Orta"
    case high = "Yüksek"
    
    var id: String { self.rawValue }
    
    var color: Color {
        switch self {
        case .low:
            return .blue
        case .medium:
            return AppColors.accentYellow
        case .high:
            return AppColors.expense
        }
    }
}

enum ReminderCategory: String, CaseIterable, Identifiable {
    case bill = "Fatura"
    case subscription = "Abonelik"
    case loan = "Kredi"
    case saving = "Birikim"
    case other = "Diğer"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .bill:
            return "doc.text.fill"
        case .subscription:
            return "repeat.circle.fill"
        case .loan:
            return "banknote.fill"
        case .saving:
            return "dollarsign.circle.fill"
        case .other:
            return "bell.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .bill:
            return .orange
        case .subscription:
            return .purple
        case .loan:
            return AppColors.expense
        case .saving:
            return AppColors.income
        case .other:
            return .gray
        }
    }
}

enum ReminderType: String, CaseIterable, Identifiable {
    case oneTime = "Tek Seferlik"
    case recurring = "Düzenli"
    
    var id: String { self.rawValue }
}

struct RemindersView: View {
    @State private var reminders: [Reminder] = [
        Reminder(
            title: "Elektrik Faturası Ödeme",
            amount: 250.75,
            dueDate: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
            notes: "",
            priority: .high,
            isCompleted: false,
            category: .bill,
            notificationEnabled: true,
            reminderType: .recurring
        ),
        Reminder(
            title: "Netflix Yenileme",
            amount: 149.99,
            dueDate: Calendar.current.date(byAdding: .day, value: 8, to: Date())!,
            notes: "",
            priority: .medium,
            isCompleted: false,
            category: .subscription,
            notificationEnabled: true,
            reminderType: .recurring
        ),
        Reminder(
            title: "Araba Kredisi Taksiti",
            amount: 35000,
            dueDate: Calendar.current.date(byAdding: .day, value: 12, to: Date())!,
            notes: "",
            priority: .high,
            isCompleted: false,
            category: .loan,
            notificationEnabled: true,
            reminderType: .recurring
        ),
        Reminder(
            title: "Aylık Birikim",
            amount: 1500,
            dueDate: Calendar.current.date(byAdding: .day, value: 15, to: Date())!,
            notes: "Tatil için birikim",
            priority: .medium,
            isCompleted: false,
            category: .saving,
            notificationEnabled: false,
            reminderType: .recurring
        )
    ]
    
    @State private var selectedFilter: ReminderFilter = .upcoming
    @State private var showingAddReminder = false
    @State private var reminderToEdit: Reminder? = nil
    @State private var showingDeleteAlert = false
    @State private var reminderToDelete: Reminder? = nil
    
    var body: some View {
        ZStack {
            AppColors.backgroundDark.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Sabit Bölge
                VStack(spacing: 15) {
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Yaklaşan")
                                .font(.caption)
                                .foregroundColor(AppColors.secondaryTextDark)
                            
                            Text("\(upcomingCount)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.textDark)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .center, spacing: 5) {
                            Text("Bugün")
                                .font(.caption)
                                .foregroundColor(AppColors.secondaryTextDark)
                            
                            Text("\(todayCount)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.accentYellow)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 5) {
                            Text("Tamamlanan")
                                .font(.caption)
                                .foregroundColor(AppColors.secondaryTextDark)
                            
                            Text("\(completedCount)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.income)
                        }
                    }
                    
                    //En yakın Hatırlatıcı
                    if let nextReminder = upcomingReminders.first {
                        Divider().background(Color.gray.opacity(0.3))
                        
                        
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(AppColors.accentYellow)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(nextReminder.title)
                                    .font(.subheadline)
                                    .foregroundColor(AppColors.textDark)
                                
                                if let amount = nextReminder.amount {
                                    Text("₺\(String(format: "%.2f", amount))")
                                        .font(.caption)
                                        .foregroundColor(AppColors.secondaryTextDark)
                                }
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(formatDate(nextReminder.dueDate))
                                    .font(.caption)
                                    .foregroundColor(AppColors.secondaryTextDark)
                                
                                Text("\(daysUntil(nextReminder.dueDate)) gün kaldı")
                                    .font(.caption)
                                    .foregroundColor(
                                        daysUntil(nextReminder.dueDate) <= 1
                                            ? AppColors.expense
                                            : AppColors.secondaryTextDark
                                    )
                            }
                        }
                    }
                }
                .padding()
                .background(AppColors.cardDark)
                
                // Fİltreleme
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(ReminderFilter.allCases, id: \.self) { filter in
                            ReminderFilterTab(filter: filter, selectedFilter: $selectedFilter)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                .background(AppColors.backgroundDark)
                
                // Hatırlatıcıların Listesi
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(filteredReminders) { reminder in
                            ReminderRow(
                                reminder: reminder,
                                onUpdate: { updatedReminder in
                                    if let index = reminders.firstIndex(where: { $0.id == updatedReminder.id }) {
                                        reminders[index] = updatedReminder
                                    }
                                },
                                onEdit: {
                                    reminderToEdit = reminder
                                },
                                onDelete: {
                                    reminderToDelete = reminder
                                    showingDeleteAlert = true
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Hatırlatıcılarım")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddReminder = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showingAddReminder) {
            AddReminderView(isPresented: $showingAddReminder, reminders: $reminders)
        }
        .sheet(item: $reminderToEdit) { reminder in
            EditReminderView(
                reminder: reminder,
                reminders: $reminders,
                isPresented: Binding(
                    get: { reminderToEdit != nil },
                    set: { if !$0 { reminderToEdit = nil } }
                )
            )
        }
        .alert("Hatırlatıcıyı Sil", isPresented: $showingDeleteAlert) {
            Button("İptal", role: .cancel) {}
            Button("Sil", role: .destructive) {
                if let reminderToDelete = reminderToDelete,
                   let index = reminders.firstIndex(where: { $0.id == reminderToDelete.id }) {
                    reminders.remove(at: index)
                }
            }
        } message: {
            if let reminder = reminderToDelete {
                Text("\(reminder.title) hatırlatıcısını silmek istediğinize emin misiniz?")
            } else {
                Text("Bu hatırlatıcıyı silmek istediğinize emin misiniz?")
            }
        }
    }
    
    var upcomingCount: Int {
        reminders.filter { !$0.isCompleted && daysUntil($0.dueDate) >= 0 }.count
    }
    
    var todayCount: Int {
        reminders.filter { !$0.isCompleted && Calendar.current.isDateInToday($0.dueDate) }.count
    }
    
    var completedCount: Int {
        reminders.filter { $0.isCompleted }.count
    }
    
    var upcomingReminders: [Reminder] {
        reminders
            .filter { !$0.isCompleted && daysUntil($0.dueDate) >= 0 }
            .sorted { daysUntil($0.dueDate) < daysUntil($1.dueDate) }
    }
    
    var filteredReminders: [Reminder] {
        switch selectedFilter {
        case .all:
            return reminders.sorted(by: { daysUntil($0.dueDate) < daysUntil($1.dueDate) })
        case .upcoming:
            return reminders
                .filter { !$0.isCompleted && daysUntil($0.dueDate) >= 0 }
                .sorted(by: { daysUntil($0.dueDate) < daysUntil($1.dueDate) })
        case .completed:
            return reminders.filter { $0.isCompleted }
        case .today:
            return reminders.filter { !$0.isCompleted && Calendar.current.isDateInToday($0.dueDate) }
        case .overdue:
            return reminders.filter { !$0.isCompleted && daysUntil($0.dueDate) < 0 }
        }
    }
    
    func daysUntil(_ date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: date)
        return components.day ?? 0
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: date)
    }
}

enum ReminderFilter: String, CaseIterable {
    case all = "Tümü"
    case upcoming = "Yaklaşan"
    case today = "Bugün"
    case overdue = "Gecikmiş"
    case completed = "Tamamlanan"
}

struct ReminderFilterTab: View {
    let filter: ReminderFilter
    @Binding var selectedFilter: ReminderFilter
    
    var body: some View {
        Button(action: {
            selectedFilter = filter
        }) {
            Text(filter.rawValue)
                .font(.subheadline)
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(selectedFilter == filter ? AppColors.accentYellow : Color.gray.opacity(0.2))
                .foregroundColor(selectedFilter == filter ? Color.black : AppColors.textDark)
                .cornerRadius(20)
        }
    }
}

struct ReminderRow: View {
    let reminder: Reminder
    let onUpdate: (Reminder) -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var isCompleted: Bool
    @State private var showingOptions = false
    
    init(reminder: Reminder, onUpdate: @escaping (Reminder) -> Void, onEdit: @escaping () -> Void, onDelete: @escaping () -> Void) {
        self.reminder = reminder
        self._isCompleted = State(initialValue: reminder.isCompleted)
        self.onUpdate = onUpdate
        self.onEdit = onEdit
        self.onDelete = onDelete
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 15) {
                //Tamamlama checkbox
                Button(action: {
                    isCompleted.toggle()
                    var updatedReminder = reminder
                    updatedReminder.isCompleted = isCompleted
                    onUpdate(updatedReminder)
                }) {
                    ZStack {
                        Circle()
                            .stroke(reminder.priority.color, lineWidth: 2)
                            .frame(width: 24, height: 24)
                        
                        if isCompleted {
                            Circle()
                                .fill(reminder.priority.color)
                                .frame(width: 16, height: 16)
                        }
                    }
                }
                
                // Kategori Icon
                ZStack {
                    Circle()
                        .fill(reminder.category.color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: reminder.category.icon)
                        .font(.system(size: 18))
                        .foregroundColor(reminder.category.color)
                }
                
                // Hatırlatıcı adı
                VStack(alignment: .leading, spacing: 4) {
                    Text(reminder.title)
                        .font(.headline)
                        .foregroundColor(isCompleted ? AppColors.secondaryTextDark : AppColors.textDark)
                        .strikethrough(isCompleted)
                    
                    HStack {
                        Text(reminder.category.rawValue)
                            .font(.caption)
                            .foregroundColor(AppColors.secondaryTextDark)
                        
                        if reminder.reminderType == .recurring {
                            Image(systemName: "arrow.2.squarepath")
                                .font(.caption)
                                .foregroundColor(AppColors.secondaryTextDark)
                        }
                        
                        if reminder.notificationEnabled {
                            Image(systemName: "bell.fill")
                                .font(.caption)
                                .foregroundColor(AppColors.accentYellow)
                        }
                    }
                }
                
                Spacer()
                
                // Miktar ve Tarih
                VStack(alignment: .trailing, spacing: 4) {
                    if let amount = reminder.amount {
                        Text("₺\(String(format: "%.2f", amount))")
                            .font(.headline)
                            .foregroundColor(isCompleted ? AppColors.secondaryTextDark : AppColors.textDark)
                            .strikethrough(isCompleted)
                    }
                    
                    Text(formatDate(reminder.dueDate))
                        .font(.caption)
                        .foregroundColor(reminderDateColor())
                }
            }
            .padding()
            .contentShape(Rectangle())
            .onTapGesture {
                showingOptions = true
            }
        }
        .background(AppColors.cardDark)
        .cornerRadius(12)
        .opacity(isCompleted ? 0.7 : 1)
        .actionSheet(isPresented: $showingOptions) {
            ActionSheet(
                title: Text(reminder.title),
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
    
    func reminderDateColor() -> Color {
        if isCompleted {
            return AppColors.income
        }
        
        let days = daysUntil(reminder.dueDate)
        if days < 0 {
            return AppColors.expense
        } else if days == 0 {
            return AppColors.accentYellow
        } else {
            return AppColors.secondaryTextDark
        }
    }
}

struct EditReminderView: View {
    let reminder: Reminder
    @Binding var reminders: [Reminder]
    @Binding var isPresented: Bool
    
    @State private var title: String
    @State private var amount: String
    @State private var dueDate: Date
    @State private var notes: String
    @State private var priority: ReminderPriority
    @State private var category: ReminderCategory
    @State private var notificationEnabled: Bool
    @State private var reminderType: ReminderType
    
    init(reminder: Reminder, reminders: Binding<[Reminder]>, isPresented: Binding<Bool>) {
        self.reminder = reminder
        self._reminders = reminders
        self._isPresented = isPresented
        
        _title = State(initialValue: reminder.title)
        _amount = State(initialValue: reminder.amount != nil ? String(format: "%.2f", reminder.amount!) : "")
        _dueDate = State(initialValue: reminder.dueDate)
        _notes = State(initialValue: reminder.notes)
        _priority = State(initialValue: reminder.priority)
        _category = State(initialValue: reminder.category)
        _notificationEnabled = State(initialValue: reminder.notificationEnabled)
        _reminderType = State(initialValue: reminder.reminderType)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.backgroundDark.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Başlok
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Başlık")
                                .font(.headline)
                                .foregroundColor(AppColors.textDark)
                            
                            TextField("Hatırlatıcı başlığı", text: $title)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .foregroundColor(AppColors.textDark)
                        }
                        
                        // Miktar
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tutar (Opsiyonel)")
                                .font(.headline)
                                .foregroundColor(AppColors.textDark)
                            
                            TextField("Ör. 250.00", text: $amount)
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .foregroundColor(AppColors.textDark)
                        }
                        
                        // Kategori ve Önceliklik
                        HStack(spacing: 15) {
                            // Kategori
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Kategori")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textDark)
                                
                                Menu {
                                    ForEach(ReminderCategory.allCases) { cat in
                                        Button(action: {
                                            category = cat
                                        }) {
                                            Label(cat.rawValue, systemImage: cat.icon)
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Label(category.rawValue, systemImage: category.icon)
                                            .foregroundColor(AppColors.textDark)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(AppColors.secondaryTextDark)
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                }
                            }
                            
                            // Öncelik
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Öncelik")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textDark)
                                
                                Menu {
                                    ForEach(ReminderPriority.allCases) { prio in
                                        Button(action: {
                                            priority = prio
                                        }) {
                                            Label(prio.rawValue, systemImage: "flag.fill")
                                                .foregroundColor(prio.color)
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Circle()
                                            .fill(priority.color)
                                            .frame(width: 10, height: 10)
                                        Text(priority.rawValue)
                                            .foregroundColor(AppColors.textDark)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(AppColors.secondaryTextDark)
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        
                        // Takvim
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tarih")
                                .font(.headline)
                                .foregroundColor(AppColors.textDark)
                            
                            DatePicker("", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .accentColor(category.color)
                                .background(AppColors.cardDark)
                                .cornerRadius(12)
                        }
                        
                        // Seçimliler
                        VStack(spacing: 10) {
                            // Tİp
                            HStack {
                                Text("Hatırlatıcı Tipi")
                                    .foregroundColor(AppColors.textDark)
                                
                                Spacer()
                                
                                Picker("", selection: $reminderType) {
                                    ForEach(ReminderType.allCases) { type in
                                        Text(type.rawValue).tag(type)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .frame(width: 200)
                            }
                            
                            Divider().background(Color.gray.opacity(0.3))
                            
                            // Bildirim opsiyonu
                            Toggle("Bildirim", isOn: $notificationEnabled)
                                .foregroundColor(AppColors.textDark)
                                .toggleStyle(SwitchToggleStyle(tint: AppColors.accentYellow))
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        
                        // Açıklaması
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notlar")
                                .font(.headline)
                                .foregroundColor(AppColors.textDark)
                            
                            TextEditor(text: $notes)
                                .frame(height: 100)
                                .padding(2)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .foregroundColor(AppColors.textDark)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Hatırlatıcıyı Düzenle")
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
                        let updatedReminder = Reminder(
                            id: reminder.id,
                            title: title,
                            amount: amount.isEmpty ? nil : Double(amount),
                            dueDate: dueDate,
                            notes: notes,
                            priority: priority,
                            isCompleted: reminder.isCompleted,
                            category: category,
                            notificationEnabled: notificationEnabled,
                            reminderType: reminderType
                        )
                        
                        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
                            reminders[index] = updatedReminder
                        }
                        
                        isPresented = false
                    }
                    .foregroundColor(.white)
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

struct AddReminderView: View {
    @Binding var isPresented: Bool
    @Binding var reminders: [Reminder]
    
    @State private var title = ""
    @State private var amount = ""
    @State private var dueDate = Date()
    @State private var notes = ""
    @State private var priority: ReminderPriority = .medium
    @State private var category: ReminderCategory = .other
    @State private var notificationEnabled = true
    @State private var reminderType: ReminderType = .oneTime
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.backgroundDark.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Hatırlatıcı başlığı
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Başlık")
                                .font(.headline)
                                .foregroundColor(AppColors.textDark)
                            
                            TextField("Hatırlatıcı başlığı", text: $title)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .foregroundColor(AppColors.textDark)
                        }
                        
                        // Miktar girişi
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tutar (Opsiyonel)")
                                .font(.headline)
                                .foregroundColor(AppColors.textDark)
                            
                            TextField("Ör. 250.00", text: $amount)
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .foregroundColor(AppColors.textDark)
                        }
                        
                        // Kategorisi & Öncelik Seviyesi
                        HStack(spacing: 15) {
                            // Kategori Seçim Butonu
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Kategori")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textDark)
                                
                                Menu {
                                    ForEach(ReminderCategory.allCases) { cat in
                                        Button(action: {
                                            category = cat
                                        }) {
                                            Label(cat.rawValue, systemImage: cat.icon)
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Label(category.rawValue, systemImage: category.icon)
                                            .foregroundColor(AppColors.textDark)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(AppColors.secondaryTextDark)
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                }
                            }
                            
                            // Önecelik Seçim Butonu
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Öncelik")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textDark)
                                
                                Menu {
                                    ForEach(ReminderPriority.allCases) { prio in
                                        Button(action: {
                                            priority = prio
                                        }) {
                                            Label(prio.rawValue, systemImage: "flag.fill")
                                                .foregroundColor(prio.color)
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Circle()
                                            .fill(priority.color)
                                            .frame(width: 10, height: 10)
                                        Text(priority.rawValue)
                                            .foregroundColor(AppColors.textDark)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(AppColors.secondaryTextDark)
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        
                        // Takvim
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tarih")
                                .font(.headline)
                                .foregroundColor(AppColors.textDark)
                            
                            DatePicker("", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .accentColor(category.color)
                                .background(AppColors.cardDark)
                                .cornerRadius(12)
                        }
                        
                        // Özellik seçimi
                        VStack(spacing: 10) {
                            // Hatırlatıcı Tipi (DÜzenli, tek seferlik)
                            HStack {
                                Text("Hatırlatıcı Tipi")
                                    .foregroundColor(AppColors.textDark)
                                
                                Spacer()
                                
                                Picker("", selection: $reminderType) {
                                    ForEach(ReminderType.allCases) { type in
                                        Text(type.rawValue).tag(type)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .frame(width: 200)
                            }
                            
                            Divider().background(Color.gray.opacity(0.3))
                            
                            // Bildirimini AÇma
                            Toggle("Bildirim", isOn: $notificationEnabled)
                                .foregroundColor(AppColors.textDark)
                                .toggleStyle(SwitchToggleStyle(tint: AppColors.accentYellow))
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        
                        // Hatırlatıcı açıklaması (notu)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Açıklama")
                                .font(.headline)
                                .foregroundColor(AppColors.textDark)
                            //Düzenlenicek
                            TextEditor(text: $notes)
                                .frame(height: 100)
                                .padding(2)
                                .background(Color.gray.opacity(0.4))
                                //.cornerRadius(10)
                                .foregroundColor(AppColors.textDark)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Yeni Hatırlatıcı")
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
                        let newReminder = Reminder(
                            title: title,
                            amount: Double(amount),
                            dueDate: dueDate,
                            notes: notes,
                            priority: priority,
                            isCompleted: false,
                            category: category,
                            notificationEnabled: notificationEnabled,
                            reminderType: reminderType
                        )
                        
                        reminders.append(newReminder)
                        isPresented = false
                    }
                    .foregroundColor(.white)
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        RemindersView()
    }
} 
