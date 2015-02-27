class MyFile

  def self.tesseract(patent,images)
    require 'open-uri'
    contents = []

    images.each_with_index do |f,i|

      file = File.open("tessdir/#{patent}-#{i}.jpg",'wb')
      file.write open("https:#{f}").read
      
      %x(tesseract tessdir/#{patent}-#{i}.jpg tessdir/#{patent}-#{i})
      
      file = File.open("tessdir/#{patent}-#{i}.txt", "rb")
      contents << {"#{i}" => file.read.split("\n").uniq.join(',').scan(/\d{3}[a-zA-Z]{1}|\d{3}|\d{2}[a-zA-Z]{1}|\d{2}|Fig[ .]{1,}\d{1,}[a-zA-Z]{0,}|Figure[ .]{1,}/i).uniq}
      %x(rm -fr tessdir/#{patent}-#{i}.txt)
    end

    File.open("tessdir/#{patent}.json", 'w') do |file| 
      file.write(contents.to_json)
    end
    if contents.present?
      create_s3("#{patent}.json")
    end

    %x(rm -fr tessdir/#{patent}.json)
    contents.to_json
  end

  def self.create_s3(filename)
    # upload to S3
    obj = $bucket.objects[filename]
    obj.write(Pathname.new("tessdir/#{filename}"))
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