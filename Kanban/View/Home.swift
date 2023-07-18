//
//  Home.swift
//  Kanban
//
//  Created by Bilal SIMSEK on 18.07.2023.
//

import SwiftUI

struct Home: View {
    @State private var todo:[Task] = [
        .init(title: "Edit video", status: .todo)
    ]
    @State private var working:[Task] = [
        .init(title: "Record video", status: .working)
    ]
    @State private var completed:[Task] = [
        .init(title: "Implement Drag and Drop", status: .completed),
        .init(title: "Update App", status: .completed),
        .init(title: "Check Results", status: .completed)
    ]
    @State private var currentlyDragging:Task?
    
    var body: some View {
        HStack(spacing: 2, content: {
            TodoView()
            WorkingView()
            CompletedView()
        })
    }
    
    @ViewBuilder
    func TasksView(_ tasks:[Task])->some View{
        VStack(alignment: .leading, spacing: 10, content: {
            ForEach(tasks) { task in
                GeometryReader{
                    TaskRow(task, $0.size)
                }
                .frame(height: 45)
            }
        })
    }
    
    @ViewBuilder
    func TaskRow(_ task:Task,_ size:CGSize)->some View{
        Text(task.title)
            .font(.callout)
            .padding(.horizontal,15)
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,alignment: .leading)
            .frame(height: size.height)
            .background(.white,in:.rect(cornerRadius: 10))
            .contentShape(.dragPreview,.rect(cornerRadius: 10))
            .padding(.horizontal,5)
            .draggable(task.id.uuidString) {
                Text(task.title)
                    .font(.callout)
                    .padding(.horizontal,15)
                    .frame(width: size.width,height: size.height,alignment: .leading)
                    .frame(height: size.height)
                    .background(.white)
                    .contentShape(.dragPreview,.rect(cornerRadius: 10))
                    .padding(.horizontal,5)
                    .onAppear(perform: {
                        currentlyDragging = task
                    })
            }
            .dropDestination(for:String.self) { items, location in
                currentlyDragging = nil
                return false
            } isTargeted:{ status in
                if let currentlyDragging, status, currentlyDragging.id != task.id{
                    withAnimation(.snappy) {
                        appendTask(task.status)
                        switch task.status {
                        case .todo:
                            replaceItem(tasks: &todo, droppingTask: task, status: .todo)
                        case .working:
                            replaceItem(tasks: &working, droppingTask: task, status: .working)
                        case .completed:
                            replaceItem(tasks: &completed, droppingTask: task, status: .completed)
                        }
                    }
                  
                   
                }
            }
    }
    
    
    
    //Append task and remove from one list to other
    
    func appendTask(_ status: Status){
        if let currentlyDragging{
            switch status {
            case .todo:
                if let task = drag(todo,status){
                    todo.append(task)
                    working.removeAll(where: {$0.id == currentlyDragging.id})
                    completed.removeAll(where: {$0.id == currentlyDragging.id})
                }
            case .working:
                if let task = drag(working,status){
                    working.append(task)
                    todo.removeAll(where: {$0.id == currentlyDragging.id})
                    completed.removeAll(where: {$0.id == currentlyDragging.id})
                }
            case .completed:
                if let task = drag(completed,status){
                    completed.append(task)
                    working.removeAll(where: {$0.id == currentlyDragging.id})
                    todo.removeAll(where: {$0.id == currentlyDragging.id})
                }
            }
        }
    }
    
    
    func drag(_ list:[Task],_ status:Status)->Task?{
        
        if !list.contains(where: {$0.id == currentlyDragging!.id}){
            var updatedTask = currentlyDragging
            updatedTask?.status = status
            return updatedTask
        }
        return nil
    }
    
    // Replace Items within the list
    
    func replaceItem(tasks: inout [Task], droppingTask:Task, status:Status){
        if let currentlyDragging{
            if let sourceIndex = tasks.firstIndex(where:{$0.id == currentlyDragging.id}),
               let destinaounIndex = tasks.firstIndex(where: { $0.id == droppingTask.id }){
                var sourceItem = tasks.remove(at: sourceIndex)
                sourceItem.status = status
                tasks.insert(sourceItem, at: destinaounIndex)
            }
               
        }
    }
    
    
    @ViewBuilder
    func TodoView()->some View{
        NavigationStack{
            ScrollView {
                    TasksView(todo)
            } .navigationTitle("TODO")
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
                .contentShape(.rect)
                .dropDestination(for: String.self) { items, location in
                    withAnimation(.snappy) {
                        appendTask(.todo)
                    }
                    return true
                } isTargeted: { _ in
                    
                }

        }
       
    }
    
    @ViewBuilder
    func WorkingView()->some View{
        NavigationStack{
            ScrollView {
                TasksView(working)
            }.navigationTitle("WORKING")
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
                .contentShape(.rect)
                .dropDestination(for: String.self) { items, location in
                    withAnimation(.snappy) {
                        appendTask(.working)
                    }
                    return true
                } isTargeted: { _ in
                    
                }

        }
    }
    
    @ViewBuilder
    func CompletedView()->some View{
        NavigationStack{
            ScrollView {
                TasksView(completed)
            }.navigationTitle("COMPLETED")
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
                .contentShape(.rect)
                .dropDestination(for: String.self) { items, location in
                    withAnimation(.snappy) {
                        appendTask(.completed)
                    }
                    return true
                } isTargeted: { _ in
                    
                }

        }
    }
}

#Preview {
    ContentView()
}
