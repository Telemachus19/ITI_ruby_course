
require 'time'

module Logger
	def log(level_of_log, message)
		timestamp = Time.now.iso8601
		File.open('app.log', 'a') do |f|
			f.puts "#{timestamp} -- #{level_of_log} -- #{message}"
		end
	end

	def log_info(message)
		log('info', message)
	end

	def log_warning(message)
		log('warning', message)
	end

	def log_error(message)
		log('error', message)
	end
end

class User
	attr_reader :name, :balance

	def initialize(name, balance)
		@name = name
		@balance = balance
	end
    # following convention
	def change_balance!(amount)
		new_balance = @balance + amount
		if new_balance < 0
			raise 'Not enough balance'
		end
		@balance = new_balance
	end
end

class Transaction
	attr_reader :user, :value

	def initialize(user, value)
		@user = user
		@value = value
		freeze
	end

	def to_string
		"User #{user.name} transaction with value #{value}"
	end
end

# Useless 
class Bank
	def process_transactions(transactions)
		raise 'process_transactions must be implemented in subclass'
	end
end

#the bank form the example
class CBABank < Bank
	include Logger

	def initialize(users)
		@users = users
	end

	def process_transactions(transactions, &callback)
		map_proc = proc { |arr| arr.map { &:to_string } }
		tx_desc = map_proc.call(transactions).join(', ')
		log_info("Processing Transactions #{tx_desc}...")

		transactions.each do |t|
			begin
				unless @users.include?(t.user)
					raise "#{t.user.name} not exist in the bank!!"
				end

				t.user.change_balance!(t.value)
				log_info("#{t.to_string} succeeded")
				if t.user.balance == 0
					log_warning("#{t.user.name} has 0 balance")
				end
				if callback	
					callback.call(:success, t)
				end
			rescue => e
				log_error("#{t.to_string} failed with message #{e.message}")
				if callback
					callback.call(:failure, t, e)
				end
			end
		end
	end
end

users = [
	User.new('John Doe', 200),
	User.new('Jane Doe', 500),
	User.new('Tom Smith', 100)
]

out_side_bank_users = [
	User.new('Menna', 400)
]

transactions = [
	Transaction.new(users[0], -20),
	Transaction.new(users[0], -30),
	Transaction.new(users[0], -50),
	Transaction.new(users[0], -100),
	Transaction.new(users[0], -100),
	Transaction.new(out_side_bank_users[0], -100)
]

bank = CBABank.new(users)

bank.process_transactions(transactions) do |status, transaction, error|
	if status == :success
		puts "Call endpoint for success of #{transaction.to_string}"
	else
		puts "Call endpoint for failure of #{transaction.to_string} with reason #{error.message}"
	end
end
