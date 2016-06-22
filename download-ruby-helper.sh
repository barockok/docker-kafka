#!/usr/bin/env ruby
require('net/http')
require('uri')
URL = "https://gist.githubusercontent.com/barock19/0e622824bf1d90aa87d78cc8b307f46b/raw/3890b78d4a85c2df82ac6a197e0faebdfe5863b6/helper_process_cli.rb"
puts Net::HTTP.get(URI(URL))