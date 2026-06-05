require "csv"

class Book
    attr_accessor :title, :author, :isbn, :count

    def initialize(title, author, isbn, count = 0)
        @title = title
        @author = author
        @isbn = isbn
        @count = count
    end

    def to_hash
        {
            "title" => title,
            "author" => author,
            "isbn" => isbn,
            "count" => count
        }
    end

    def self.from_hash(hash)
        new(hash["title"],hash["author"],hash["isbn"],hash["count"].to_i)
    end
end

class Inventory
    attr_reader :file_path

    def initialize(file_path)
        @file_path = file_path
        @books = []
    end

    public 
    def load_books
        unless File.exist?(file_path)
            puts "No inventory file found. Starting with an empty inventory."
        else
            CSV.foreach(file_path, headers: true) do |row|
                @books << Book.from_hash(row.to_hash)
            end
        end
    end

    def list_books
        if @books.empty?
            puts "No books in inventory."
            return
        end

        puts "Inventory:"
        @books.each do |book|
            puts "Title: #{book.title} | Author: #{book.author} | ISBN: #{book.isbn} | Count: #{book.count}"
        end
    end

    def add_book(book)
        if existing_book = find_book_by_isbn(book.isbn)
            update_book_count(book.isbn, book.count)
        else
            @books << book
        end
    end

    def save_books
        CSV.open(file_path, "w", headers: ["title", "author", "isbn", "count"], write_headers: true) do |csv|
            @books.each do |book|
                csv << book.to_hash.values
            end
        end
    end

    def remove_book_by_isbn(isbn)
        @books.reject! { |book| book.isbn == isbn}
    end

    def find_book_by_isbn(isbn)
        @books.find { |book| book.isbn == isbn }
    end

    # since there might be multiple books by the same perosn
    def find_books_by_author(author)
        @books.select { |book| book.author.downcase.include?(author.downcase) }
    end
    # kinda fuzzy
    def find_books_by_title(title)
        @books.select { |book| book.title.downcase.include?(title.downcase) }
    end

    def list_sorted_by_isbn
        @books.sort_by(&:isbn).each do |book|
            puts "Title: #{book.title} | Author: #{book.author} | ISBN: #{book.isbn} | Count: #{book.count}"
        end
    end

    private
    def update_book_count(isbn, count)
        book = find_book_by_isbn(isbn)
        book.count += count
    end

end

file_path = "books.csv"
inventory = Inventory.new(file_path)

inventory.load_books

def print_book(book)
    puts "Title: #{book.title} | Author: #{book.author} | ISBN: #{book.isbn} | Count: #{book.count}"
end

loop do
    puts "\nChoose an option:"
    puts "1) List books"
    puts "2) Add new book"
    puts "3) Remove book by ISBN"
    puts "4) Search books"
    puts "5) Exit"
    print "> "

    choice = STDIN.gets&.strip
    break unless choice

    case choice
    when "1"
        inventory.list_books
    when "2"
        print "Title: "
        title = STDIN.gets&.strip
        print "Author: "
        author = STDIN.gets&.strip
        print "ISBN: "
        isbn = STDIN.gets&.strip
        print "Count (default 1): "
        count_input = STDIN.gets&.strip

        if [title, author, isbn].any? { |v| v.nil? || v.empty? }
            puts "All fields are required."
            next
        end

        count = count_input.to_i
        count = 1 if count <= 0

        inventory.add_book(Book.new(title, author, isbn, count))
        inventory.save_books
        puts "Book added."
    when "3"
        print "ISBN to remove: "
        isbn = STDIN.gets&.strip
        if isbn.nil? || isbn.empty?
            puts "ISBN is required."
            next
        end

        inventory.remove_book_by_isbn(isbn)
        inventory.save_books
        puts "Book removed if it existed."
    when "4"
        puts "\nSearch by:"
        puts "1) Title"
        puts "2) Author"
        puts "3) ISBN"
        print "> "

        search_choice = STDIN.gets&.strip
        next if search_choice.nil?

        case search_choice
        when "1"
            print "Title query: "
            query = STDIN.gets&.strip
            if query.nil? || query.empty?
                puts "Title is required."
                next
            end

            results = inventory.find_books_by_title(query)
            if results.empty?
                puts "No books found."
            else
                results.each { |book| print_book(book) }
            end
        when "2"
            print "Author query: "
            query = STDIN.gets&.strip
            if query.nil? || query.empty?
                puts "Author is required."
                next
            end

            results = inventory.find_books_by_author(query)
            if results.empty?
                puts "No books found."
            else
                results.each { |book| print_book(book) }
            end
        when "3"
            print "ISBN: "
            isbn = STDIN.gets&.strip
            if isbn.nil? || isbn.empty?
                puts "ISBN is required."
                next
            end

            book = inventory.find_book_by_isbn(isbn)
            if book
                print_book(book)
            else
                puts "No book found."
            end
        else
            puts "Invalid choice."
        end
    when "5"
        break
    else
        puts "Invalid choice."
    end
end

