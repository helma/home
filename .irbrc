require 'irb/completion'
ARGV.concat [ "--readline", "--prompt-mode"]
require 'irb/ext/save-history'
IRB.conf[:SAVE_HISTORY] = 100
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb-save-history"
require 'rubygems'
#require "opentox-ruby"

