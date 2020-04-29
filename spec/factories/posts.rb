FactoryBot.define do
  factory :post do
    sequence(:title) { |n| "Post number #{n}" }
    sequence(:text) { |n| "My text #{n}" }
    sequence(:slug) { |n| "post-number-#{n}" }
    sequence(:preview_text) { |n| "My text #{n}" }
  end
end
