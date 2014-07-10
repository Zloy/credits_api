require "credits_api/engine"

module CreditsApi
  mattr_accessor :user_class, :name_attr

  # @param[String] id_str - checks if user with id exists
  # @return[Boolean]
  #
  def self.check_id id_str
    id = Utils.cast_int id_str
    (id && id > 0 && self.user_class.exists?(id)) ? id : nil
  end
end
