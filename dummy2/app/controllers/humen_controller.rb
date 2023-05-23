class HumenController < ApplicationController
  # regenerate this controller with
  # rails generate hot_glue:scaffold Human --gd

  helper :hot_glue
  include HotGlue::ControllerHelper

  
  before_action :load_human, only: [:show, :edit, :update, :destroy]
  after_action -> { flash.discard }, if: -> { request.format.symbol == :turbo_stream }
   
  def load_human
    @human = Human.find(params[:id])
  end
  

  def load_all_humen
    @humen = Human.page(params[:page])
  end

  def index
    load_all_humen
  end

  def new
    @human = Human.new()
   
  end

  def create
 
    modified_params = modify_date_inputs_on_params(human_params.dup)

    @human = Human.create(modified_params) 
    if @human.save
      flash[:notice] = "Successfully created #{@human.name}"
      load_all_humen
      render :create
    else
      flash[:alert] = "Oops, your human could not be created. #{@hawk_alarm}"
      render :create, status: :unprocessable_entity
    end
  end


  def edit
    render :edit
  end

  def update
 
    modified_params = modify_date_inputs_on_params(human_params.dup)

    

    if @human.update(modified_params)
      
      flash[:notice] = (flash[:notice] || "") << "Saved #{@human.name}"
      flash[:alert] = @hawk_alarm if @hawk_alarm
      render :update
    else
      flash[:alert] = (flash[:alert] || "") << "Human could not be saved. #{@hawk_alarm}"
      render :update, status: :unprocessable_entity
    end
  end

  def destroy
    begin
      @human.destroy
    rescue StandardError => e
      flash[:alert] = 'Human could not be deleted.'
    end
    load_all_humen
  end

  def human_params
    params.require(:human).permit([:name])
  end

  def namespace
    
  end
end


