#!/usr/bin/env ruby

# <bitbar.title>Twilio Issue Monitor</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Greg Fox</bitbar.author>
# <bitbar.author.github>greg-fox</bitbar.author.github>
# <bitbar.desc>Watches for issue reports from Twilio.</bitbar.desc>
# <bitbar.dependencies>ruby</bitbar.dependencies>

require 'net/http'
require 'uri'
require 'open-uri'
require 'json'
require 'digest'

# <bitbar.settings>
# </bitbar.settings>

TWILIO_URL = 'http://gpkpyklzq55q.statuspage.io/api/v2/incidents.json'
INCIDENT_BASE_URL = 'http://status.twilio.com/incidents/'

def incident_info
  response = Net::HTTP.get_response(URI.parse(TWILIO_URL))
  JSON.parse(response.body)['incidents']
end

def format_output(incident)
  status = incident['status']
  color = status == 'resolved' ? 'green' : 'red'
  color = status == 'resolved' ? nil : 'color=red'
  size = status == 'resolved' ? 'size=10' : 'size=15'
  puts "#{status} - #{incident['name']} | #{size} #{color} href=#{INCIDENT_BASE_URL}#{incident['id']}"

  separator
end

def separator
  puts '---'
end

def overall_status(incidents)
  bad_count = incidents.count{|i| i['status'] != 'resolved'}
  color = bad_count > 0 ? 'color=red' : nil
  size = bad_count > 0 ? 'size=25' : nil
  puts "Twilio(#{bad_count}) | #{size} #{color}"
end

begin
  incidents = incident_info
  incident_hash = {}
  incidents.map{|incident| incident_hash[incident['status']] = incident}
  overall_status(incidents)
  separator
  incidents.each do |incidents|
    format_output(incidents)
  end
end
