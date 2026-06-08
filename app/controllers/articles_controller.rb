class ArticlesController < ApplicationController
  before_action :authenticate_user!, except: %i[ index show ]
  before_action :set_article, only: %i[ show edit update destroy report ]
  before_action :authorize_user!, only: %i[ edit update destroy ]

  # GET /articles or /articles.json
  def index
    if user_signed_in?
      @articles = Article.where(archived: false)
                         .where("public = ? OR user_id = ?", true, current_user.id)
    else
      @articles = Article.where(public: true, archived: false)
    end
  end

  # GET /articles/1 or /articles/1.json
  def show
    if @article.archived
      if user_signed_in? && @article.user == current_user
      else
        redirect_to articles_path, alert: "This article is archived and cannot be viewed."
      end
    elsif !@article.public
      if !user_signed_in? || @article.user != current_user
        redirect_to articles_path, alert: "You are not authorized to view this private article."
      end
    end
  end

  # GET /articles/new
  def new
    @article = current_user.articles.build
  end

  # GET /articles/1/edit
  def edit
  end

  # POST /articles or /articles.json
  def create
    @article = current_user.articles.build(article_params)

    respond_to do |format|
      if @article.save
        format.html { redirect_to @article, notice: "Article was successfully created." }
        format.json { render :show, status: :created, location: @article }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @article.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /articles/1 or /articles/1.json
  def update
    respond_to do |format|
      if @article.update(article_params)
        format.html { redirect_to @article, notice: "Article was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @article }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @article.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /articles/1 or /articles/1.json
  def destroy
    @article.destroy!

    respond_to do |format|
      format.html { redirect_to articles_path, notice: "Article was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  def report
    @article.reports_count += 1
    if @article.save
      if @article.archived?
        redirect_to articles_path, alert: "This article has been archived due to multiple reports."
      else
        redirect_to @article, notice: "Article was successfully reported."
      end
    else
      redirect_to @article, alert: "Failed to submit report."
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_article
      @article = Article.find(params.expect(:id))
    end

    def authorize_user!
      if @article.user != current_user
        redirect_to articles_path, alert: "You are not authorized to perform this action."
      end
    end

    # Only allow a list of trusted parameters through.
    def article_params
      params.expect(article: [ :title, :content, :public, :image ])
    end
end
