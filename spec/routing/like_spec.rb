# frozen_string_literal: true

require 'rails_helper'

describe 'likes routes' do
  it 'should route to likes show' do
    expect(get: '/posts/1/likes').to route_to('likes#index', post_id: '1')
    expect(get: '/posts/1/comments/1/likes').to route_to('likes#index', post_id: '1', comment_id: '1')
  end

  it 'should route to likes create' do
    expect(post: '/posts/1/likes').to route_to('likes#create', post_id: '1')
    expect(post: '/posts/1/comments/1/likes').to route_to('likes#create', post_id: '1', comment_id: '1')
  end

  it 'should route to likes destroy' do
    expect(delete: '/posts/1/likes/1').to route_to('likes#destroy', id: '1', post_id: '1')
    expect(delete: '/posts/1/comments/1/likes/1').to route_to('likes#destroy', id: '1', post_id: '1', comment_id: '1')
  end
end
