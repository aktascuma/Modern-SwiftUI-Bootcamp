//
//  ContentView.swift
//  Bootcamp_HW_7
//
//  Created by Cuma Aktaş on 24.09.2025.

import SwiftUI
import Combine

// MARK: - Event Türleri
enum EventType: String, CaseIterable, Codable, Identifiable, Hashable {
    case birthday = "Birthday"
    case meeting  = "Meeting"
    case holiday  = "Holiday"
    case sport    = "Sport"
    case other    = "Other"
    
    var id: String { rawValue }
}

// MARK: - Event Model
struct Event: Identifiable, Codable, Equatable, Hashable {
    var id: UUID = UUID()
    var title: String
    var date: Date
    var type: EventType
    var hasReminder: Bool
    
    func formattedDateString() -> String {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.timeStyle = .short
        return fmt.string(from: date)
    }
}

// MARK: - ViewModel
final class EventViewModel: ObservableObject {
    @Published private(set) var events: [Event] = []
    
    private let storageKey = "events_storage_v1"
    
    init(loadSampleDataIfEmpty: Bool = true) {
        load()
        if events.isEmpty && loadSampleDataIfEmpty {
            loadSampleData()
        }
    }
    
    func addEvent(title: String, date: Date, type: EventType, hasReminder: Bool) {
        let new = Event(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            date: date,
            type: type,
            hasReminder: hasReminder
        )
        events.append(new)
        sortEvents()
        save()
    }
    
    func deleteEvent(_ event: Event) {
        if let idx = events.firstIndex(of: event) {
            events.remove(at: idx)
            save()
        }
    }
    
    func deleteEvent(id: UUID) {
        events.removeAll { $0.id == id }
        save()
    }
    
    func updateEvent(_ event: Event) {
        guard let idx = events.firstIndex(where: { $0.id == event.id }) else { return }
        events[idx] = event
        sortEvents()
        save()
    }
    
    func toggleReminder(for event: Event) {
        guard var e = events.first(where: { $0.id == event.id }) else { return }
        e.hasReminder.toggle()
        updateEvent(e)
    }
    
    private func sortEvents() {
        events.sort { $0.date < $1.date }
    }
    
    private func save() {
        do {
            let data = try JSONEncoder().encode(events)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Events save error:", error)
        }
    }
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            let decoded = try JSONDecoder().decode([Event].self, from: data)
            self.events = decoded
            sortEvents()
        } catch {
            print("Events load error:", error)
        }
    }
    
    private func loadSampleData() {
        let now = Date()
        addEvent(title: "Cuma's Birthday",
                 date: Calendar.current.date(byAdding: .day, value: 2, to: now) ?? now,
                 type: .birthday,
                 hasReminder: true)
        addEvent(title: "Team Meeting",
                 date: Calendar.current.date(byAdding: .day, value: 1, to: now) ?? now,
                 type: .meeting,
                 hasReminder: false)
        addEvent(title: "Weekend Match",
                 date: Calendar.current.date(byAdding: .day, value: 7, to: now) ?? now,
                 type: .sport,
                 hasReminder: true)
    }
}



// MARK: - Event List View
struct Bootcamp_HW_7: View {
    @EnvironmentObject var viewModel: EventViewModel
    @State private var showingAddSheet: Bool = false
    @State private var searchText: String = ""
    
    var filteredEvents: [Event] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return viewModel.events
        } else {
            let lower = searchText.lowercased()
            return viewModel.events.filter {
                $0.title.lowercased().contains(lower) ||
                $0.type.rawValue.lowercased().contains(lower)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if filteredEvents.isEmpty {
                    VStack(alignment: .center) {
                        Text("There is no event yet.")
                            .foregroundColor(.secondary)
                        Text("Tap the + button to add a new item")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
                } else {
                    ForEach(filteredEvents) { event in
                        NavigationLink(value: event) {
                            EventRowView(event: event)
                        }
                    }
                    .onDelete(perform: delete(at:))
                }
            }
            .navigationTitle("Event")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            .searchable(text: $searchText, prompt: "Search Events with type or title")
            .sheet(isPresented: $showingAddSheet) {
                AddEventView(isPresented: $showingAddSheet)
                    .environmentObject(viewModel)
            }
            .navigationDestination(for: Event.self) { event in
                EventDetailView(event: event)
                    .environmentObject(viewModel)
            }
        }
    }
    
    private func delete(at offsets: IndexSet) {
        let idsToDelete = offsets.compactMap { index -> UUID? in
            guard index < filteredEvents.count else { return nil }
            return filteredEvents[index].id
        }
        for id in idsToDelete {
            viewModel.deleteEvent(id: id)
        }
    }
}

// MARK: - Row
struct EventRowView: View {
    let event: Event
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                Text("\(event.formattedDateString()) • \(event.type.rawValue)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if event.hasReminder {
                Image(systemName: "bell.fill")
                    .imageScale(.small)
                    .foregroundColor(.accentColor)
            }
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Add Event
struct AddEventView: View {
    @EnvironmentObject var viewModel: EventViewModel
    @Binding var isPresented: Bool
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var date: Date = Date()
    @State private var type: EventType = .other
    @State private var hasReminder: Bool = false
    
    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Event Infos")) {
                    TextField("Event Title", text: $title)
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    Picker("Type", selection: $type) {
                        ForEach(EventType.allCases) { t in
                            Text(t.rawValue).tag(t)
                        }
                    }
                    Toggle("Reminder", isOn: $hasReminder)
                }
            }
            .navigationTitle("New Event")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(!isValid)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func save() {
        viewModel.addEvent(title: title, date: date, type: type, hasReminder: hasReminder)
        isPresented = false
        dismiss()
    }
}

// MARK: - Detail
struct EventDetailView: View {
    @EnvironmentObject var viewModel: EventViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var event: Event
    @State private var showingDeleteConfirmation: Bool = false
    
    init(event: Event) {
        _event = State(initialValue: event)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Title")) {
                TextField("Title", text: $event.title)
                    .onChange(of: event.title) { _ in applyChanges() }
            }
            Section(header: Text("Time")) {
                DatePicker("Date", selection: $event.date, displayedComponents: [.date, .hourAndMinute])
                    .onChange(of: event.date) { _ in applyChanges() }
            }
            Section(header: Text("Other")) {
                Picker("Type", selection: $event.type) {
                    ForEach(EventType.allCases) { t in
                        Text(t.rawValue).tag(t)
                    }
                }
                .onChange(of: event.type) { _ in applyChanges() }
                Toggle("Reminder", isOn: $event.hasReminder)
                    .onChange(of: event.hasReminder) { _ in applyChanges() }
            }
            Section {
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    Label("Delete Event", systemImage: "trash")
                }
            }
        }
        .navigationTitle("Event Details")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Are you sure to delete this event?",
                            isPresented: $showingDeleteConfirmation,
                            titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                deleteAndClose()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Deleting can't be undone.")
        }
        .onDisappear {
            applyChanges()
        }
    }
    
    private func applyChanges() {
        let trimmed = event.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        event.title = trimmed
        viewModel.updateEvent(event)
    }
    
    private func deleteAndClose() {
        viewModel.deleteEvent(event)
        dismiss()
    }
}

// MARK: - Preview
#Preview {
    let vm = EventViewModel(loadSampleDataIfEmpty: false)
    vm.addEvent(title: "Sample Event", date: Date(), type: .meeting, hasReminder: true)
    return Bootcamp_HW_7()
        .environmentObject(vm)
}
