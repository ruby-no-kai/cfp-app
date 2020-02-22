module RubyKaigi
  DISCUSSION_SESSIONS = [127, 172, 330].freeze  # committers, committers
  LT_SESSIONS = [159, 233, 329].freeze  # LT
  WORKSHOP_PROPOSALS = {794 => 'mrkn_workshop'}

  module CfpApp
    def self.speakers(event)
      keynotes, speakers = {}, {}
      Speaker.joins(:proposal).includes(:user, program_session: [:session_format, :time_slot]).merge(event.proposals.accepted.confirmed).order('time_slots.conference_day, time_slots.start_time').decorate.each do |sp|
        user = sp.user
        id = sp.social_account
        bio = if sp.bio.present? && (sp.bio != 'N/A')
          sp.bio
        else
          user.bio || ''
        end.gsub("\r\n", "\n").strip
        h = {'id' => id, 'name' => user.name, 'bio' => bio, 'github_id' => sp.github_account, 'twitter_id' => sp.twitter_account, 'gravatar_hash' => Digest::MD5.hexdigest(user.email)}
        if sp.program_session.session_format.name == 'Keynote'
          keynotes[id] = h
        else
          speakers[id] = h
        end
      end

      result = {'keynotes' => keynotes.to_h, 'speakers' => speakers.sort_by {|p| p.last['name'].downcase }.to_h }
      result.delete 'keynotes' if result['keynotes'].empty?
      result
    end

    def self.presentations(event)
      proposals = event.proposals.joins(:session).includes([{speakers: {person: :services}}, :session]).accepted.confirmed.order('sessions.conference_day, sessions.start_time, sessions.room_id')
      presentations = proposals.each_with_object({}) do |p, h|
        speakers = p.speakers.sort_by(&:created_at).map {|sp| sp.person.social_account }
        lang = (p.custom_fields['spoken language in your talk'] || 'JA').downcase.in?(['ja', 'jp', 'japanese', '日本語', 'Maybe Japanese (not sure until fix the contents)']) ? 'JA' : 'EN'
        type = p.session.id.in?(KEYNOTE_SESSIONS) ? 'keynote' : (p.session.id.in?(DISCUSSION_SESSIONS) ? 'discussion' : 'presentation')
        speaker_name = WORKSHOP_PROPOSALS[p.id] || speakers.first
        h[speaker_name] = {'title' => p.title, 'type' => type, 'language' => lang, 'description' => p.abstract.gsub("\r\n", "\n").chomp, 'speakers' => speakers.map {|sp| {'id' => sp}}}
      end
    end

    def self.schedule(event)
      first_date = event.start_date.to_date

      time_slots = event.time_slots.includes(:room, program_session: {speakers: :user})

      time_slots.group_by(&:conference_day).sort_by {|day, _| day }.to_h do |day, time_slots_per_day|
        events = time_slots_per_day.group_by {|s| [s.start_time, s.end_time] }.sort_by {|(start_time, end_time), _| [start_time, end_time] }.map do |(start_time, end_time), time_slots|
          if time_slots.one? && time_slots.first['presenter'] == 'break'
            {type: 'break', begin: start_time.strftime('%H:%M'), end: end_time.strftime('%H:%M'), name: time_slots.first.title}
          else
            program_sessions = time_slots.select(&:program_session).sort_by {|s| s.room.grid_position }.map(&:program_session)
            type = program_sessions.one? && program_sessions.first.session_format.name == 'Keynote' ? 'keynote' : 'talks'
            talks = program_sessions.to_h {|ps| [ps.time_slot.room.name, ps.speakers.first.decorate.social_account] }
            {type: type, begin: start_time.strftime('%H:%M'), end: end_time.strftime('%H:%M'), talks: talks}
          end
        end
        [(day - 1).days.since(first_date).strftime('%b%d').downcase, {events: events}.deep_stringify_keys]
      end
    end
  end

  class RKO
    def self.clone
      Dir.chdir '/tmp' do
        `git clone https://#{ENV['GITHUB_TOKEN']}@github.com/ruby-no-kai/rubykaigi.org.git`
        Dir.chdir 'rubykaigi.org' do
          `git checkout master`
          `git remote add rubykaigi-bot https://#{ENV['GITHUB_TOKEN']}@github.com/rubykaigi-bot/rubykaigi.org.git`
          `git pull --all`
        end
      end
      new '/tmp/rubykaigi.org'
    end

    def initialize(path)
      @path = path
    end

    %w(speakers lt_speakers sponsors schedule presentations lt_presentations).each do |name|
      define_method name do
        File.read "#{@path}/data/year_2020/#{name}.yml"
      end

      define_method "#{name}=" do |content|
        File.write "#{@path}/data/year_2020/#{name}.yml", content
      end

      define_method "pull_requested_#{name}" do
        begin
          `git checkout #{name}-from-cfpapp`
          File.read "#{@path}/data/year_2020/#{name}.yml"
        ensure
          `git checkout master`
        end
      end
    end

    def pr(title: 'From cfp-app', branch: "from-cfpapp-#{Time.now.strftime('%Y%m%d%H%M%S')}")
      Dir.chdir @path do
        `git checkout -b #{branch}`
        `git config user.name "RubyKaigi Bot" && git config user.email "amatsuda@rubykaigi.org"`
        `git commit -am '#{title}' && git push -u rubykaigi-bot HEAD`
        uri = URI 'https://api.github.com/repos/ruby-no-kai/rubykaigi.org/pulls'
        Net::HTTP.post uri, {'title' => title, 'head' => "rubykaigi-bot:#{branch}", 'base' => 'master'}.to_json, {'Authorization' => "token #{ENV['GITHUB_TOKEN']}"}
      end
    end
  end

  module Gist
    def self.sponsors_yml
      uri = URI 'https://api.github.com/gists/9f71ac78c76cd7132be1076702002d47'
      uri.query = URI.encode_www_form 'access_token': ENV['GIST_TOKEN']
      res = Net::HTTP.get(uri)
      JSON.parse(res)['files']['rubykaigi2020_sponsors.yml']['content']
    end
  end

  module Speakers
#       def self.get
#         uri = URI 'https://api.github.com/repos/ruby-no-kai/rubykaigi.org/contents/data/year_2020/speakers.yml'
#         uri.query = URI.encode_www_form access_token: #{ENV['GITHUB_TOKEN']}
#         res = Net::HTTP.get(uri)
#         Base64.decode64(JSON.parse(res))['content']
#       end
  end
end
