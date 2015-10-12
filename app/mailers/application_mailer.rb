class ApplicationMailer < ActionMailer::Base
  helper MailerHelper

  attr_accessor :template_name

  def mail_markdown(options)
    mail options do |format|
      markdown_string = render_to_string(template_name || action_name, formats: :md)
      format.html { render body: Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(markdown_string)}
      format.text { render plain: markdown_string }
    end
  end
end
