class Invitation < ApplicationRecord
  enum :state, {pending: 'pending', accepted: 'accepted', declined: 'declined'}, default: :pending do
    event :accept do
      transition :pending => :accepted

      before do |user|
        self.user = user
        proposal.speakers.create!(user: user, event: proposal.event, skip_name_email_validation: true)
      end
    end

    event :decline do
      transition :pending => :declined
    end
  end

  belongs_to :proposal
  belongs_to :user, optional: true

  before_create :set_slug

  validates :email, presence: true
  validates_format_of :email, with: /@/

  private

  def set_slug
    self.slug = Digest::SHA1.hexdigest([email, rand(1000)].map(&:to_s).join('-'))[0, 10]
  end
end

# == Schema Information
#
# Table name: invitations
#
#  id          :integer          not null, primary key
#  proposal_id :integer
#  person_id   :integer
#  email       :string(255)
#  state       :string(255)      default("pending")
#  slug        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  user_id     :integer
#
# Indexes
#
#  index_invitations_on_person_id              (person_id)
#  index_invitations_on_proposal_id            (proposal_id)
#  index_invitations_on_proposal_id_and_email  (proposal_id,email) UNIQUE
#  index_invitations_on_slug                   (slug) UNIQUE
#  index_invitations_on_user_id                (user_id)
#
