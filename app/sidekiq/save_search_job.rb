class SaveSearchJob
  include Sidekiq::Job

  def perform(search_params, user_id)
    current_user = User.find_by(id: user_id)
    begin
      @search = Search.new(search_params)
      @search.user = current_user
      @search.save!
    rescue StandardError => e
      Rails.logger.error("SaveSearchJob failed: #{e.message}")
      raise e
    end
  end
end
