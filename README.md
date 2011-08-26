A script that helps you to choose a name for your project using M:TG card names from http://cardkingdom.com

## Installation

    git clone git@github.com:installero/blighted_agent.git
    cd blighted_agent
    sudo apt-get install libxslt-dev libxml2-dev
    sudo gem install nokogiri whois highline

## Usage

    ruby ./blighted_agent.rb -h
    
    -v, --verbose                    Run verbosely
    -t, --type CARD_TYPE             Card type |Artifact, Creature, Enchant, Instant, Land, Planeswalker, Sorcery|
    -k, --key CARD_KEYTYPE           Card key type "Knight, Goblin, Rebel"
    -r, --rarities x,y,z             Card rarities (m,r,u,c,s)
    -c, --color x,y,z                Card colors (b,u,g,r,w)
    -o, --output FILE                Print output html to file, result.html by default
    
##  Example
    
    ruby ./blighted_agent.rb -k Rogue -c u
    
  
