class Room < ApplicationRecord
  belongs_to :event
  has_many :time_slots

  validates :name, uniqueness: {scope: :event_id}, presence: true
  scope :by_grid_position, -> {where.not(grid_position: nil).order(:grid_position)}
  scope :grid_order, -> { order(:grid_position) }
end

# == Schema Information
#
# Table name: rooms
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  room_number   :string(255)
#  level         :string(255)
#  address       :string(255)
#  capacity      :integer
#  event_id      :integer
#  created_at    :datetime
#  updated_at    :datetime
#  grid_position :integer
#
# Indexes
#
#  index_rooms_on_event_id  (event_id)
#
