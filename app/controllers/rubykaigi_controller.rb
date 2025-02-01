# frozen_string_literal: true

class RubykaigiController < ApplicationController
  before_action :require_event, :authenticate_with_token

  # /events/2025/rubykaigi/speakers.yml
  def speakers
    speakers = RubyKaigi::CfpApp.speakers(@event)

    respond_to do |format|
      format.yaml { render plain: speakers.to_yaml, content_type: 'text/yaml' }
    end
  end

  # /events/2025/rubykaigi/presentations.yml
  def presentations
    presentations = RubyKaigi::CfpApp.presentations(@event)

    respond_to do |format|
      format.yaml { render plain: presentations.to_yaml, content_type: 'text/yaml' }
    end
  end


  # /events/2025/rubykaigi/schedule.yml
  def schedule
    schedule = RubyKaigi::CfpApp.schedule(@event)

    respond_to do |format|
      format.yaml { render plain: schedule.to_yaml, content_type: 'text/yaml' }
    end
  end

  private

  def authenticate_with_token
    authenticate_or_request_with_http_token do |token, options|
      ActiveSupport::SecurityUtils.secure_compare(token, ENV.fetch('RUBYKAIGI_API_TOKEN'))
    end
  end
end
