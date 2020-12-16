class YardsController < ApplicationController
  before_filter :login_required
#  before_action :set_yard, only: [:show, :edit, :update, :destroy]

  # GET /yards
  # GET /yards.json
  def index
    @yards = Yard.all(current_user.token)
  end

  # GET /yards/1
  # GET /yards/1.json
  def show
    @yard = Yard.find_by_id(current_user.token, params[:id])
    session[:yard_id] = params[:id]
    session[:yard_name] = @yard['Name']
    @currencies = Ticket.currencies(current_user.token)
    cookies[:current_currency_id] = params[:currency_id] unless params[:currency_id].blank?
    if current_user.mobile_admin?
      flash[:info] = "You can now customize the order of Event Codes! Go <strong><a href=#{edit_user_setting_path(current_user.user_setting.id)}>here</a></strong> to try it out.".html_safe
      redirect_to root_path
    elsif current_user.mobile_dispatch?
      redirect_to trips_path
    end
  end

  # GET /yards/new
  def new
    @yard = Yard.new
  end

  # GET /yards/1/edit
  def edit
  end

  # POST /yards
  # POST /yards.json
  def create
    @yard = Yard.new(yard_params)

    respond_to do |format|
      if @yard.save
        format.html { redirect_to @yard, notice: 'Yard was successfully created.' }
        format.json { render :show, status: :created, location: @yard }
      else
        format.html { render :new }
        format.json { render json: @yard.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /yards/1
  # PATCH/PUT /yards/1.json
  def update
    respond_to do |format|
      if @yard.update(yard_params)
        format.html { redirect_to @yard, notice: 'Yard was successfully updated.' }
        format.json { render :show, status: :ok, location: @yard }
      else
        format.html { render :edit }
        format.json { render json: @yard.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /yards/1
  # DELETE /yards/1.json
  def destroy
    @yard.destroy
    respond_to do |format|
      format.html { redirect_to yards_url, notice: 'Yard was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_yard
      @yard = Yard.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def yard_params
      params.require(:yard).permit(:yardname, :password)
    end
end
