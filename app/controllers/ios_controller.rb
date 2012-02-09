
class IosController < ApplicationController
  include IpHelper

  def ios
      application_host = "#{local_ip}:#{ request.port }" if Rails.env == "development"
      application_host = request.hostname if Rails.env != "development"

      content = open( Rails.root.join("public", "basic.mobileconfig") ).read
      token = SecureRandom.hex(16) 
      
      content = content.sub!( "optional challenge", token )
      content = content.sub!( "URL_STRING_TO_REPLACE",  "http://#{ application_host }/ios_register" )

      tempfile = Tempfile.new([ token , '.mobileconfig'])
      tempfile.write( content )
      tempfile.close

      send_file open( tempfile )
  end

  def ios_register
    device_info = request.body.read

    udid = /<key>UDID<\/key>\s*<string>(.*)<\/string>/.match( device_info ) 
    token = /<key>CHALLENGE<\/key>\s*<string>(.*)<\/string>/.match( device_info )
    
    redirect_to action: "show", udid: udid[1], token: token[1] , status: 301  
  end

  def show
    @udid = params[:udid]
    @token = params[:token]
  end

  

end
