class MyFile

  def self.tesseract(images)
    require 'open-uri'
    contents = []

    images.each_with_index do |f,i|

      file = File.open("/tmp/#{f.split('/')[1]}.jpg",'wb')
      file.write open("http://patentimages.storage.googleapis.com/#{f}.png").read
      
      %x(tesseract /tmp/#{f.split('/')[1]}.jpg /tmp/#{f.split('/')[1]})
      
      file = File.open("/tmp/#{f.split('/')[1]}.txt", "rb")
      contents << {"#{i}" => file.read.split("\n").uniq.join(',').scan(/\d{3}[a-zA-Z]{1}|\d{3}|\d{2}[a-zA-Z]{1}|\d{2}|Fig[ .]{1,}\d{1,}[a-zA-Z]{0,}|Figure[ .]{1,}/i).uniq}
    end

    File.open("/tmp/#{f.split('/')[0]}.json", 'w') do |file| 
      file.write(contents.to_json)
    end
    if contents.present?
      create_s3("#{images[0].split('/')[0]}.json")
    end
    %x(rm -fr /tmp/#{images[0].split('/')[1]}.txt)
    %x(rm -fr /tmp/#{images[0].split('/')[0]}.json)
    contents.to_json
  end

  def self.create_s3(filename)
    # upload to S3
    obj = $bucket.objects[filename]
    obj.write(Pathname.new("/tmp/#{filename}"))
  end

  def self.get_s3(filename)
    # read from S3
    
    obj = $bucket.objects[filename]
    begin
      return obj.read
    rescue
      return false
    end
  end
end