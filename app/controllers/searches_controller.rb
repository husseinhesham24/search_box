class SearchesController < ApplicationController
  
  def index
    @searches = Search.group(:query).order('count_all DESC').count
  end

  def get_history
    @searches = current_user.searches.order(created_at: :desc)
  end

  def create
    SaveSearchJob.perform_async(search_params.to_h, current_user.id)
  end
end

private 

def search_params
  params.require(:search).permit(:query)
end
