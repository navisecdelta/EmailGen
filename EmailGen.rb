#!/usr/bin/env ruby
require "mechanize"
require "nokogiri"
require "optparse"
require "ruby-progressbar"
require "json"
require "./lib/e.rb"
require "./lib/hunter.rb"


trap("SIGINT") do
  puts("\nBye Bye, thanks for using EmailGen by Navisec Delta :)")
  exit(130)
end

ARGV << "-h" if ARGV.empty?
options = {}

optparse = OptionParser.new do |opts|

    # Set a banner, displayed at the top
    # of the help screen.
  opts.banner = "Usage: EmailGen.rb "

    # Define the options, and what they do
  options[:company] = false

  opts.on("-c", "--company \"Company, Inc\"", "Name of Company on LinkedIn") do |company|
    options[:company] = company
  end

  options[:domain] = false

  opts.on("-d", "--domain company.com", "Domain name used with Email") do |domain|
    options[:domain] = domain
  end

  options[:location] = false

  opts.on("-l", "--location New Jersey", "Location to search profiles for") do |location|
    options[:location] = location
  end

  options[:format] = false

  opts.on("-f", "--format \"{first}.{last}@{domain}\"", "Format of email") do |email_format|
    options[:format] = email_format
  end

  options[:autodetect] = false

  opts.on("-a", "--autodetect", "Auto Detect Format of email from Hunter (requires API key)") do

    options[:autodetect] = true
  end

  options[:results] = false

  opts.on("-r", "--results", "Results levels") do
    options[:results] = true
  end

  options[:outfile] = false

  opts.on("-o", "--outfile emails.txt", "File to save the results") do |outfile|
    options[:outfile] = outfile
  end

    # This displays the help screen, all programs are
    # assumed to have this option.
  opts.on("-h", "--help", "Display this screen") do
    puts(opts)
    exit
  end
end

@agent = Mechanize.new

def company_name(domain)
  company_name = ""
  search_url = "https://www.bing.com/search?q=%2Bsite%3Alinkedin.com%2Fcompany%2F%20%22#{domain}%22&qs=ds&form=QBRE"
  html = @agent.get(search_url).body
  page = Nokogiri::HTML(html)
  return page.css("li.b_algo")[0].css("h2").css("a").text.split(" | ")[0]
end

optparse.parse!

if options[:domain]
  puts(" _____                 _ _  ____\n| ____|_ __ ___   __ _(_) |/ ___| ___ _ __\n|  _| | '_ ` _ \\ / _` | | | |  _ / _ \\ '_ \\\n| |___| | | | | | (_| | | | |_| |  __/ | | |\n|_____|_| |_| |_|\\__,_|_|_|\\____|\\___|_| |_|\n\nAuthor: pry0cc | NaviSec Delta | delta.navisec.io\n    ")
  puts("[*] Initializing EmailGen...")
  load_tokens = false
  begin
    require "./tokens.rb"

    load_tokens = true
  rescue LoadError
  end

  if @hunter_key
    puts("[+] Autodetect enabled!")

    if !options[:format]
      hunter = Hunter.new(@hunter_key)
      pre_format = hunter.get_format(options[:domain])

      if pre_format
        options[:format] = pre_format + "@{domain}"
        puts("Detected format from hunter as '#{options[:format]}'")
      else
        puts("[-] Autodetection from hunter failed, please specify a format")
        exit
      end

    else
      puts("Using user-specified format as #{options[:format]}")
    end

    if !options[:company]
      company = company_name(options[:domain])

      if company
        options[:company] = company
        puts("Detected name as '#{company}'")
      else
        puts("[-] Autodetection of company name failed, please specify domain")
        exit
      end

    else
      puts("Using user-specified company name as #{options[:company]}")
    end

  else
    if !options[:company] or !options[:format]
      puts("[-] Tokens could not be loaded, please either create it or specify --company and --format")
      exit
    end
  end

  egen = EmailGen.new(options[:domain], options[:company], options[:format], location = options[:location])
  puts("[+] Starting scan against #{options[:company]}")
  emails = egen.scan
  puts("[*] Scan complete! Generated #{emails.length} emails!")
  puts("")

  if options[:outfile]
    file = File.open(options[:outfile], "w+")

    emails.each do |email|
      file.write(email + "\n")
    end

    file.close
    puts("[+] Emails saved to #{options[:outfile]}")
  else
    puts(emails)
  end
end
