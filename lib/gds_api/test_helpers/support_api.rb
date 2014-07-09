module GdsApi
  module TestHelpers
    module SupportApi
      SUPPORT_API_ENDPOINT = Plek.current.find('support-api')

      def stub_support_api_service_feedback_creation(feedback_details = nil)
        post_stub = stub_http_request(:post, "#{SUPPORT_API_ENDPOINT}/anonymous-feedback/service-feedback")
        post_stub.with(:body => { service_feedback: feedback_details }) unless feedback_details.nil?
        post_stub.to_return(:status => 201)
      end

      def support_api_isnt_available
        stub_request(:post, /#{SUPPORT_API_ENDPOINT}\/.*/).to_return(:status => 503)
      end
    end
  end
end
