class ArticlesController < ApplicationController

  def index
    if params[:query].present?
      @articles = Article.where("title LIKE ? OR body LIKE ?", "%#{ActiveRecord::Base.sanitize_sql_like(params[:query])}%", "%#{ActiveRecord::Base.sanitize_sql_like(params[:query])}%")
    else
      @articles = Article.all
    end
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      flash[:notice] = "Article was created successfully."
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def article_params
    params.require(:article).permit(:title, :body)
  end
end
