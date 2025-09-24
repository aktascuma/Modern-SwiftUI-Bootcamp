//
//  ContentView.swift
//  Bootcamp_HW_8
//
//  Created by Cuma Aktaş on 24.09.2025.
//

import SwiftUI
import Combine

// MARK: - Model
struct Note: Identifiable, Codable, Equatable, Hashable {
    var id: UUID = UUID()
    var title: String
    var content: String
    var date: Date
}

// MARK: - ViewModel
final class NotesViewModel: ObservableObject {
    @Published private(set) var notes: [Note] = []
    
    private let storageKey = "notes_storage_v1"
    
    init() {
        load()
    }
    
    func addNote(title: String, content: String) {
        let newNote = Note(title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                           content: content.trimmingCharacters(in: .whitespacesAndNewlines),
                           date: Date())
        notes.append(newNote)
        save()
    }
    
    func deleteNote(_ note: Note) {
        if let idx = notes.firstIndex(of: note) {
            notes.remove(at: idx)
            save()
        }
    }
    
    private func save() {
        do {
            let data = try JSONEncoder().encode(notes)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Save error:", error)
        }
    }
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            notes = try JSONDecoder().decode([Note].self, from: data)
        } catch {
            print("Load error:", error)
        }
    }
}



// MARK: - List View
struct Bootcamp_HW_8: View {
    @EnvironmentObject var viewModel: NotesViewModel
    @State private var showingAddSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                if viewModel.notes.isEmpty {
                    Text("No notes yet. Tap + to add one.")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 20)
                } else {
                    ForEach(viewModel.notes) { note in
                        NavigationLink(value: note) {
                            VStack(alignment: .leading) {
                                Text(note.title)
                                    .font(.headline)
                                Text(note.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .onDelete(perform: delete(at:))
                }
            }
            .navigationTitle("Notes")
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
            .sheet(isPresented: $showingAddSheet) {
                AddNoteView(isPresented: $showingAddSheet)
                    .environmentObject(viewModel)
            }
            .navigationDestination(for: Note.self) { note in
                NoteDetailView(note: note)
                    .environmentObject(viewModel)
            }
        }
    }
    
    private func delete(at offsets: IndexSet) {
        for index in offsets {
            let note = viewModel.notes[index]
            viewModel.deleteNote(note)
        }
    }
}

// MARK: - Add Note View
struct AddNoteView: View {
    @EnvironmentObject var viewModel: NotesViewModel
    @Binding var isPresented: Bool
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var content: String = ""
    
    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    TextField("Enter title", text: $title)
                }
                Section("Content") {
                    TextEditor(text: $content)
                        .frame(height: 200)
                }
            }
            .navigationTitle("New Note")
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
        viewModel.addNote(title: title, content: content)
        isPresented = false
        dismiss()
    }
}

// MARK: - Detail View
struct NoteDetailView: View {
    @EnvironmentObject var viewModel: NotesViewModel
    let note: Note
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(note.title)
                    .font(.largeTitle)
                    .bold()
                Text(note.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
                Divider()
                Text(note.content)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Note Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview
#Preview {
    let vm = NotesViewModel()
    vm.addNote(title: "Sample Note", content: "This is a preview note.")
    return Bootcamp_HW_8()
        .environmentObject(vm)
}
