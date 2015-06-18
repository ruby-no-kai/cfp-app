class SpeakerDecorator < Draper::Decorator
  delegate_all
  decorates_association :proposals
  decorates_association :program_sessions

  def bio
    object.bio.present? ? object.bio : object.user.try(:bio)
  end

  def github_account
    user.identities.where(provider: 'github').pick(:account_name)
  end

  def twitter_account
    user.identities.where(provider: 'twitter').pick(:account_name)
  end

  def social_account
    twitter_account || github_account || (user&.name || speaker_name).downcase.tr(' ', '_')
  end

  def link_to_github
    if (uname = github_account)
      h.link_to "@#{uname}", "https://github.com/#{uname}", target: '_blank'
    else
      'none'
    end
  end

  def link_to_twitter
    if (uname = twitter_account)
      h.link_to "@#{uname}", "https://twitter.com/#{uname}", target: '_blank'
    else
      'none'
    end
  end
end
