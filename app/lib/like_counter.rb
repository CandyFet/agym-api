class LikeCounter
    def initialize(reference_type, reference_id)
        @like_counter = reference_type == 'Post' ? Post.new(reference_id) : Comment.new(reference_id) 
    end
end