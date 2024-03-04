# frozen_string_literal: true

FactoryBot.define do
  factory :comment do
    comment_text { 'MyString' }
    refences { 'MyString' }
    post_id { 'MyString' }
  end
end
