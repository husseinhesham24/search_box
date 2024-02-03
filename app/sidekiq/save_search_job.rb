class SaveSearchJob
  include Sidekiq::Job

  def perform(search_params, user_id)
    current_user = User.find_by(id: user_id)
    @search = Search.new(search_params)
    @search.user = current_user
    @search.save
  end
end
