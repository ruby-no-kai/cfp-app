namespace :rubykaigi do
  namespace :to_yaml do
    desc 'Generate speakers.yml from cfp-app and send a PR to the RKO repo'
    task :speakers, [:event_slug] => :environment do |t, args|
      require 'ruby_kaigi'

      event = Event.find_by! slug: args[:event_slug]
      new_yaml = RubyKaigi::CfpApp.speakers(event).to_yaml
      repo = RubyKaigi::RKO.clone
      old_yaml = repo.speakers

      if new_yaml != old_yaml
        repo.speakers = new_yaml
        p res = repo.pr
        p res.body unless res.code.to_s == '201'
      end
    end
  end
end
