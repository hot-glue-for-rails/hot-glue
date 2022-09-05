class AbcsController < ApplicationController
  helper :hot_glue
  include HotGlue::ControllerHelper

  
  
  before_action :load_abc, only: [:show, :edit, :update, :destroy]
  after_action -> { flash.discard }, if: -> { request.format.symbol ==  :turbo_stream }
 
  def load_abc
    @abc = (Abc.find(params[:id]))
  end
  

  def load_all_abcs 
    @abcs = ( Abc.page(params[:page]))  
  end

  def index
    load_all_abcs
    respond_to do |format|
       format.html
    end
  end

  def new
    
    @abc = Abc.new()
   
    respond_to do |format|
      format.html
    end
  end

  def create
    modified_params = modify_date_inputs_on_params(abc_params.dup)


    @abc = Abc.create(modified_params)

    if @abc.save
      flash[:notice] = "Successfully created #{@abc.name}"
      load_all_abcs
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to abcs_path }
      end
    else
      flash[:alert] = "Oops, your abc could not be created. #{@hawk_alarm}"
      respond_to do |format|
        format.turbo_stream
        format.html
      end
    end
  end

  def show
    respond_to do |format|
      format.html
    end
  end

  def edit
    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def update
    modified_params = modify_date_inputs_on_params(abc_params)
      
 if @abc.update(modified_params)
      flash[:notice] = (flash[:notice] || "") << "Saved #{@abc.name}"
      flash[:alert] = @hawk_alarm if @hawk_alarm
    else
      flash[:alert] = (flash[:alert] || "") << "Abc could not be saved. #{@hawk_alarm}"

    end

    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def destroy
    begin
      @abc.destroy
    rescue StandardError => e
      flash[:alert] = "Abc could not be deleted."
    end
    load_all_abcs
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to abcs_path }
    end
  end

  def abc_params
    params.require(:abc).permit( [:name] )
  end

  def namespace
    ""
  end
end


