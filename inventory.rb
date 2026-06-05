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
        unless File.exist?(file_path)
            File.write(file_path, "")
        else
            CSV.open(file_path, "w", headers: ["title", "author", "isbn", "count"], write_headers: true) do |csv|
                @books.each do |book|
                    csv << book.to_hash.values
                end
            end
        end  
    end

    def remove_book_by_isbn(isbn)
        @books.reject! { |book| book.isbn == isbn}
    end

    def find_book_by_isbn(isbn)
        @books.find { |book| book.isbn == isbn }
    end

    def find_books_by_author(author)
        @books.select { |book| book.author.downcase.include?(author.downcase) }
    end

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
inventory.add_book(Book.new("The Great Gatsby", "F. Scott Fitzgerald", "978-0743273565",1))
inventory.add_book(Book.new("To Kill a Mockingbird", "Harper Lee", "978-0061120084",1))
inventory.list_books
inventory.save_books
inventory.list_sorted_by_isbn
