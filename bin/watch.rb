#!/usr/bin/env ruby

require 'listen'

def dump(arr, happened)
  arr.each {|item| puts "#{happened} #{item}"}
end

listen_dir = ARGV[0] || '_output'
listener = Listen.to(listen_dir) do |modified, added, removed|
  dump(modified, 'M') if modified.any?
  dump(added,    'A') if added.any?
  dump(removed,  'D') if removed.any?
end
listener.run # not blocking, listener is a Thread
sleep
