require 'ruby_kaigi'

raise 'Specify an Event Slug' unless event_slug = (ENV['EVENT_SLUG'] || ARGV[0])

event = Event.find_by! slug: event_slug
puts RubyKaigi::CfpApp.speakers(event).to_yaml
