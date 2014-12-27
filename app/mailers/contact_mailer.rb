class ContactMailer < ActionMailer::Base
  default from: "contato@brasilacessivel.com.br"

  def contact_mail(contact)
    @contact = contact
    mail(to: 'geisonfgf@gmail.com',
         subject: @contact.subject,
         template_path: 'contacts/mailer',
         template_name: 'contact_mailer')
  end
end
