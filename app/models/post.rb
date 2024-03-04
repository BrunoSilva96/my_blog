# frozen_string_literal: true

class Post < ApplicationRecord
  validates_presence_of :text
  has_many :comment
end
