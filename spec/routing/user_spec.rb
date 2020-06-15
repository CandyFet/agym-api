require 'rails_helper'

describe 'user routes' do
    it 'should route to users index action' do
        expect(get '/users').to route_to('users#index')
    end

    it 'should route to user show action' do
      expect(get '/users/1').to route_to('users#show', id: '1')
    end

    it 'should route to user create aaction' do
      expect(post '/users').to route_to('users#create')
    end

    it 'should route to user update action' do
      expect(put '/users/1').to route_to('users#update', id: '1')
      expect(patch '/users/1').to route_to('users#update', id: '1')
    end

    it 'should route to user destroy action' do
      expect(delete '/users/1').to route_to('users#destroy', id: '1')
    end
end