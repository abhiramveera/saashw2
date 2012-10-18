class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    sort = params[:order_by] || session[:order_by]
    case sort
    when 'title'
      ordering = {:order => :title}
    when 'release_date'
      ordering = {:order => :release_date}
    else
      ordering = nil
    end
    @all_ratings = Movie.select(:rating).map(&:rating).uniq.sort
    @selected_rating = params[:ratings] || session[:ratings] || {}

    if @selected_rating == {}
       @selected_rating = {"G" =>1, "PG"=>1, "PG-13"=>1, "R"=>1}     
    end   
    
    if params[:order_by] != session[:order_by]
       session[:order_by] = sort
       flash.keep
       redirect_to :order_by => sort, :ratings => @selected_rating and return
    end

    if params[:ratings] != session[:ratings]
       session[:order_by] = sort
       session[:ratings] = @selected_rating
       flash.keep
       redirect_to :order_by => sort, :ratings => @selected_rating and return
    end 

    @movies = Movie.find_all_by_rating(@selected_rating.keys, ordering)
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
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
