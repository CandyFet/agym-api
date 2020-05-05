99.times do |n|
    Post.create(title: "Post title #{n}",
                text: Faker::Lorem.paragraph_by_chars(number: 256, supplemental: false),
                preview_text: Faker::Lorem.paragraph_by_chars(number: 50, supplemental: false),
                slug: "post-title-#{n}")
end

User.create(login: 'example', password: 'test123', provider: 'standard')

99.times do |n|
    User.create(login: 'Faker::Name.name',
         password: 'test123',
         provider: 'standard') 
end