require "rubygems"
require "nokogiri"
require "whois"

TYPE = 'Land'
RARITY = 'any'

@output = 'result.html'

@names = []
(1..22).each do |i|
  filename = "cardkingdom_#{i}.html"
  %x(wget "http://www.cardkingdom.com/catalog/view?search=mtg_advanced&filter[type]=#{TYPE}&filter[rarity_all]=#{RARITY}&page=#{i}" -O #{filename})
  @doc = Nokogiri::HTML(File.open(filename))
  @doc.css("table.grid[3]").css("tr").each do |tr|
    text = tr.css("td[1]").text.downcase.gsub(/ (\(.*\))/,"").gsub(/[,.' -]/,"")
    unless text == "" || %w(title highmarket murmuringbosk irrigationditch).include?(text)
      @names << text
    end
  end
end

@names.uniq!
File.open(@output, "a") do |f|
  @names.each do |name|
    puts "checking #{name}.com... "
    record = Whois::Client.new(:timeout => 120).query("#{name}.com")
    if record.available?
      f.puts "<p><b>#{name}.com is free!</b></p>"
      puts "#{name}.com is free!"
    else
      if record.technical_contact
          ocupant = record.technical_contact.organization 
      elsif record.registrar
          ocupant = record.registrar.organization
      else
          ocupant = "unknown ocupant"
      end
      f.puts "<p>#{name}.com is occupied by #{ocupant}</p>"
      puts "#{name}.com is occupied by #{ocupant}"
    end
  end
end

%x(rm cardkingdom_*)
