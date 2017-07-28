module RubyKaigi
  # 2017
  KEYNOTES = %w(yukihiro_matz n0kada vnmakarov)

  module CfpApp
    def self.speakers(event)
      # people = Person.includes(:services).where(id: event.proposals.select('people.id').joins(speakers: :person).accepted.confirmed).each_with_object({}) do |p, hash|
      people = Speaker.includes(person: :services).where(id: event.proposals.select('speakers.id').joins(:speakers).accepted.confirmed).each_with_object({}) do |sp, hash|
        person = sp.person
        tw = person.services.detect {|s| s.provider == 'twitter'}&.account_name
        gh = person.services.detect {|s| s.provider == 'github'}&.account_name
        id = tw || gh
        bio = if sp.bio.present? && (sp.bio != 'N/A')
          sp.bio
        else
          person.bio || ''
        end.gsub("\r\n", "\n").chomp
        h = {'id' => id, 'name' => person.name, 'bio' => bio, 'github_id' => gh, 'twitter_id' => tw, 'gravatar_hash' => Digest::MD5.hexdigest(person.email)}
        hash[id] = h
      end
      keynotes, speakers = people.partition {|p| KEYNOTES.include? p.first}

      {'keynotes' => keynotes.to_h, 'speakers' => speakers.sort_by {|p| p.first.downcase}.to_h}
    end
  end

  class RKO
    def self.clone
      Dir.chdir '/tmp' do
        `git clone https://#{ENV['GITHUB_TOKEN']}@github.com/ruby-no-kai/rubykaigi2017.git`
        Dir.chdir 'rubykaigi2017' do
          `git checkout master`
          `git remote add rubykaigi-bot https://#{ENV['GITHUB_TOKEN']}@github.com/rubykaigi-bot/rubykaigi2017.git`
          `git pull`
        end
      end
      new '/tmp/rubykaigi2017'
    end

    def initialize(path)
      @path = path
    end

    def speakers
      File.read "#{@path}/data/year_2017/speakers.yml"
    end

    def speakers=(content)
      File.write "#{@path}/data/year_2017/speakers.yml", content
    end

    def sponsors
      File.read "#{@path}/data/year_2017/sponsors.yml"
    end

    def sponsors=(content)
      File.write "#{@path}/data/year_2017/sponsors.yml", content
    end

    def pr(title: 'From cfp-app')
      Dir.chdir @path do
        branch_name = "from-cfpapp-#{Time.now.strftime('%Y%m%d%H%M%S')}"
        `git checkout -b #{branch_name}`
        `git config user.name "RubyKaigi Bot" && git config user.email "amatsuda@rubykaigi.org"`
        `git commit -am '#{title}' && git push -u rubykaigi-bot HEAD`
        uri = URI 'https://api.github.com/repos/ruby-no-kai/rubykaigi2017/pulls'
        Net::HTTP.post uri, {'title' => title, 'head' => "rubykaigi-bot:#{branch_name}", 'base' => 'master'}.to_json, {'Authorization' => "token #{ENV['GITHUB_TOKEN']}"}
      end
    end
  end

  module Gist
    def self.sponsors_yml
      uri = URI 'https://api.github.com/gists/d6f1dd44017aac2ec4031aa9178f99e8'
      uri.query = URI.encode_www_form 'access_token': ENV['GIST_TOKEN']
      res = Net::HTTP.get(uri)
      JSON.parse(res)['files']['rubykaigi2017_sponsors.yml']['content']
    end
  end

  module Speakers
#       def self.get
#         uri = URI 'https://api.github.com/repos/ruby-no-kai/rubykaigi2017/contents/data/year_2017/speakers.yml'
#         uri.query = URI.encode_www_form access_token: #{ENV['GITHUB_TOKEN']}
#         res = Net::HTTP.get(uri)
#         Base64.decode64(JSON.parse(res))['content']
#       end
  end
end
