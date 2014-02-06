require 'pony'
require 'date'
require './email.rb'

namespace :emails do
	task :send do
		getRemindersForToday
	end
end

def getRemindersForToday
	r = Reminder.all(:date => Date.today)
	sendMail(r)
	setNewReminders(r)
end

def setNewReminders(r)
	r.each do |reminder|
		if reminder.repeat != 'no-repeat'
			new_reminder = Reminder.get reminder.id
			new_reminder.updated_at = Time.now
			case reminder.repeat
			when "day"
				new_reminder.date = reminder.date + 1
			when "week"
				new_reminder.date = reminder.date + 7
			when "month"
				new_reminder.date = reminder.date >> 1
			when "year"
				new_reminder.date = reminder.date >> 12
			end
			new_reminder.save		
		end	
	end
end	

def sendMail(r)
	r.each do |reminder|
		body = "#{reminder.content}\n\n\nhttp://remindme.colmheaney.com/unsubscribe/#{Email.encrypt(reminder.email, 'qrwonjjk24aba1obr')}/#{reminder.id}"
		Pony.mail({
			:from => 'remindme@colmheaney.com',
			:to => reminder.email,
			:subject =>'DO-NOT-REPLY: Email Reminder Service',
			:body => body,
			:via => :sendmail
		})		
	end
end
