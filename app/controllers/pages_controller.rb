class PagesController < ApplicationController
  require 'oj'
  def index
  end

  def search
    @profile = false
    @subreddit = list_subreddit(params[:subreddit])
    unless @subreddit
      @message = 'No Links found or Incorrect Subreddit'
    end
    render action: :index
  end

  def access_token
    @response = request_access_token
    @access_token = @response["access_token"]
    @message = "Your Access Token is #{@response}"
    render action: :index
  end

  def my_data
    response = get_my_data
    @profile = true
    @name = response["name"]
    @image = response["icon_img"]
    @url = response["subreddit"]["url"]
    @user_type = response["subreddit"]["subreddit_type"]
    render action: :index
  end

  def list_subreddit(subreddit)
    access_token = request_access_token["access_token"]
    @about = about(subreddit, access_token)
    response = retrieve_posts(subreddit, access_token)
    @submissions = response["data"]["children"]
  end

  private

  def request_access_token
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
    body = Oj.load(response.body)
  end

  def get_my_data
    access_token = request_access_token["access_token"]
    url = "https://oauth.reddit.com/api/v1/me"
    headers = "Bearer #{access_token}" 
    conn = Faraday.new(
      url
    )

    response = conn.get do |req|
      req.url ''
      req.headers['Authorization'] = headers
    end
    body = Oj.load(response.body)
  end

  def about(subreddit,access_token)
    url = "https://oauth.reddit.com/r/#{subreddit}/about"
    headers = "Bearer #{access_token}" 
    conn = Faraday.new(url)
    response = conn.get do |req|
      req.url ''
      req.headers['Authorization'] = headers
    end
    body = Oj.load(response.body)
  end

  def retrieve_posts(subreddit, access_token)
    url = "https://oauth.reddit.com/r/#{subreddit}/top/.json?limit=10"
    headers = "Bearer #{access_token}" 
    conn = Faraday.new(url)
    response = conn.get do |req|
      req.url ''
      req.headers['Authorization'] = headers
    end
    body = Oj.load(response.body)
  end
end
