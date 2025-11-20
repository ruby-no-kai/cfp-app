class Invitation < ApplicationRecord
  include Invitable

  belongs_to :proposal
  belongs_to :user, optional: true

  def accept(user)
    transaction do
      self.user = user
      self.state = State::ACCEPTED
      proposal.speakers.create(user: user, event: proposal.event, skip_name_email_validation: true)
      save
    end
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
