class Yard < ActiveResource::Base
#  self.headers['Authorization'] = 'Bearer token="abcd"'
  self.site = "https://71.41.52.58:50002/api/user/yard"
  Yard.headers['authorization'] = 'Bearer ' + "WgtnduHcDElnmytXjImJGOHMmp7x9rhXHsEMDJ5otawxEh1d2OMdj9oytvuUKZyxoZA3zldrOKxvoXy30TvmvZtSXRSY0B-T-33kdAENHsum1eR00JxMY6VjBv3wybKhGgSXN5HhvKS_8yTj7rnCcIy-qvF8PnR5_i8Gel5onH5me03ounKDUgGQoG-Jy9HdG3apIUUTZsVuIE6D2JjV2g"
  
#  def self.headers
#    { 'authorization' => "Bearer WgtnduHcDElnmytXjImJGOHMmp7x9rhXHsEMDJ5otawxEh1d2OMdj9oytvuUKZyxoZA3zldrOKxvoXy30TvmvZtSXRSY0B-T-33kdAENHsum1eR00JxMY6VjBv3wybKhGgSXN5HhvKS_8yTj7rnCcIy-qvF8PnR5_i8Gel5onH5me03ounKDUgGQoG-Jy9HdG3apIUUTZsVuIE6D2JjV2g"}
#  end
end