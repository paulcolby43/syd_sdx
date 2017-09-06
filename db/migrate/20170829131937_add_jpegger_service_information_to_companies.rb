class AddJpeggerServiceInformationToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :jpegger_service_ip, :string
    add_column :companies, :jpegger_service_port, :string
  end
end
