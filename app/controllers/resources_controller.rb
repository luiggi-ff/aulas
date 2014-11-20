class ResourcesController < ApplicationController
  before_action :authenticate_user!
  require 'rest_client'

  API_BASE_URL = "http://localhost:9292/" # base url of the API
  

  def index
    uri = "#{API_BASE_URL}/resources" # specifying json format in the URl
    rest_resource = RestClient::Resource.new(uri) # It will create
    #new rest-client resource so that we can call different methods of it
    resources = rest_resource.get # will get back you all the detail in json format, but it
    #will we wraped as string, so we will parse it in the next step.
    @resources = JSON.parse(resources, :symbolize_names => true)[:resources] # we will convert the return
    @resources.each do |r|
      url = r[:links].first[:uri]
      id = URI(url).path.split('/').last
      r[:id] = id
    end
    I18n.locale = :es
    #data into array of hash.see json data parsing here
  end

  def new

  end

  def create
    uri = "#{API_BASE_URL}/resources"
    payload = params#.to_json # converting the params to json
    rest_resource = RestClient::Resource.new(uri)
    begin
      rest_resource.post payload , :content_type => 'text/plain'
      flash[:notice] = "Resource Saved successfully"
      redirect_to resources_path # take back to index page, which now list the newly created user also
    rescue Exception => e
     flash[:error] = "Resource Failed to save"
     render :new
    end
  end



  def show
    uri = "#{API_BASE_URL}/resources/#{params[:id]}"
    rest_resource = RestClient::Resource.new(uri)
    resource = rest_resource.get
    @resource = JSON.parse(resource, :symbolize_names => true)[:resource]
  end

  def edit
    uri = "#{API_BASE_URL}/resources/#{params[:id]}" # specifying format as json so that 
                                                      #json data is returned 
    rest_resource = RestClient::Resource.new(uri)
    resource = rest_resource.get
    @resource = JSON.parse(resource, :symbolize_names => true)[:resource]
  end

  def update
    uri = "#{API_BASE_URL}/resources/#{params[:id]}"
    payload = params
    rest_resource = RestClient::Resource.new(uri)
    begin
      rest_resource.put payload , :content_type => 'text/plain'
      flash[:notice] = "Resource Updated successfully"
    rescue Exception => e
      flash[:error] = "Resource Failed to Update"
    end
    redirect_to resources_path
  end

  def destroy
    uri = "#{API_BASE_URL}/resources/#{params[:id]}"
    rest_resource = RestClient::Resource.new(uri)
    begin
     rest_resource.delete
     flash[:notice] = "Resource Deleted successfully"
    rescue Exception => e
     flash[:error] = "Resource Failed to Delete"
    end
    redirect_to resources_path
   end
 

end
