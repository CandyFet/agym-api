FactoryBot.define do
  factory :comment do
    sequence(:text) { |n| "My text #{n}" }
    association :post
    association :user
  end
end
