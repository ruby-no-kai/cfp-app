class ApplicationMailer < ActionMailer::Base
  helper MailerHelper

  MARKDOWN_RENDERER = Redcarpet::Markdown.new(Redcarpet::Render::HTML).freeze

  attr_accessor :template_name

  def mail_markdown(options)
    mail options do |format|
      markdown_string = render_to_string(template_name || action_name, formats: :md)
      format.html { render body: MARKDOWN_RENDERER.render(markdown_string) }
      format.text { render plain: markdown_string }
    end
  end
end
