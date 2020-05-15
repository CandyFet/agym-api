FactoryBot.define do
  factory :like do
    for_post

    trait :for_post do
      association :likeble, factory: :post
      association :user
    end

    trait :for_comment do
      association :likeble, factory: :comment
      association :user
    end
  end
end
