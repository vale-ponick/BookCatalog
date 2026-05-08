//
//  main.swift
//  BookCatalog
//
//  Created by Валерия Пономарева on 07.05.2026

import Foundation

enum Genre: String { // 1️⃣ Импорты и модель данных
    case fantastic = "fantastic"  // 🔹 тип жанра с rawValue - позволяет хранить и выводить название жанра
    case detective = "detective"
    case history = "history"
    case it = "it"
    case fantasy = "fantasy"
}

enum BookType {                  // 🔹 тип книги с ассоциированным значением
    case paper
    case audio(duration: Double) // показывает, как enum может хранить данные
}

struct Book {                   // 🔹 сущность "книга" -  чистое описание данных, без логики
    let title: String
    let author: String
    let year: Int
    let pages: Int
    let id: UUID = UUID()
    let genre: Genre
    let type: BookType
    var isAvailable: Bool
}

enum Command: String { // 2️⃣ Команды пользователя
    case add = "add book"       // Raw value — строка, которую вводит user
    case delete = "delete book" // Типобезопасность (нельзя ошибиться в написании команды)
    case showAll = "show all books"
    case showAvailable = "show available book"
    case showByGenre = "show by genre"
    case toggleStatus = "toggle status"
    case exit = "exit"
}

class BookShelf { // 3️⃣ Бизнес-логика: класс BookShelf
    private(set) var books: [Book] = [] // 🔹 инкапсуляция: массив скрыт от внешнего мира
    
    func addBook(title: String, author: String, year: Int, pages: Int, genre: Genre, type: BookType, isAvailable: Bool) { // создание и добавление
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { // защита от пустого названия
            print("❌ Title cannot be empty")
            return
        }
        let book = Book(
            title: trimmed,
            author: author,
            year: year,
            pages: pages,
            genre: genre,
            type: type,
            isAvailable: isAvailable
        )
        self.books.append(book)  // self.books вместо глобального books
        print("✅ Book added successfully!")
    }
    
    func showAllBooks(_ books: [Book], title: String) { // универсальный метод печати (DRY)
        guard !books.isEmpty else {
            print("\(title)")
            return
        }
        print("\n\(title):")
        books.enumerated().forEach { index, book in
            let emoji = book.isAvailable ? "✅" : "❌"
            let typeInfo: String
            switch book.type {
            case .paper:
                typeInfo = "📖 paper"
            case .audio(let duration):
                typeInfo = "🎧 audio (\(String(format: "%.1f", duration))h)"
            }
            print("\(index + 1). \(emoji) \"\(book.title)\" by \(book.author) (\(book.year), \(book.pages)p, \(typeInfo), \(book.genre.rawValue))")
        }
    }
    
    func showAvailable() { // фильтрация
        let available = books.filter { $0.isAvailable }
        showAllBooks(available, title: "✅ Available books")
    }
    
    func showByGenre(_ genre: Genre) { // фильтрация
        let filtered = books.filter { $0.genre == genre } // функциональный стиль
        showAllBooks(filtered, title: "📚 \(genre.rawValue.capitalized) books")
    }
    
    func delete(at index: Int) -> Bool { //  работа по индексу
        guard books.indices.contains(index) else { return false } // безопасная проверка индекса
        let removed = books.remove(at: index)
        print("🗑️ Deleted: \"\(removed.title)\"")
        return true
    }
    
    func toggleStatus(at index: Int) -> Bool { //  работа по индексу
        guard books.indices.contains(index) else { return false }
        books[index].isAvailable.toggle()
        let status = books[index].isAvailable ? "✅ available" : "❌ unavailable"
        print("🔄 Status changed to \(status): \"\(books[index].title)\"")
        return true
    }
}
/* 4️⃣ Вспомогательные функции ввода
 - Вынесены для чистоты main
 - Возвращают nil при ошибке + печатают сообщение
 - Один раз написаны — много раз используются */

func selectGenre() -> Genre? {
    print("""
    📚 Genres:
      fantastic
      detective
      history
      it
      fantasy
    📝 Enter genre: 
    """, terminator: "")
    
    guard let input = readLine()?.trimmingCharacters(in: .whitespaces), !input.isEmpty else {
        print("❌ Genre cannot be empty")
        return nil
    }
    
    switch input.lowercased() {
    case "fantastic": return .fantastic
    case "detective": return .detective
    case "history": return .history
    case "it": return .it
    case "fantasy": return .fantasy
    default:
        print("❌ Unknown genre")
        return nil
    }
}
func selectBookType() -> BookType? {
    print("📖 Enter type (paper/audio): ", terminator: "")
    guard let input = readLine()?.trimmingCharacters(in: .whitespaces), !input.isEmpty else {
        print("❌ Type cannot be empty")
        return nil
    }
    
    switch input.lowercased() {
    case "paper":
        return .paper
    case "audio":
        print("🎧 Enter duration (hours): ", terminator: "")
        guard let durationInput = readLine(),
              let duration = Double(durationInput),
              duration > 0 else {
            print("❌ Invalid duration")
            return nil
        }
        return .audio(duration: duration)
    default:
        print("❌ Unknown type. Use 'paper' or 'audio'")
        return nil
    }
}
func askAvailability() -> Bool? {
    print("📌 Is available? (true/false): ", terminator: "")
    guard let input = readLine()?.lowercased(),
          let isAvailable = Bool(input) else {
        print("❌ Invalid input. Use true or false")
        return nil
    }
    return isAvailable
}
func readInt(prompt: String) -> Int? {
    print(prompt, terminator: "")
    guard let input = readLine()?.trimmingCharacters(in: .whitespaces),
          let number = Int(input),
          number > 0 else {
        return nil
    }
    return number
}

