class SearchesController < ApplicationController
  
  def index
    @searches = Search.group(:query).order('count_all DESC').count
  end

  def get_history
    @searches = current_user.searches.order(created_at: :desc)
  end

  def new
    @search = Search.new
  end

  def create
    @search = Search.new(search_params)
    @search.user = current_user
    unless @search.save
      render "new", status: :unprocessable_entity
    end
  end
end

private 

def search_params
  params.require(:search).permit(:query)
end
