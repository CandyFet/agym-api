FactoryBot.define do
  factory :post do
    sequence(:title) { |n| "Post number #{n}" }
    sequence(:text) { |n| "My text #{n}" }
    sequence(:preview_text) { |n| "My text #{n}" }
    association :user
  end
end
