class Post < ApplicationRecord
  validates_presence_of :post_text
  has_many :comment
end
