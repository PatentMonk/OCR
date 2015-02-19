class TesseractPagesController < ApplicationController
  skip_before_filter :verify_authenticity_token 
  def run
    require 'open-uri'
  	puts "In Run Controller"

    jpg = open("http://patentimages.storage.googleapis.com/#{params[:image]}.png").read
    
    puts "Creating directory"
    %x(mkdir tessdir)

    puts "Saving image"
    file = File.open("tessdir/sample.jpg",'wb')
  	file.write jpg
	  
    puts "Starting tesseract"
    %x(tesseract tessdir/sample.jpg tessdir/out -l #{params[:language]})
    
    puts "Reading result"
    file = File.open("tessdir/out.txt", "rb")
    contents = file.read
    
    puts "removing tessdir"
    %x(rm -Rf tessdir)
    
    render text: contents
  end
end
