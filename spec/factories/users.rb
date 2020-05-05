FactoryBot.define do
  factory :user do
    sequence(:login) { |n| "User#{n}" }
    name { "John" }
    email { "John@example.com" }
    url { "http://example.com" }
    avatar_url { "http://example.com/avatar" }
    provider { "github" }
    admin { false }
    trainer { false }
    ambassador { false }
  end
end
