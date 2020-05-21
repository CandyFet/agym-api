FactoryBot.define do
  factory :article do
    sequence(:title) { |n| "Article number #{n}" }
    sequence(:text) { |n| "My text #{n}" }
    sequence(:preview_text) { |n| "My text #{n}" }
    association :user
  end
end
