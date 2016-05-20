#!/usr/bin/env ruby

# <bitbar.title>Github Assigned PR Monitor</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Greg Fox</bitbar.author>
# <bitbar.author.github>greg-fox</bitbar.author.github>
# <bitbar.desc>Watches for assigned PRs in Github.</bitbar.desc>
# <bitbar.dependencies>ruby</bitbar.dependencies>

require 'octokit'
require 'byebug'


# <bitbar.settings>

API_TOKEN = ''
REPOSITORY = ''
USER_NAMES = ''

# </bitbar.settings>

@client = Octokit::Client.new(access_token: API_TOKEN)

def pr_info
  pr_hash = {}
  REPOSITORY.split(',').each do |repo_name|
    opened_prs = []
    repo = @client.repository(repo_name)

    pages = (repo[:open_issues] / 30.0).ceil
    (1..pages).each do |page|
      options = { status: 'open', page: page, assignee: '*' }
      opened_prs << @client.pull_requests(repo_name, options)
    end
    pr_hash[repo_name] = opened_prs.flatten
  end
  pr_hash
end

def filter_assigned_prs(open_pr_hash)
  assigned_pr_hash = {}
  open_pr_hash.each do |repo_name, open_prs|
    assigned_prs = open_prs.select{ |pr| USER_NAMES.split(',').include?(pr[:assignee][:login]) if pr[:assignee] }
    assigned_pr_hash[repo_name] = assigned_prs
  end
  assigned_pr_hash
end

def separator
  puts '---'
end

def overall_status(assigned_hash)
  count = 0
  assigned_hash.each do |repo_name, assigned_list|
    count += assigned_list.size
  end
  puts "GitHub(#{count})"
end

def format_pr(repo_name, pr)
  p = @client.pull_request(repo_name, pr[:number])
  link = p[:url]
  title = p[:title]
  puts "#{repo_name} - #{title} | href=#{link}"
end

begin
  open_prs = pr_info
  assigned_prs = filter_assigned_prs(open_prs)
  overall_status(assigned_prs)
  separator

  assigned_prs.each do |repo_name, assigned_list|
    assigned_list.each do |pr|
    format_pr(repo_name, pr)
  end
  end
end
