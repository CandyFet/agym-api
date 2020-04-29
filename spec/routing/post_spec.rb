require 'rails_helper'

describe 'posts routes' do
    it 'should rout to posts index' do
        expect(get '/posts').to route_to('posts#index')
    end

    it 'should rout to posts show' do
        expect(get '/posts/1').to route_to('posts#show', id: '1')
    end
end