//
//  main.swift
//  BookCatalog
//
//  Created by Валерия Пономарева on 07.05.2026.
//

import Foundation

enum Genre: String {
    case fantactic = "fantastic"
    case detective = "detective"
    case history = "history"
    case IT = "IT"
    case fantesy = "fantesy"
}

enum BookType {
    case paper
    case audio(duration: Double) // ассоциированное значение
}
struct Book {
    let title: String
    let author: String
    let year: Int
    let pages: Int
    let id: UUID = UUID()
    let genre: Genre
    let type: BookType
    var isAvailable: Bool
}
var books: [Book] = []

enum Command: String {
    case add = "add book"
    case delete = "delete book"
    case showAll = "show all books"
    case showAvailable = "show available book"
    case showByGenre = "show by genre"
    case toggleStatus = "toggle status"
    case exit = "exit"
}
class BookShelf {
    private(set) var books: [Book] = [] //
    
    func addBook(title: String, author: String, year: Int, pages: Int, genre: Genre, type: BookType, isAvailable: Bool) {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            print("❌ Title cannot be empty")
            return
        }
        let book = Book(    // создай экземпляр структуры Book
            title: trimmed,
            author: author,
            year: year,
            pages: pages,
            genre: genre,
            type: type,    // это значение, переданное в функцию
            isAvailable: isAvailable
        )
        books.append(book)    // добавь в массив объект
    }
    
    func showAllBooks(_ books: [Book], title: String) {
        guard !books.isEmpty else {
            print("\(title)")
            return
        }
        print("\n\(title):")
        books.enumerated().forEach { index, book in
            let emodji = book.isAvailable ? "✅" : "❌"
            print("\(index + 1). \(emodji) \"\(book.title)\"")
        }
    }
    
    func showAvailable() {
        let available = books.filter { $0.isAvailable }
        showAllBooks(available, title:  "✅ Available books")
    }
    
    func showByGenre(_ genre: Genre) {
        let filtered = books.filter { $0.genre == genre }
        showAllBooks(filtered, title: "✅ \(genre) books")
    }
    
    func  delete(at index: Int) -> Bool {
        guard books.indices.contains(index) else { return false }
        let removed = books.remove(at: index)
        print("Deleted: \"\(removed.title)\"")
        return true
    }
    func toggleStatus(at index: Int) -> Bool {
        guard books.indices.contains(index) else { return false }
        books[index].isAvailable.toggle()
        let status = books[index].isAvailable ? "✅" : "❌"
        print("🔄 Status changed to \(status): \"\(books[index].title)\"")
        return true
    }
}

// MARK: - Основная программа
let shelf = BookShelf()

print("""
Commands:
  ➕ add book
  👁️ show all books
  ✅ show available book
    show by gentre
  🔄 toggle status
  ❌ delete book
  🔄 change status
  🚪 exit
""")

while true {
    print("\n>", terminator: "")
    guard let input = readLine()?.trimmingCharacters(in: .whitespaces), !input.isEmpty else { continue }
    
    if input == "exit" {
        print("By, bro!")
        break
    }
    
    guard let command = Command(rawValue: input) else {
        print("❌ Unknown command")
        continue
    }
    
    switch command {
    case .add:
        print("📝 Enter title: ", terminator: "")
        guard let title = readLine()?.trimmingCharacters(in: .whitespaces), !title.isEmpty else {
            print("❌ Title cannot be empty")
            continue
        }
        print("📝 Enter author: ", terminator: "")
        guard let author = readLine()?.trimmingCharacters(in: .whitespaces), !author.isEmpty else {
            print("❌ Author cannot be empty")
            continue
        }
        print("📝 Enter year: ", terminator: "")
        guard let yearInput = readLine()?.trimmingCharacters(in: .whitespaces),
              let year = Int(yearInput),
              year > 0  else {
            print("❌ Year must be a positive number")
            continue
        }
        print("📝 Enter pages: ", terminator: "")
        guard let pagesInput = readLine()?.trimmingCharacters(in: .whitespaces),
              let pages = Int(pagesInput),
              pages > 0  else {
            print("❌ Pages must be a positive number")
            continue
        }
        
    case .showByGenre:
        print("""
            Genres:
              fantactic
              detective
              history
              IT
              fantesy
            """)
        
        print("Enter genre:", terminator: "")
        
        guard let genre = readLine()?.trimmingCharacters(in: .whitespaces), !genre.isEmpty else {
            print("❌ Genre cannot be empty")
            continue
        }
        
        let selectedGenre: Genre
        
        switch genre.lowercased() {
        case "fantactic": selectedGenre = .fantactic
        case "detective": selectedGenre = .detective
        case "history": selectedGenre = .history
        case "it": selectedGenre = .IT
        case "fantesy": selectedGenre = .fantesy
        default:
            print("❌ Unknown genre")
            continue
        }
        shelf.showByGenre(selectedGenre)
        
    case .delete, .toggleStatus:
        guard !shelf.books.isEmpty else {
            print("No books")
        }
        
        print(command == .delete ? "🗑️ Enter number to delete: " : "🔄 Enter number to toggle status: ", terminator: "")
        guard let input = readLine(), let index = Int(input), index >= 1 && index <= shelf.books.count else {
            print("❌ Invalid number")
            continue
        }
        
        if command == .delete {
            _ = shelf.delete(at: index - 1)
        } else {
            _ = shelf.toggleStatus(at: index - 1)
        }
    case .showAll:
        <#code#>
    case .showAvailable:
        <#code#>
    case .exit:
        <#code#>
    }
   
}
