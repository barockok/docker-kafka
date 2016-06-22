#!/usr/bin/env ruby
require '/ruby-processcli-helper.rb'
$kafka_pid = nil
$kafka_port = 9091
CONFLUENT_HOME = '/confluent-2.0.0'

def advertised_host
  return @_advertised_host if @_advertised_host
  default_command = "sed -n 's/^\([0-9\.]*\)[[:blank:]]*[0-9a-f]\{12,\}$/\1/p' /etc/hosts"
  command = ENV['ADVERTISED_HOST_COMMAND'] ? ENV['ADVERTISED_HOST_COMMAND'] : default_command
  if ENV['ADVERTISED_HOST_COMMAND']
    @_advertised_host = `#{ENV['ADVERTISED_HOST_COMMAND']}`
  else
    @_advertised_host = File.read('/etc/hosts').split("\n").last.match(/(\d{,3}.\d{,3}.\d{,3}.\d{,3})/)[0]
  end
end

def extend_conf
  content = ''
  content +="advertised.host.name=#{advertised_host}\n" if advertised_host

  ENV.each do |key, val|
    if key =~ /^KAFKA__/
      content += "#{key.gsub(/KAFKA__/, '').gsub('_', '.').downcase}=#{val}\n"
    end
  end

  content +="port=#{$kafka_port}\n"
  content +="listeners=PLAINTEXT://:#{$kafka_port}\n"
  content
end

def start_service
  puts "-> extending configuration"
  conf_path = File.join(CONFLUENT_HOME, 'etc', 'kafka', 'server.properties')
  IO.write(conf_path, extend_conf , mode: 'a' )
  puts "-> starting kafka"
  $kafka_pid = running_daemon "#{CONFLUENT_HOME}/bin/kafka-server-start #{conf_path}"
  check_socket_live 'localhost', $kafka_port, 30
  puts "-> kafka started"
end

def stop_service
  puts "-> stopping kafka"
  kill_process $kafka_pid
  puts "-> kafka stopped"
end

def signal_handler sig
  raise Interrupt
end

include Helper::ProcessCLI

add_stop_exception Interrupt, Errno::ECONNREFUSED
run!


