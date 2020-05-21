# frozen_string_literal: true

module Behaveable
  module ResourceFinder
    def behaveable
      klass, param = behaveable_class
      klass&.find(params[param.to_sym])
    end

    private

    def behaveable_class
      klass, name = nil
      params.each_key do |key|
        if key =~ /(.+)_id$/
          model = key.match(%r{([^\/.]*)_id$})
          klass = model[1].classify.constantize
          name = key
        end
      end
      return klass, name if klass.present? && name.present?
    end
  end
end
