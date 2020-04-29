99.times do |n|
    Post.create(title: "Post title #{n}",
                text: Faker::Lorem.paragraph_by_chars(number: 256, supplemental: false),
                preview_text: Faker::Lorem.paragraph_by_chars(number: 50, supplemental: false),
                slug: "post-title-#{n}")
end