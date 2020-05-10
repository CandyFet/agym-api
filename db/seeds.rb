User.create(login: 'example', password: 'test123', provider: 'standard')

9.times do |n|
    User.create(login: Faker::Name.name,
         password: 'test123',
         provider: 'standard') 
end

25.times do |n|
    Post.create(title: "Post title #{n}",
                text: Faker::Lorem.paragraph_by_chars(number: 256, supplemental: false),
                preview_text: Faker::Lorem.paragraph_by_chars(number: 50, supplemental: false),
                slug: "post-title-#{n}",
                user: User.find_by(id: "#{n}"))
end

Post.count.times do |post_index|
    10.times do |comment_index| 
        Comment.create(
            post: Post.find_by(id: "#{post_index + 1}"),
            user: User.find_by(id: "#{Random.new.rand(1...User.count)}"),
            text: "Super comment number #{comment_index + 1}!"
        )
    end
end