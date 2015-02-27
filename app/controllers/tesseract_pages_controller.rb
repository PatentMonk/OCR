class TesseractPagesController < ApplicationController
  skip_before_filter :verify_authenticity_token 
  def run
    contents = MyFile.get_s3("#{params[:patent]}.json")
    unless contents
      contents = MyFile.tesseract(params[:patent],params[:images])
    end

    render json: {strings: contents}
  end

  def ping
    render json: {pong: true}
  end
end
