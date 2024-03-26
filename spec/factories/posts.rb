# frozen_string_literal: true

FactoryBot.define do
  factory :post do
    text { Faker::Lorem.paragraph }
    # user

    # trait :with_comments do
    #   comments { create(:comment, :with_comments) }
    # end
  end
end
