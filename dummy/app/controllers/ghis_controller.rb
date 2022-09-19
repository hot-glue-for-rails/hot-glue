class GhisController < ApplicationController
  helper :hot_glue
  include HotGlue::ControllerHelper

  before_action :authenticate_user!
  
  before_action :load_ghi, only: [:show, :edit, :update, :destroy]
  after_action -> { flash.discard }, if: -> { request.format.symbol ==  :turbo_stream }
 
  def load_ghi
    @ghi = (current_user.ghis.find(params[:id]))
  end
  

  def load_all_ghis 
    @ghis = ( current_user.ghis.page(params[:page]).includes(:dfg, :xyz))  
  end

  def index
    load_all_ghis
    respond_to do |format|
       format.html
    end
  end

  def new
    
    @ghi = Ghi.new()

   
    respond_to do |format|
      format.html
    end
  end

  def create
    modified_params = modify_date_inputs_on_params(ghi_params.dup)


    @ghi = Ghi.create(modified_params)

    if @ghi.save
      flash[:notice] = "Successfully created #{@ghi.name}"
      load_all_ghis
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to ghis_path }
      end
    else
      flash[:alert] = "Oops, your ghi could not be created. #{@hawk_alarm}"
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
    modified_params = modify_date_inputs_on_params(ghi_params, current_user)
      
 if @ghi.update(modified_params)
      flash[:notice] = (flash[:notice] || "") << "Saved #{@ghi.name}"
      flash[:alert] = @hawk_alarm if @hawk_alarm
    else
      flash[:alert] = (flash[:alert] || "") << "Ghi could not be saved. #{@hawk_alarm}"

    end

    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def destroy
    begin
      @ghi.destroy
    rescue StandardError => e
      flash[:alert] = "Ghi could not be deleted."
    end
    load_all_ghis
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to ghis_path }
    end
  end

  def ghi_params
    params.require(:ghi).permit( [:dfg_id, :xyz_id] )
  end

  def namespace
    ""
  end
end


