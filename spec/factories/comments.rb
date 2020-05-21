FactoryBot.define do
  factory :comment do
    for_post

    trait :for_post do
      association :commentable, factory: :post
      association :user
      sequence(:text) { |n| "My text #{n}" }
    end

    trait :for_article do
      association :commentable, factory: :article
      association :user
      sequence(:text) { |n| "My text #{n}" }
    end

  end
end
