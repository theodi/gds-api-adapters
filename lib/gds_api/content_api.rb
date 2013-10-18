require_relative 'base'
require_relative 'exceptions'
require_relative 'list_response'

class GdsApi::ContentApi < GdsApi::Base
  include GdsApi::ExceptionHandling

  def initialize(endpoint_url, options = {})
    # If the `web_urls_relative_to` option is given, the adapter will convert
    # any `web_url` values to relative URLs if they are from the same host.
    #
    # For example: "https://www.gov.uk"

    @web_urls_relative_to = options.delete(:web_urls_relative_to)
    super
  end

  def sections
    get_list!("#{base_url}/tags.json?type=section")
  end

  def root_sections
    get_list!("#{base_url}/tags.json?type=section&root_sections=true")
  end

  def sub_sections(parent_tag)
    get_list!("#{base_url}/tags.json?type=section&parent_id=#{CGI.escape(parent_tag)}")
  end

  def tag(tag)
    get_json("#{base_url}/tags/#{CGI.escape(tag)}.json")
  end

  def with_tag(tag)
    get_list!("#{base_url}/with_tag.json?tag=#{CGI.escape(tag)}&include_children=1")
  end

  def curated_list(tag)
    get_list("#{base_url}/with_tag.json?tag=#{CGI.escape(tag)}&sort=curated")
  end

  def sorted_by(tag, sort_by)
    get_list!("#{base_url}/with_tag.json?tag=#{CGI.escape(tag)}&sort=#{sort_by}")
  end
  
  def related(type, item)
    get_list("#{base_url}/related.json?#{CGI.escape(type)}=#{CGI.escape(item)}")
  end

  def artefact(slug, params={})
    url = "#{base_url}/#{CGI.escape(slug)}.json"
    query = params.map { |k,v| "#{k}=#{v}" }
    if query.any?
      url += "?#{query.join("&")}"
    end

    if params[:edition] && ! options.include?(:bearer_token)
      raise GdsApi::NoBearerToken
    end
    get_json(url)
  end

  def artefacts
    get_list!("#{base_url}/artefacts.json")
  end

  def local_authority(snac_code)
    get_json("#{base_url}/local_authorities/#{CGI.escape(snac_code)}.json")
  end

  def local_authorities_by_name(name)
    get_json!("#{base_url}/local_authorities.json?name=#{CGI.escape(name)}")
  end

  def local_authorities_by_snac_code(snac_code)
    get_json!("#{base_url}/local_authorities.json?snac_code=#{CGI.escape(snac_code)}")
  end

  def licences_for_ids(ids)
    ids = ids.map(&:to_s).sort.join(',')
    get_json("#{@endpoint}/licences.json?ids=#{ids}")
  end

  def business_support_schemes(identifiers)
    identifiers = identifiers.map {|i| CGI.escape(i) }
    url_template = "#{base_url}/business_support_schemes.json?identifiers="
    response = nil # assignment necessary for variable scoping

    start_url = "#{url_template}#{identifiers.shift}"
    last_batch_url = identifiers.inject(start_url) do |url, id|
      new_url = [url, id].join(',')
      if new_url.length >= 2000
        # fetch a batch using the previous url, then return a new start URL with this id
        response = get_batch(url, response)
        "#{url_template}#{id}"
      else
        new_url
      end
    end
    get_batch(last_batch_url, response)
  end

  def get_list!(url)
    get_json!(url) { |r|
      GdsApi::ListResponse.new(r, self, web_urls_relative_to: @web_urls_relative_to)
    }
  end

  def get_list(url)
    get_json(url) { |r|
      GdsApi::ListResponse.new(r, self, web_urls_relative_to: @web_urls_relative_to)
    }
  end

  def get_json(url, &create_response)
    create_response = create_response || Proc.new { |r|
      GdsApi::Response.new(r, web_urls_relative_to: @web_urls_relative_to)
    }
    super(url, &create_response)
  end

  def get_json!(url, &create_response)
    create_response = create_response || Proc.new { |r|
      GdsApi::Response.new(r, web_urls_relative_to: @web_urls_relative_to)
    }
    super(url, &create_response)
  end

  private
    def base_url
      endpoint
    end

    def get_batch(batch_url, existing_response = nil)
      batch_response = get_json!(batch_url)
      if existing_response
        existing_response.to_hash["total"] += batch_response["total"]
        existing_response.to_hash["results"] += batch_response["results"]
        existing_response
      else
        batch_response
      end
    end
end
