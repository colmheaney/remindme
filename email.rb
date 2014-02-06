require 'rubygems'
require 'sinatra'
require 'data_mapper'
require 'dm-aggregates'
require 'sinatra/flash'

enable :sessions

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/email.db")

class Reminder
	include DataMapper::Resource
	property :id, Serial
	property :email, String, :required => true, :format => :email_address
	property :date, Date, :required => true, :message => "Date should be in the format dd-mm-yyyy" 
	property :content, Text
	property :repeat, Text, :required => true
	property :created_at, DateTime
	property :updated_at, DateTime
end

DataMapper.finalize.auto_upgrade!

class Sinatra::Application

	get '/' do
		@reminders = Reminder.all :order => :id.desc
		@title = 'Set a reminder'
		erb :home
	end

	post '/' do
		if params[:name] != ""
			flash[:errors] = "You seem to be a bot. Go away.."
			redirect '/'
		else 
			@r = Reminder.new(:email => params[:email].downcase, :date => params[:date],
						 :content => params[:content], :created_at => Time.now, 
						 :updated_at => Time.now, :repeat => params[:repeat] )
			if @r.save
				flash[:success] = "Thanks! We'll send you your reminder on the date you requested."
				redirect '/'
			else
				flash[:errors] = @r.errors.values.map{ |e| e.to_s.gsub(/[\[\]""]/, ' ') }
				redirect '/'
			end
		end

	end

	get '/unsubscribe/:encrypted_email/:id' do
		email = Email.decrypt(params[:encrypted_email], 'qrwonjjk24aba1obr')
		id = params[:id]
		if Reminder.count(:email => email, :id => id) != 0
			Reminder.all(:email => email, :id => id).destroy
			flash[:success] = "You're reminders have been deleted. Thanks for trying the service!"
			redirect '/'
		else
			flash[:errors] = "Sorry that message doesn't exist in our database"
			redirect '/'
		end
	end
end

module Email
	
	def Email.encrypt(word, key) 
		wd = Array.new
		arr = Array.new
		i = 0 
		setKey(key, arr)
		word.each_byte do |c|
			if c == 64
				wd << 95.chr
			elsif c == 46
				wd << 45.chr
			else
				wd << (97 + (c + arr[i]) % 26).chr
			end
			i = (i + 1) % key.length
		end
		return wd.join('')
	end

	def Email.decrypt(word, key) 
		wd = Array.new
		arr = Array.new
		i = 0 
		Email.setKey(key, arr)
		word.each_byte do |c|
			if c == 95
				wd << 64.chr
			elsif c == 45
				wd << 46.chr
			else		
				wd << ((((c - 97) - arr[i] - 97) % 26) + 97).chr
			end
			i = (i + 1) % key.length
		end
		return wd.join('')
	end

	def Email.setKey(key, arr)
		key.each_byte do |c|
			arr << c
		end	
	end
end


