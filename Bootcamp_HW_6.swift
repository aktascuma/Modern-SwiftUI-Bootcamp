//
//  ContentView.swift
//  Bootcamp_HW_6
//
//  Created by Cuma Aktaş on 9.09.2025.
//

import SwiftUI

struct Bootcamp_HW_6: View {
    
    @StateObject var viewModel = TasksViewModel()
    @State private var showingAddSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.tasks.isEmpty {
                    ContentUnavailableView("Add New Task",
                        systemImage: "plus",
                        description: Text("Use the Plus button to add your first task")
                    )
                } else {
                    List {
                        ForEach(viewModel.tasks) { task in
                            HStack {
                                Button {
                                    viewModel.toggleTask(task)
                                } label: {
                                    Image(systemName: task.isCompleted ? "checkmark.square.fill" : "square")
                                }
                                .buttonStyle(.plain)
                                
                                Text(task.title)
                                    .strikethrough(task.isCompleted, color: .black)
                                    .foregroundColor(task.isCompleted ? .gray : .primary)
                            }
                        }
                        .onDelete(perform: viewModel.deleteTask)
                    }
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                Button {
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddTaskView(viewModel: viewModel, isPresented: $showingAddSheet)
            }
        }
    }
}

#Preview {
    Bootcamp_HW_6()
}



class TasksViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    
    
    func addTask(withTitle title: String) {
        tasks.append(Task(title: title))
    }
    
    func deleteTask(at indexSet: IndexSet) {
        tasks.remove(atOffsets: indexSet)
    }
    
    func toggleTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            
            if tasks[index].isCompleted {
                let completedTask = tasks.remove(at: index)
                tasks.append(completedTask)
            }
        }
    }
}


struct Task: Identifiable {
    var id: UUID = UUID()
    var title: String
    var isCompleted: Bool = false
}


struct AddTaskView: View {
    @ObservedObject var viewModel: TasksViewModel
    @Binding var isPresented: Bool
    @State private var taskTitle: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Enter task title", text: $taskTitle)
            }
            .navigationTitle("New Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if !taskTitle.isEmpty {
                            viewModel.addTask(withTitle: taskTitle)
                            isPresented = false
                        }
                    }
                }
            }
        }
    }
}
