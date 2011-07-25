#!/usr/bin/env ruby
require 'webkit'
require 'yaml'

insert = false
search = ""
history = File.join(ENV['HOME'],".br","history")
bookmark = File.join(ENV['HOME'],".br","bookmark")

def full_uri(args)
  #searchengine="http://www.google.com/search?q="
  searchengine="https://encrypted.google.com/search?q="
  #searchengine="http://www.google.com/webhp?hl=all&q="
  #searchengine = "http://ixquick.com/do/metasearch.pl?query="
  #searchengine = "https://ssl.scroogle.org/cgi-bin/nbbwssl.cgi?Gw="
  if args.is_a? Array
    if args.size == 1
      uri = args.first
    else
      uri = searchengine+args.join("+")
    end
  else
    uri = args
  end
  unless uri =~ /^http|^file/ or uri.empty?
    if uri =~ /\./
      uri = "http://"+uri
    elsif File.exists?(uri)
      uri = "file://"+uri
    else
      uri = searchengine+uri.gsub(/\s+/,"+")
    end
  end
  uri
end

clipboard = Gtk::Clipboard.get(Gdk::Selection::CLIPBOARD)
sw = Gtk::ScrolledWindow.new(nil, nil)
wv = Gtk::WebKit::WebView.new
wv.settings.enable_page_cache=true
sw.add wv
win = Gtk::Window.new
win.add(sw)

win.signal_connect("key-press-event") do |w,e|
  if Gdk::Keyval.to_name(e.keyval) == "Escape"
    insert = false
    wv.stop_loading
  end
  unless insert
    case Gdk::Keyval.to_name(e.keyval)
    when "b"
      wv.open File.read(bookmark).chomp# unless bookmark.empty?
    when "m"
      `echo "#{wv.get_uri}" > #{bookmark} `
    when "P"
      wv.execute_script("window.print();")
    when "g"
      sw.vadjustment.value = 0
    when "G"
      sw.vadjustment.value = sw.vadjustment.upper - sw.vadjustment.page_size
    when "j"
      sw.vadjustment.value = [sw.vadjustment.upper - sw.vadjustment.page_size,sw.vadjustment.value + sw.vadjustment.step_increment].min
    when "k"
      sw.vadjustment.value = [0,sw.vadjustment.value - sw.vadjustment.step_increment].max
    when "s"
      Process.spawn("wget -O /tmp/br-source.html #{wv.get_uri} && xterm -e \"vim -c 'set filetype=html' /tmp/br-source.html\" &")
    when "f"
      wv.execute_script(File.read(File.join(File.dirname(__FILE__),"link-hinting.js"))+"\nhintMode();")
    when "F"
      wv.execute_script(File.read(File.join(File.dirname(__FILE__),"link-hinting.js"))+"\nhintMode(true);")
    when "i"
      insert = true
    when "r"
      wv.reload
    when "y"
      clipboard.text = wv.get_uri
      clipboard.store
    when "p"
      wv.open full_uri(clipboard.wait_for_text)
    when "o"
      wv.open full_uri(`sort #{history}|uniq -c |sort -nr| grep -v "^ \+1 "|sed 's/^ *[0-9]* //'|dmenu -b -l 10`)
    when "h"
      wv.go_back
    when "l"
      wv.go_forward
    when "slash"
      search = `echo "#{search}"| dmenu -b`
      wv.search_text search,false,"forward",true
    when "n"
      wv.search_text search,false,"forward",true
    when "q"
      Gtk.main_quit
    else
      #wv.load_html_string(Gdk::Keyval.to_name(e.keyval), "file:///")
    end
  end
  #if insert
    #win.border_width = 2
    #win.modify_bg(Gtk::STATE_NORMAL,Gdk::Color.parse("yellow"))
  #end
end

win.signal_connect("destroy") { Gtk.main_quit }

# receive javascript messages (borrowed from vimpropable)
wv.signal_connect("console-message") do |w,message|
  case message
  when "insertmode_on"
    insert = true
  when "insertmode_off"
    insert = false
  end
end

wv.signal_connect("download-requested") do |w,download|
  file = download.suggested_filename
  file = "br_download" if file.empty?
  download.set_destination_uri(File.join("file://",ENV['HOME'],file))
end

wv.signal_connect("create-web-view") do |w,f,d| 
  wv.open wv.get_uri # do not open a new window
end

wv.signal_connect("document-load-finished") do |w|
  insert = false
  last = `tail -n 1 #{history}`.chomp
  if wv.get_uri =~ /^https:\/\// 
    win.border_width = 2
    win.modify_bg(Gtk::STATE_NORMAL,Gdk::Color.parse("green"))
  else 
    win.border_width = 0
    win.modify_bg(Gtk::STATE_NORMAL,Gdk::Color.parse("grey"))
  end
  wv.execute_script(File.read(File.join(File.dirname(__FILE__),"input-focus.js")))
  File.open(history, "a+"){|f| f.puts wv.get_uri} if wv.get_uri and !wv.get_uri.empty? and wv.get_uri != last
end

wv.signal_connect("mime-type-policy-decision-requested") do |w,f,r,mime,decision|
  if mime =~ /html/
    false
  else
    `cd $HOME && wget #{r.uri}`
    Process.spawn("zathura #{File.join(ENV["HOME"],File.basename(r.uri))}") if mime =~ /pdf/
    wv.open wv.get_uri # do not open a new window
    true
  end
end

if ARGV.empty?
  wv.load_html_string(ARGF.read)
else
  wv.open full_uri(ARGV)
end
win.show_all
Gtk.main
