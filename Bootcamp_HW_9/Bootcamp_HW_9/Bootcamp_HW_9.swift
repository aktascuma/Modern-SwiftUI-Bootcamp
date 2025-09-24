//
//  ContentView.swift
//  Bootcamp_HW_9
//
//  Created by Cuma Aktaş on 24.09.2025.
//

import SwiftUI
import CoreData
import Combine

// MARK: - PersistenceController
class PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer
    init() {
        container = NSPersistentContainer(name: "NotesModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
    }
}

// MARK: - Note Extension
extension Note {}

extension Note {
    static func create(context: NSManagedObjectContext, title: String, content: String) {
        let note = Note(context: context)
        note.id = UUID()
        note.title = title
        note.content = content
        note.date = Date()
        try? context.save()
    }
    func update(context: NSManagedObjectContext, title: String, content: String) {
        self.title = title
        self.content = content
        self.date = Date()
        try? context.save()
    }
    func delete(context: NSManagedObjectContext) {
        context.delete(self)
        try? context.save()
    }
}

// MARK: - ViewModel
class NotesViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var content: String = ""
    func addNote(context: NSManagedObjectContext) {
        guard !title.isEmpty else { return }
        Note.create(context: context, title: title, content: content)
        title = ""
        content = ""
    }
    func update(note: Note, context: NSManagedObjectContext) {
        guard !title.isEmpty else { return }
        note.update(context: context, title: title, content: content)
    }
    func delete(note: Note, context: NSManagedObjectContext) {
        note.delete(context: context)
    }
}

// MARK: - AddNoteView
struct AddNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context
    @ObservedObject var viewModel: NotesViewModel
    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $viewModel.title)
                TextField("Content", text: $viewModel.content)
            }
            .navigationTitle("New Note")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.addNote(context: context)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - EditNoteView
struct EditNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context
    @ObservedObject var viewModel: NotesViewModel
    var note: Note
    var body: some View {
        Form {
            TextField("Title", text: $viewModel.title)
            TextField("Content", text: $viewModel.content)
        }
        .navigationTitle("Edit Note")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Update") {
                    viewModel.update(note: note, context: context)
                    dismiss()
                }
            }
        }
        .onAppear {
            viewModel.title = note.title ?? ""
            viewModel.content = note.content ?? ""
        }
    }
}

// MARK: - NotesListView
struct Bootcamp_HW_9: View {
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        entity: Note.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Note.date, ascending: false)]
    ) private var notes: FetchedResults<Note>
    @StateObject private var viewModel = NotesViewModel()
    @State private var showingAdd = false
    var body: some View {
        NavigationStack {
            List {
                ForEach(notes) { note in
                    NavigationLink(destination: EditNoteView(viewModel: viewModel, note: note)) {
                        VStack(alignment: .leading) {
                            Text(note.title ?? "")
                                .font(.headline)
                            Text(note.date ?? Date(), style: .date)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onDelete { indexSet in
                    indexSet.map { notes[$0] }.forEach { viewModel.delete(note: $0, context: context) }
                }
            }
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddNoteView(viewModel: viewModel)
            }
        }
    }
}

