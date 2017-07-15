# dec11:
#   events:
#   - type: talk
#     begin: '11:00'
#     end: '12:00'
#     talks:
#       hall_a: matz
#
#   - type: break
#     begin: '12:00'
#     end: '13:30'
#     name: Lunch on your own
#
#   - type: talk
#     begin: '14:10'
#     end: '14:45'
#     talks:
#       hall_a: MattStudies
#       hall_b: yuki24

require 'ruby_kaigi'

raise 'Specify an Event Slug' unless event_slug = (ENV['EVENT_SLUG'] || ARGV[0])

event = Event.find_by! slug: event_slug
puts RubyKaigi::CfpApp.schedule(event).to_yaml
