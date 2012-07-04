module Braintree
  module TransparentRedirect

    def self.confirm(query_string)
      response = SuccessfulResult.new
      puts response.success?
      response
    end


	class SuccessfulResult   

		def customer
		{:id => 1}
		end

		def success?
		true
		end
	end
  end
end
