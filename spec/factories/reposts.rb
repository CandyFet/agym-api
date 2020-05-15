FactoryBot.define do
  factory :repost do
    for_post

    trait :for_post do
      association :repostable, factory: :post
      association :user
    end
  end
end
