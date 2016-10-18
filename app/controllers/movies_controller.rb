class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    sort_by = params[:sort_by] || session[:sort_by]

    case sort_by
    when 'title'
      ordering,@title_header = {:order => :title}, 'hilite'
    when 'release_date'
      ordering,@date_header = {:order => :release_date}, 'hilite'
    else
      ordering  = {:order => :title}
    end

    @all_ratings = Movie.all_ratings
    @selected_ratings = params[:ratings] || session[:ratings] || {}

    if params[:sort_by] != session[:sort_by]
      session[:sort_by] = sort_by
      redirect_to :sort_by => sort_by, :ratings => @selected_ratings and return
    end

    if params[:ratings] != session[:ratings] and @selected_ratings != {}
      session[:sort_by] = sort_by
      session[:ratings] = @selected_ratings
      redirect_to :sort_by => sort_by, :ratings => @selected_ratings and return
    end

    if @selected_ratings == {}
      @selected_ratings = Hash.new
      @all_ratings.each do |rating|
        @selected_ratings[rating] = 1
      end
    end

    @movies = Movie.order(ordering[:order])
    if(@selected_ratings.keys.any?)
      @movies = @movies.where(:rating => @selected_ratings.keys)
    end

  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
