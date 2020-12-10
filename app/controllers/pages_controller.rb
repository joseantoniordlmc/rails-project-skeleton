class PagesController < ApplicationController
  #Con esto se transforma el código a hash de json
  require 'oj'
  
  #Muestra en la página
  def index
  end
  
  #Manda a llamar a la función que da el acces token
  def access_token
    #El @ es como un this.algo
    #Aquí se guardan todos los datos que mandó de respuesta cuando se pidió el token
    @response = request_access_token
    #Se guarda el puro token
    @access_token = @response["access_token"]
    #Se pone un mensaje en pantalla con el token en el index.html.erb se explica
    @message = "Your Access Token is #{@response}"
    #actualiza la página pero actualizada con la información
    render action: :index
  end

  #Manda a llamar la función que recibe el subreddit ingresado que se va a buscar para regresar la información guardada
  def search
    #se guarda la lista que se encontró en el subreddit
    @subreddit = list_subreddit(params[:subreddit])
    #Si no encuentra el subreddit pone el mensaje
    unless @subreddit
      @message = 'No Links found or Incorrect Subreddit'
    end
    render action: :index
  end

  #Manda a llamar a la función que regresa la info de un usuario
  def my_data
    #guarda la información de usuario
    response = get_my_data
    #Se guarda el puro nombre
    @name = response["name"]
    #Se guarda la imágen
    @image = response["icon_img"]
    #se guarda la url
    @url = response["subreddit"]["url"]
    #se guarda el tipo de usuario
    @user_type = response["subreddit"]["subreddit_type"]
    #igual actualiza
    render action: :index
  end
  
  #Manda a llamar a la función que busca el top 10 de un subreddit
  def list_subreddit(subreddit)
    #se guarda el token
    access_token = request_access_token["access_token"]
    #se guarda la info del subreddit
    @about = about(subreddit, access_token)
    #Guarda la info de los posts
    response = retrieve_posts(subreddit, access_token)
    #Guarda la info de los hijos del post tal cual
    @submissions = response["data"]["children"]
  end

  #De aquí en adelante se vuelven privadas las funciónes porque #BuenCódigo
  private

  #Pide el access token
  def request_access_token
    #Se trae y guarda la info del usuario desde el local_env.yml
    client_id = ENV["CLIENT_ID"]
    client_secret = ENV["CLIENT_SECRET_ID"]
    username = ENV["USERNAME"]
    password = ENV["PASSWORD"]
    #url para pedir el token
    url = 'https://www.reddit.com/api/v1/access_token'
    #Se codifica porque #Reddit el cliente y el secret id
    combo = "#{client_id}:#{client_secret}"
    combo_encoded = Base64.encode64(combo).strip
    headers = "Basic #{combo_encoded}" 
    #se pone el body de la url
    body = "grant_type=password&username=#{username}&password=#{password}"
    #Faraday es para hacer la conexión con el html del token 
    conn = Faraday.new(url)
    #Ya estando en la conexión se manda el resto de atributos que necesita para tener el acces token
    response = conn.post do |req|
      #no se modifica la url
      req.url ''
      #Se mandan las credenciales en Authoritzation
      req.headers['Authorization'] = headers
      #Se actualiza el body
      req.body = body
    end
    #Convierte la respuesta en hashes de json
    body = Oj.load(response.body)
  end

  #Recibe los datos de usuario
  def get_my_data
    access_token = request_access_token["access_token"]
    #Ahora se usará este tipo de url para acceder a la información con el acces token
    url = "https://oauth.reddit.com/api/v1/me"
    #Se guarda el acces token
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

  #Pide la info de un subreddit
  def about(subreddit,access_token)
    #Solo cambia la url nada más
    url = "https://oauth.reddit.com/r/#{subreddit}/about"
    headers = "Bearer #{access_token}" 
    conn = Faraday.new(url)
    response = conn.get do |req|
      req.url ''
      req.headers['Authorization'] = headers
    end

    body = Oj.load(response.body)
  end

  #Recibe el los post top 10 de un subreddit
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
