# frozen_string_literal: true

class Post < ApplicationRecord
  validates_presence_of :text
  has_many :comments, dependent: :destroy
  belongs_to :user
end
