# frozen_string_literal: true

class Comment < ApplicationRecord
  validates_presence_of :text
  belongs_to :post
end
