require "json"

module GdsApi
  module TestHelpers
    module AccountApi
      ACCOUNT_API_ENDPOINT = Plek.find("account-api")

      def stub_account_api_get_sign_in_url(redirect_path: nil, state_id: nil, level_of_authentication: nil, auth_uri: "http://auth/provider", state: "state")
        querystring = Rack::Utils.build_nested_query({ redirect_path: redirect_path, state_id: state_id, level_of_authentication: level_of_authentication }.compact)
        stub_request(:get, "#{ACCOUNT_API_ENDPOINT}/api/oauth2/sign-in?#{querystring}")
          .to_return(
            status: 200,
            body: { auth_uri: auth_uri, state: state }.to_json,
          )
      end

      def stub_account_api_validates_auth_response(code: nil, state: nil, govuk_account_session: "govuk-account-session", redirect_path: "/", ga_client_id: "ga-client-id")
        stub_request(:post, "#{ACCOUNT_API_ENDPOINT}/api/oauth2/callback")
          .with(body: hash_including({ code: code, state: state }.compact))
          .to_return(
            status: 200,
            body: { govuk_account_session: govuk_account_session, redirect_path: redirect_path, ga_client_id: ga_client_id }.to_json,
          )
      end

      def stub_account_api_rejects_auth_response(code: nil, state: nil)
        stub_request(:post, "#{ACCOUNT_API_ENDPOINT}/api/oauth2/callback")
          .with(body: hash_including({ code: code, state: state }.compact))
          .to_return(status: 401)
      end

      def stub_account_api_create_registration_state(attributes: nil, state_id: "state-id")
        stub_request(:post, "#{ACCOUNT_API_ENDPOINT}/api/oauth2/state")
          .with(body: hash_including({ attributes: attributes }.compact))
          .to_return(
            status: 200,
            body: { state_id: state_id }.to_json,
          )
      end

      def stub_account_api_has_email_subscription(**options)
        stub_account_api_request(
          :get,
          "/api/transition-checker-email-subscription",
          response_body: { has_subscription: true },
          **options,
        )
      end

      def stub_account_api_does_not_have_email_subscription(**options)
        stub_account_api_request(
          :get,
          "/api/transition-checker-email-subscription",
          response_body: { has_subscription: false },
          **options,
        )
      end

      def stub_account_api_unauthorized_get_email_subscription(**options)
        stub_account_api_request(
          :get,
          "/api/transition-checker-email-subscription",
          response_status: 401,
          **options,
        )
      end

      def stub_account_api_forbidden_get_email_subscription(needed_level_of_authentication: "level1", **options)
        stub_account_api_request(
          :get,
          "/api/transition-checker-email-subscription",
          response_status: 403,
          response_body: { needed_level_of_authentication: needed_level_of_authentication },
          **options,
        )
      end

      def stub_account_api_set_email_subscription(slug: nil, **options)
        stub_account_api_request(
          :post,
          "/api/transition-checker-email-subscription",
          with: { body: hash_including({ slug: slug }.compact) },
          **options,
        )
      end

      def stub_account_api_unauthorized_set_email_subscription(slug: nil, **options)
        stub_account_api_request(
          :post,
          "/api/transition-checker-email-subscription",
          with: { body: hash_including({ slug: slug }.compact) },
          response_status: 401,
          **options,
        )
      end

      def stub_account_api_forbidden_set_email_subscription(slug: nil, needed_level_of_authentication: "level1", **options)
        stub_account_api_request(
          :post,
          "/api/transition-checker-email-subscription",
          with: { body: hash_including({ slug: slug }.compact) },
          response_status: 403,
          response_body: { needed_level_of_authentication: needed_level_of_authentication },
          **options,
        )
      end

      def stub_account_api_has_attributes(attributes: [], values: {}, **options)
        querystring = Rack::Utils.build_nested_query({ attributes: attributes }.compact)
        stub_account_api_request(
          :get,
          "/api/attributes?#{querystring}",
          response_body: { values: values },
          **options,
        )
      end

      def stub_account_api_unauthorized_has_attributes(attributes: [], **options)
        querystring = Rack::Utils.build_nested_query({ attributes: attributes }.compact)
        stub_account_api_request(
          :get,
          "/api/attributes?#{querystring}",
          response_status: 401,
          **options,
        )
      end

      def stub_account_api_forbidden_has_attributes(attributes: [], needed_level_of_authentication: "level1", **options)
        querystring = Rack::Utils.build_nested_query({ attributes: attributes }.compact)
        stub_account_api_request(
          :get,
          "/api/attributes?#{querystring}",
          response_status: 403,
          response_body: { needed_level_of_authentication: needed_level_of_authentication },
          **options,
        )
      end

      def stub_account_api_set_attributes(attributes: nil, **options)
        stub_account_api_request(
          :patch,
          "/api/attributes",
          with: { body: hash_including({ attributes: attributes }.compact) },
          **options,
        )
      end

      def stub_account_api_unauthorized_set_attributes(attributes: nil, **options)
        stub_account_api_request(
          :patch,
          "/api/attributes",
          with: { body: hash_including({ attributes: attributes }.compact) },
          response_status: 401,
          **options,
        )
      end

      def stub_account_api_forbidden_set_attributes(attributes: nil, needed_level_of_authentication: "level1", **options)
        stub_account_api_request(
          :patch,
          "/api/attributes",
          with: { body: hash_including({ attributes: attributes }.compact) },
          response_status: 403,
          response_body: { needed_level_of_authentication: needed_level_of_authentication },
          **options,
        )
      end

      def stub_account_api_get_attributes_names(attributes: [], **options)
        querystring = Rack::Utils.build_nested_query({ attributes: attributes }.compact)
        stub_account_api_request(
          :get,
          "/api/attributes/names?#{querystring}",
          response_body: { values: attributes },
          **options,
        )
      end

      def stub_account_api_unauthorized_get_attributes_names(attributes: [], **options)
        querystring = Rack::Utils.build_nested_query({ attributes: attributes }.compact)
        stub_account_api_request(
          :get,
          "/api/attributes/names?#{querystring}",
          response_status: 401,
          **options,
        )
      end

      def stub_account_api_forbidden_get_attributes_names(attributes: [], needed_level_of_authentication: "level1", **options)
        querystring = Rack::Utils.build_nested_query({ attributes: attributes }.compact)
        stub_account_api_request(
          :get,
          "/api/attributes/names?#{querystring}",
          response_status: 403,
          response_body: { needed_level_of_authentication: needed_level_of_authentication },
          **options,
        )
      end

      def stub_account_api_request(method, path, with: {}, response_status: 200, response_body: {}, govuk_account_session: nil, new_govuk_account_session: nil)
        with.merge!(headers: { GdsApi::AccountApi::AUTH_HEADER_NAME => govuk_account_session }) if govuk_account_session
        new_govuk_account_session = nil if response_status >= 400
        to_return = { status: response_status, body: response_body.merge(govuk_account_session: new_govuk_account_session).compact.to_json }
        if with.empty?
          stub_request(method, "#{ACCOUNT_API_ENDPOINT}#{path}").to_return(**to_return)
        else
          stub_request(method, "#{ACCOUNT_API_ENDPOINT}#{path}").with(**with).to_return(**to_return)
        end
      end
    end
  end
end