// MARK: - 5️⃣ Основная программа
let shelf = BookShelf()

print("""
Commands:
  ➕ add book
  👁️ show all books
  ✅ show available book
  📚 show by genre
  🔄 toggle status
  ❌ delete book
  🚪 exit
""")

while true {
    print("\n> ", terminator: "")
    guard let input = readLine()?.trimmingCharacters(in: .whitespaces), !input.isEmpty else { continue }
    // guard let input — безопасное чтение
    
    if input == "exit" {
        print("👋 Bye, bro!")
        break
    }
    
    guard let command = Command(rawValue: input) else { // Command(rawValue:) — преобразование строки в команду
        print("❌ Unknown command. Type 'exit' to quit.")
        continue
    }
    
    switch command { // switch — чистая обработка, каждая команда вызывает метод shelf
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
        
        guard let year = readInt(prompt: "📝 Enter year: "), year > 0 else {
            print("❌ Year must be a positive number")
            continue
        }
        guard let pages = readInt(prompt: "📝 Enter pages: "), pages > 0 else {
            print("❌ Pages must be a positive number")
            continue
        }
        
        guard let selectedGenre = selectGenre() else { continue }
        guard let selectedType = selectBookType() else { continue }
        guard let isAvailable = askAvailability() else { continue }
        
        shelf.addBook(
            title: title,
            author: author,
            year: year,
            pages: pages,
            genre: selectedGenre,
            type: selectedType,
            isAvailable: isAvailable
        )
    
    case .showAll:
        shelf.showAllBooks(shelf.books, title: "📚 All books")
        
    case .showAvailable:
        shelf.showAvailable()
        
    case .showByGenre:
        guard let selectedGenre = selectGenre() else { continue }
        shelf.showByGenre(selectedGenre)
        
    case .toggleStatus, .delete:
        guard !shelf.books.isEmpty else {
            print("📚 No books yet. Add some first!")
            continue
        }
        
        shelf.showAllBooks(shelf.books, title: "📚 Select book:")
        print(command == .delete ? "🗑️ Enter number to delete: " : "🔄 Enter number to toggle status: ", terminator: "")
        
        guard let input = readLine()?.trimmingCharacters(in: .whitespaces),
              let index = Int(input),
              index >= 1 && index <= shelf.books.count else {
            print("❌ Invalid number")
            continue
        }
        
        if command == .delete {
            _ = shelf.delete(at: index - 1)
        } else {
            _ = shelf.toggleStatus(at: index - 1)
        }
        
    case .exit:
        print("👋 Bye, bro!")
        break
    }
}
/*
 🔥 Главное — разделение на слои
 Слой          Где                                  За что отвечает
 Модели        enum Genre, BookType, struct Book    Описание данных
 Команды       enum Command                         Типобезопасные команды пользователя
 Логика        class BookShelf                      Управление данными (CRUD, фильтрация)
 Ввод/вывод    select..., read..., main.swift       Общение с user */

/*
 🔥 Архитектурные решения (и почему они крутые)
 Принцип                      Как реализовано                       Зачем
 Single Responsibility        Book — только данные,
                              BookShelf — логика,
                              main — ввод/вывод                     Каждый класс/структура отвечают за одно
 DRY (Don't Repeat Yourself)  showAllBooks универсальный,
                              selectGenre, selectBookType вынесены  Нет дублирования кода
 Типобезопасность             enum Command, enum Genre, BookType    Нельзя ошибиться в строке
 Инкапсуляция                 private(set) var books                Массив нельзя изменить напрямую
 Проверка границ              books.indices.contains(index)         Нет краша при неверном индексе
 Функциональный стиль         filter { $0.isAvailable },
                              enumerated().forEach                  Короче, читаемее
 Ранний выход                 guard let, guard !books.isEmpty       Код плоский, легко читать
 */

/*
 🔥 Самый важный принцип — разделение на слои

 user
       ↓
    main.swift      (ввод / вывод)
       ↓
    Command         (типобезопасные команды)
       ↓
    BookShelf       (бизнес-логика)
       ↓
    Book / Genre    (данные)
 Каждый слой не зависит от других.
 Если захочешь поменять ввод с консоли на GUI — поменяешь только main.swift, остальное останется.
 */
