User.create(login: 'example', password: 'test123', provider: 'standard')

9.times do |n|
    User.create(login: Faker::Name.name,
         password: 'test123',
         provider: 'standard') 
end

25.times do |n|
    Post.create(title: "Post title #{n}",
                text: Faker::Lorem.paragraph_by_chars(number: 256, supplemental: false),
                user: User.find_by(id: "#{Random.new.rand(1...User.count)}"))
end

Post.count.times do |post_index|
    10.times do
        post = Post.find_by(id: "#{post_index + 1}")
        user = User.find_by(id: "#{Random.new.rand(1...User.count)}")
        comment = Comment.create(
            commentable: post,
            user: user,
            text: Faker::Lorem.paragraph_by_chars(number: 100, supplemental: false),
        )
    end
end

25.times do |n|
    article = Article.create(title: "Article title #{n}",
                text: Faker::Lorem.paragraph_by_chars(number: 256, supplemental: false),
                user: User.find_by(id: "#{Random.new.rand(1...User.count)}"))
    like = Like.create(user: article.user, likeble: article)
    repost = Repost.create(user: article.user, repostable: article)
end

Article.count.times do |article_index|
    10.times do
        article = Article.find_by(id: "#{article_index + 1}")
        user = User.find_by(id: "#{Random.new.rand(1...User.count)}")
        comment = Comment.create(
            commentable: article,
            user: user,
            text: Faker::Lorem.paragraph_by_chars(number: 100, supplemental: false),
        )
        like = Like.create(user: user, likeble: comment)
    end
end
