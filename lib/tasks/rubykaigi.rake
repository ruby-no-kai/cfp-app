namespace :rubykaigi do
  namespace :to_yaml do
    desc 'Generate speakers.yml from cfp-app and send a PR to the RKO repo'
    task :speakers, [:event_slug] => :environment do |t, args|
      require 'ruby_kaigi'

      event = Event.find_by! slug: args[:event_slug]
      new_yaml = RubyKaigi::CfpApp.speakers(event).to_yaml
      repo = RubyKaigi::RKO.clone
      old_yaml = repo.pull_requested_speakers || repo.speakers

      if new_yaml == old_yaml
        Rails.logger.info 'No change.'
      else
        repo.speakers = new_yaml
        p res = repo.pr(title: 'Updates on speakers.yml from cfp-app', branch: 'speakers-from-cfpapp')
        p res.body unless res.code.to_s == '201'
        Rails.logger.info 'PRed.'
      end
    end

    desc 'Generate lt_speakers.yml from cfp-app and send a PR to the RKO repo'
    task :lt_speakers, [:event_slug] => :environment do |t, args|
      require 'ruby_kaigi'

      event = Event.find_by! slug: args[:event_slug]
      new_yaml = RubyKaigi::CfpApp.speakers(event).to_yaml
      repo = RubyKaigi::RKO.clone
      old_yaml = repo.pull_requested_lt_speakers || repo.lt_speakers

      if new_yaml == old_yaml
        Rails.logger.info 'No change.'
      else
        repo.lt_speakers = new_yaml
        p res = repo.pr(title: 'Updates on lt_speakers.yml from cfp-app', branch: 'lt_speakers-from-cfpapp')
        p res.body unless res.code.to_s == '201'
        Rails.logger.info 'PRed.'
      end
    end

    desc 'Generate presentations.yml and schedule.yml from cfp-app and send PRs to the RKO repo'
    task :schedule, [:event_slug] => :environment do |t, args|
      require 'ruby_kaigi'

      event = Event.find_by! slug: args[:event_slug]
      repo = RubyKaigi::RKO.clone
      new_schedule_yaml = RubyKaigi::CfpApp.schedule(event).to_yaml
      old_schedule_yaml = repo.pull_requested_schedule || repo.schedule

      if new_schedule_yaml == old_schedule_yaml
        Rails.logger.info 'No change for schedule.yml.'
      else
        repo.schedule = new_schedule_yaml
        p res = repo.pr(title: 'Updates on schedule.yml from cfp-app', branch: 'schedule-from-cfpapp')
        p res.body unless res.code.to_s == '201'
        Rails.logger.info 'PRed.'
      end

      new_presentations_yaml = RubyKaigi::CfpApp.presentations(event).to_yaml
      old_presentations_yaml = repo.pull_requested_presentations || repo.presentations

      if new_presentations_yaml == old_presentations_yaml
        Rails.logger.info 'No change for presentation.yml.'
      else
        repo.presentations = new_presentations_yaml
        p res = repo.pr(title: 'Updates on presentations.yml from cfp-app', branch: 'presentations-from-cfpapp')
        p res.body unless res.code.to_s == '201'
        Rails.logger.info 'PRed.'
      end
    end

    desc 'Generate lt_presentations.yml from cfp-app and send a PR to the RKO repo'
    task :lt_presentations, [:event_slug] => :environment do |t, args|
      require 'ruby_kaigi'

      event = Event.find_by! slug: args[:event_slug]
      repo = RubyKaigi::RKO.clone
      new_presentations_yaml = RubyKaigi::CfpApp.presentations(event).to_yaml
      old_presentations_yaml = repo.pull_requested_lt_presentations || repo.lt_presentations

      if new_presentations_yaml == old_presentations_yaml
        Rails.logger.info 'No change.'
      else
        repo.lt_presentations = new_presentations_yaml
        p res = repo.pr(title: 'Updates on lt_presentations.yml from cfp-app', branch: 'lt_presentations-from-cfpapp')
        p res.body unless res.code.to_s == '201'
        Rails.logger.info 'PRed.'
      end
    end

    desc 'Generate sponsors.yml from gist and send a PR to the RKO repo'
    task sponsors: :environment do |t, args|
      require 'ruby_kaigi'

      new_yaml = RubyKaigi::Gist.sponsors_yml
      repo = RubyKaigi::RKO.clone
      old_yaml = repo.pull_requested_sponsors || repo.sponsors

      if new_yaml == old_yaml
        Rails.logger.info 'No change.'
      else
        repo.sponsors = new_yaml
        p res = repo.pr(title: 'Updates on sponsors.yml from the spreadsheet', branch: 'sponsors-from-spreadsheet')
        p res.body unless res.code.to_s == '201'
        Rails.logger.info 'PRed.'
      end
    end
  end
end
