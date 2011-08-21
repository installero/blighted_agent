require 'rubygems'
require 'nokogiri'
require 'whois'
require 'open-uri'
require 'optparse'
require 'highline/import'

ft = HighLine::ColorScheme.new do |cs|
  cs[:first_variant] = [:bold,:green]
  cs[:second_variant] = [:green]
end

HighLine.color_scheme = ft

options = OpenStruct.new

optparse = OptionParser.new do|opts|

  opts.banner = "Usage: ruby blighted_agent.rb [options]"
  options.verbose = false
  options.output = 'result.html'

  opts.on("-v", "--verbose", "Run verbosely") do |v|
    options.verbose = v
  end

  opts.on('-t', '--type CARD_TYPE', 'Card type |Artifact, Creature, Enchant, Instant, Land, Planeswalker, Sorcery|') do |card_type|
    options.card_type = card_type
  end

  opts.on('-k', '--key CARD_KEYTYPE', 'Card key type "Knight, Goblin, Rebel"') do |card_keytype|
    options.card_keytype = card_keytype
  end

  opts.on('-r', '--rarities x,y,z', Array, 'Card rarities (m,r,u,c,s)') do |rarities|
    options.rarities = rarities
  end

  opts.on('-c', '--color x,y,z', Array, 'Card colors (b,u,g,r,w)') do |colors|
    options.colors = colors
  end

  opts.on('-o', '--output FILE', 'Print output html to file, result.html by default') do |file|
    options.output = file
  end

end
  
optparse.parse!

url = "http://www.cardkingdom.com/catalog/view?search=mtg_advanced"

url << "&filter[type]=" << options.card_type if options.card_type
url << "&filter[type_key]=" << options.card_keytype if options.card_keytype

if options.rarities
  %w(m r u c s).each_with_index do |r,i|
    url << "&filter[rarity][#{i}]=#{r.upcase}" if options.rarities.include?(r)
  end
end

if options.colors
  %w(b u g r w).each_with_index do |c,i|
    url << "&filter[cast][#{i}]=#{c}" if options.colors.include?(c)
  end
end

puts url if options.verbose

uri = URI.parse(url)

@doc = Nokogiri::HTML(uri.read)
pages = @doc.css("table.grid[2] tr td[1]").text.split(" ")[4].to_i/50 + 1

puts "pages=#{pages}" if options.verbose

@names = []

(1..pages).each do |i|
 uri = URI.parse(url << "&page=#{i}")
 @doc = Nokogiri::HTML(uri.read)
 @doc.css("table.grid[3]").css("tr").each do |tr|
   text = tr.css("td[1]").text.downcase.gsub(/ (\(.*\))/,"").gsub(/[,.' -]/,"")
   unless text == "" || %w(title highmarket murmuringbosk irrigationditch).include?(text)
     @names << text
   end
 end
end

@domains = []

@names.uniq!
File.open(options.output, "a") do |f|
  @names.each do |name|
    domain = "#{name}.com"
    puts "checking #{domain}... " if options.verbose
    record = Whois::Client.new(:timeout => 120).query(domain)
    if record.available?
      @domains << domain
      f.puts "<p><b>#{domain} is free!</b></p>"
      puts "#{domain} is free!" if options.verbose
    else
      if record.technical_contact
        ocupant = record.technical_contact.organization
      elsif record.registrar
        ocupant = record.registrar.organization
      else
        ocupant = "unknown ocupant"
      end
      f.puts "<p>#{domain} is occupied by #{ocupant}</p>"
      puts "#{domain} is occupied by #{ocupant}" if options.verbose
    end
  end
end

@domains = @domains.shuffle

say %{Your next project is <%= color('#{@domains.first}', :first_variant) %>! Now stop wasting time on choosing a name for it and go create it!}
say %{OK, you may consider <%= color('#{@domains[1]}', :second_variant) %> if you don't like the first variant.} if @domains.length > 1
