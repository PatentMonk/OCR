class TesseractPagesController < ApplicationController
  skip_before_filter :verify_authenticity_token 
  def run
    require 'open-uri'
    contents = []
    params[:images].each_with_index do |f,i|
      file = File.open("tessdir/#{f.split('/')[0]}.jpg",'wb')
      file.write open("http://patentimages.storage.googleapis.com/#{f}.png").read
      
      %x(tesseract tessdir/#{f.split('/')[0]}.jpg tessdir/out)
      
      file = File.open("tessdir/out.txt", "rb")
      contents << {"#{i}" => file.read.scan(/\d{3}|Fig[ .]{1,}\d{1,}|Figure[ .]{1,}/i).uniq}
    end
    
    render json: {strings: contents}
  end
end
