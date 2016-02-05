#!/usr/bin/env ruby
#
require 'net/http'
require 'uri'
require 'open-uri'
require 'json'

# Codeship API access token (https://codeship.com/user/edit)
CODESHIP_ACCESS_TOKEN=''

# ID for your Codeship project
CODESHIP_PROJECT_ID=''

CODESHIP_BASE_URL = 'https://codeship.com'
CODESHIP_PROJECTS_API = "#{CODESHIP_BASE_URL}/api/v1/projects/#{CODESHIP_PROJECT_ID}.json?api_key=#{CODESHIP_ACCESS_TOKEN}"
CODESHIP_BUILD_URL = "#{CODESHIP_BASE_URL}/projects/#{CODESHIP_PROJECT_ID}/builds/"

LINE_SEPERATOR = 'ꞁ'
INDICATOR = '★'
ANCHOR = '⚓'
SUCCESS = 'success'
WAITING = 'waiting'
TESTING = 'testing'
ERROR = 'error'
STATUSES = [ERROR, SUCCESS, TESTING, WAITING]
STATUS_COLORS = { SUCCESS => '#60CC69', WAITING => '#5A95E5', TESTING => '#5A95E5', ERROR => '#FE402C' }
STATUS_ICON = { SUCCESS => '✔', WAITING => '⌛', TESTING => '⟳', ERROR => '✗' }

def get_builds
  response = Net::HTTP.get_response(URI.parse(CODESHIP_PROJECTS_API))
  data = JSON.parse(response.body)
  data['builds']
end

def format_output(data_list)
  data_list.each do |data|
    short_message = data['message']
    short_message = "#{short_message[0..27]}..." if short_message.size >= 30
    parts = [data['github_username'] || '???', data['branch'] || '??? branch ???', short_message]
    puts "#{STATUS_ICON[data['status']]} #{parts.join(" #{LINE_SEPERATOR} ")} | color=#{STATUS_COLORS[data['status']]} href=#{CODESHIP_BUILD_URL}#{data['id']}"
  end
end

def separator
  puts '---'
end

def overall_status(data_list)
  status = 'All Good'
  if data_list.any?{ |data| data['status'] != SUCCESS}
    status_parts = Hash.new(0)
    data_list.each{ |data| status_parts[data['status']] += 1 }
    output = []
    STATUSES.each do |status|
    	count = status_parts[status]
    	output << "#{count}#{STATUS_ICON[status]}" if count > 0
    end
    status = output.join(' ')
  end
  puts "#{ANCHOR} #{status}"
end

begin
  builds = get_builds
  overall_status(builds)
  separator
  format_output(builds)
end
