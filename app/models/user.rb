class User < ApplicationRecord
  has_secure_password
  validates_presence_of :password_digest
  VALID_EMAIL_FORMAT = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates email, presence: true, length: { maximum: 260 }, format: { with: VALID_EMAIL_FORMAT },
                   uniqueness: { case_sensitive: false }
end
