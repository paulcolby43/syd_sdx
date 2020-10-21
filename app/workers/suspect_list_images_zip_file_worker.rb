class SuspectListImagesZipFileWorker
  include Sidekiq::Worker
  
  def perform(suspect_list_id, yard_id)
    require 'zip'
    suspect_list = SuspectList.find(suspect_list_id)
    temp_file = Tempfile.new(["Suspect_List_#{suspect_list.name}_#{suspect_list.id}", '.zip'])
    begin
      Zip::OutputStream.open(temp_file.path) do |zos|
        suspect_list.csv_file_table.uniq.each do |row|
          ticket_number = row.first[1]
          images = Image.api_find_all_by_ticket_number(ticket_number, suspect_list.company, yard_id)
          images.each_with_index do |image, index|
            begin
              file_name = "ticket_#{ticket_number}/#{index+1}_ticket_#{ticket_number}_id_#{image['capture_seq_nbr']}#{Rack::Mime::MIME_TYPES.invert[image['content_type']]}"
              zos.put_next_entry(file_name)
              zos.print Down::NetHttp.open(Image.uri(image['azure_url'], suspect_list.company), ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).read
            rescue
              logger.debug "************ Suspect List zip file trying to download #{image['azure_url']} ********************"
            end
          end
        end
      end
      suspect_list.zip_file = temp_file
      suspect_list.save!
      UserMailer.new_suspect_list_zip_created(suspect_list).deliver
    ensure
      temp_file.close
      temp_file.unlink   # deletes the temp file
    end
  end
  
end