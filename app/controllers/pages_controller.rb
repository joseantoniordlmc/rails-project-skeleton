class PagesController < ApplicationController
  def index
  end

  def search
    links = find_links(params[:subreddit])
    unless links
      flash[:alert] = 'No Links found or Incorrect Subreddit'
      return render action: :index
    end
  end

  private
  def request_api(subreddit)
    client_id = ENV["CLIENT_ID"]
    client_secret = ENV["CLIENT_SECRET_ID"]
    username = ENV["USERNAME"]
    password = ENV["PASSWORD"]
    url = 'https://www.reddit.com/api/v1/access_token'
    combo = "#{client_id}:#{client_secret}"
    combo_encoded = Base64.encode64(combo).strip
    headers = "Basic #{combo_encoded}" 
    body = "grant_type=password&username=#{username}&password=#{password}"
    conn = Faraday.new(
      url
    )
    response = conn.post do |req|
      req.url ''
      req.headers['Authorization'] = headers
      req.body = body
    end
    binding.pry
    
    response.response_body
  end

  def find_links(subreddit)
    request_api(subreddit)
  end
end
