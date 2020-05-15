FactoryBot.define do
  factory :access_token do
    token { "MyString" }
    user { User.create(login: 'example', password: 'test123', provider: 'standard') }
  end
end
