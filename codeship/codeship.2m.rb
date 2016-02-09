#!/usr/bin/env ruby

# <bitbar.title>Codeship Build Monitor</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Greg Fox</bitbar.author>
# <bitbar.author.github>greg-fox</bitbar.author.github>
# <bitbar.desc>Watches builds on the Codeship server.</bitbar.desc>
# <bitbar.dependencies>ruby</bitbar.dependencies>

require 'net/http'
require 'uri'
require 'open-uri'
require 'json'
require 'digest'

# <bitbar.settings>

# Codeship API access token (https://codeship.com/user/edit)
CODESHIP_ACCESS_TOKEN=''

# ID for your Codeship project (optional - excluding this will display all projects you have access to)
CODESHIP_PROJECT_ID=''

# Your github account name (optional - including this will highlight this accounts builds)
GITHUB_ACCOUNT = ''

# </bitbar.settings>

CODESHIP_BASE_URL = 'https://codeship.com'
CODESHIP_ALL_PROJECTS_API = "#{CODESHIP_BASE_URL}/api/v1/projects.json?api_key=#{CODESHIP_ACCESS_TOKEN}"
CODESHIP_BUILDS_API = "#{CODESHIP_BASE_URL}/api/v1/builds.json?api_key=#{CODESHIP_ACCESS_TOKEN}&project_id="

LINE_SEPERATOR = 'ꞁ'
ANCHOR = '⚓'
YOUR_BUILD_INDICATOR = '☆'

SUCCESS = 'success'
WAITING = 'waiting'
TESTING = 'testing'
ERROR = 'error'
STOPPED = 'stopped'
STATUSES = [ERROR, SUCCESS, TESTING, WAITING, STOPPED]
STATUS_COLORS = { SUCCESS => '#60CC69', WAITING => '#5A95E5', TESTING => '#5A95E5', ERROR => '#FE402C', STOPPED => '#CEDBED' }
STATUS_ICON = { SUCCESS => '✔', WAITING => '⌛', TESTING => '⟳', ERROR => '✗', STOPPED => '◼' }

def build_info_for_project(all_projects)
  data = {}
  all_projects.each do |project|
    response = Net::HTTP.get_response(URI.parse("#{CODESHIP_BUILDS_API}#{project[:id]}"))
    parsed_data = JSON.parse(response.body)
    data[project[:id]] = parsed_data['builds']
  end
  data
end

def ownership_indicator(build_initiator)
	return unless GITHUB_ACCOUNT != ''
    is_own_build = build_initiator == GITHUB_ACCOUNT
    return is_own_build ? YOUR_BUILD_INDICATOR : "\UFFC3"
end

def project_color(name)
  hash = Digest::SHA256.hexdigest(name)
  r = hash[0..1]
  g = hash[2..3]
  b = hash[4..5]
  "\##{r}#{g}#{b}"
end

def build_url(project, build_id)
  "#{CODESHIP_BASE_URL}/projects/#{project[:id]}/builds/#{build_id}"
end

def format_output(project, data_list)
  puts "Project #{project[:name]} | color=#{project_color(project[:name])} size=18"
  data_list[project[:id]].each do |data|
    short_message = data['message']
    short_message = "#{short_message[0..27]}..." if short_message.size >= 30
    parts = [data['github_username'] || '???', data['branch'] || '??? branch ???', short_message]
    parts = "#{STATUS_ICON[data['status']]} #{ownership_indicator(data['github_username'])} #{parts.join(" #{LINE_SEPERATOR} ")} | color=#{STATUS_COLORS[data['status']]} href=#{build_url(project, data['id'])}"
    puts parts
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

def projects_info
  response = Net::HTTP.get_response(URI.parse(CODESHIP_ALL_PROJECTS_API))
  data = JSON.parse(response.body)
  projects = []
  data['projects'].each do |project|
    projects << {id: project['id'], name: project['repository_name']}
  end
  projects
end

def projects
  all_projects = projects_info
  all_projects = all_projects.select{ |p| p[:id] == CODESHIP_PROJECT_ID.to_i } if CODESHIP_PROJECT_ID != ''
  all_projects
end

begin
  all_projects = projects
  builds = build_info_for_project(all_projects)
  overall_status(builds.values.flatten)
  separator
  all_projects.each do |project|
    format_output(project, builds)
  end
end
