class ContactsController < ApplicationController
  def new
    @contact = Contact.new
  end

  def create
    @contact = Contact.new(place_params)
    if @contact.valid?
      ContactMailer.contact_mail(@contact).deliver
      redirect_to root_path, notice: 'Seu email foi enviado com sucesso!'
    else
      render 'contacts/new'
    end
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def place_params
      params.require(:contact).permit(:name, :email, :subject, :content)
    end
end
