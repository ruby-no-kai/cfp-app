# matz:
#   title: Keynote
#   type: keynote
#   language: JA
#   description: 'TBA'
#   speakers:
#     - id: matz
#
# keiju:
#   title: Usage and implementation of Reish which is an Unix shell for Rubyist
#   type: presentation
#   language: JA
#   description: "Reish is an Unix shell for Rubyist. It was a language that was realized
#     Ruby in the syntax of the shell. I will introduce usage and implementation of Reish."
#   speakers:
#     - id: keiju

require 'ruby_kaigi'

raise 'Specify an Event Slug' unless event_slug = (ENV['EVENT_SLUG'] || ARGV[0])

event = Event.find_by! slug: event_slug
puts RubyKaigi::CfpApp.presentations(event).to_yaml
