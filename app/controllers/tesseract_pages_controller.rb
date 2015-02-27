class TesseractPagesController < ApplicationController
  skip_before_filter :verify_authenticity_token 
  def run
    if params[:images]
      contents = MyFile.get_s3("#{params[:images][0].split('/')[0]}.json")
      unless contents
        contents = MyFile.tesseract(params[:images])
      end
    else
      contents = []
    end

    render json: {strings: contents}
  end

  def ping
    render json: {pong: true}
  end
end

