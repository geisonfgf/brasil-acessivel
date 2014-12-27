class Contact
  include ActiveAttr::Model

  attribute :name
  attribute :email
  attribute :subject
  attribute :content

  validates :name, :email, :subject, :content, presence: true
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create
end
