#!/usr/bin/env ruby

# <bitbar.title>Honeybadger Fault Monitor</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Greg Fox</bitbar.author>
# <bitbar.author.github>greg-fox</bitbar.author.github>
# <bitbar.desc>Watches for faults in Honeybadger.</bitbar.desc>
# <bitbar.dependencies>ruby</bitbar.dependencies>

require 'net/http'
require 'uri'
require 'open-uri'
require 'json'
require 'digest'

# <bitbar.settings>

# Honeybadger API access token (https://codeship.com/user/edit)
HONEYBADGER_ACCESS_TOKEN=''
HONEYBADGER_PROJECT_ID=''

# </bitbar.settings>

HONEYBADGER_BASE_URL = 'https://app.honeybadger.io'
HONEYBADGER_FAULTS_API = "#{HONEYBADGER_BASE_URL}/v1/projects/#{HONEYBADGER_PROJECT_ID}/faults?auth_token=#{HONEYBADGER_ACCESS_TOKEN}&resolved=f&ignored=f&order=frequent"
HONEYBADGER_FAULT_URI = "#{HONEYBADGER_BASE_URL}/v1/projects/#{HONEYBADGER_PROJECT_ID}/faults/FAULT_ID?auth_token=#{HONEYBADGER_ACCESS_TOKEN}"



begin

end
