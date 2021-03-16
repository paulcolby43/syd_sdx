class V2::ContractsController < ApplicationController
  before_filter :login_required  
  include ApplicationHelper

  # GET v2/contracts
  # GET v2/contracts.json
  def index
    authorize! :index, :contracts
    @q = params[:q]
    unless current_user.mobile_greeter?
      @yard_filter = "#{params[:yard_filter].blank? ? 'all_yards' : params[:yard_filter]}" # Default yard filter to all yards
    else
      @yard_filter = '1\my_yard' # Default yard filter to my yard for mobile_greeter
    end
    unless params[:q].blank?
      if @yard_filter == 'all_yards'
        filter = '{ "or": [{"contractNumber": {"eq":' + "#{@q.to_i}" + '}}, {"contractDescription": {"contains": "' + @q + '" }} ] }'
        @search = Contract.v2_all_by_filter(filter)
      else
        filter = '{"yardId": {"eq": "' +  current_yard_id + '"}, "or": [{"contractNumber": {"eq":' + "#{@q.to_i}" + '}}, {"contractDescription": {"contains": "' + @q + '" }} ] }'
        @search = Contract.v2_all_by_filter(filter)
      end
    end
    respond_to do |format|
      format.html {
        unless @search.blank?
          @contracts = Kaminari.paginate_array(@search).page(params[:page]).per(10)
        else
          @contracts = []
        end
      }
      format.json {
        unless search.blank?
          @contracts = @search.collect{ |contract| {id: contract.id, text: "#{contract.contract_description}"} }
        else
          @customers = nil
        end
        Rails.logger.info "results: {#{@contracts}}"
        render json: {results: @contracts}
      }
      format.js {
        unless @search.blank?
          @contracts = Kaminari.paginate_array(@search).page(params[:page]).per(10)
        else
          @contracts = []
        end
      }
    end
  end

  # GET v2/contracts/1
  # GET v2/contracts/1.json
  def show
    @contract = Contract.v2_find_by_id(params[:id])
    respond_to do |format|
      format.html { 
        if @contract.blank?
          flash[:danger] = "Not found."
          redirect_to root_path
        end
      }
      format.json { 
        unless @contract.blank?
          render json: JSON.pretty_generate(@contract.as_json) 
        else
          render json: { message: 'Not found.' }, status: :not_found
        end
        }
    end
  end
  
  def show_information
    authorize! :show_information, :contracts
    respond_to do |format|
      format.json {
        search = Contract.search_by_tag(current_user.token, current_yard_id, params[:tag_number])
        @contract = search.first unless search.blank?
        unless @contract.blank?
          render json: {"id" => @contract['Id'], "name" => @contract['PrintDescription'], "internal_contract_number" => @contract['InternalContractNumber'], 
            "tag_number" => @contract['TagNumber'], "gross" => @contract['GrossWeight'], "tare" => @contract['TareWeight'], 
            "net" => @contract['NetWeight'], "status" => @contract['Status'], "status_description" => contract_status_description(@contract['Status'])} 
        else
          render json: {message: "No contract found"}, status: :ok
        end
        } 
    end
  end

  # GET v2/contracts/new
  def new
  end

  # GET v2/contracts/1/edit
  def edit
    authorize! :edit, :contracts
    @status = "#{params[:status].blank? ? '0' : params[:status]}"
    @contract = Contract.find_by_id(current_user.token, current_yard_id, @status, params[:id])
  end

  # POST v2/contracts
  # POST v2/contracts.json
  def create
    @contract = Contract.new(contract_params)

    respond_to do |format|
      if @contract.save
        format.html { 
          flash[:success] = 'Contract was successfully created.'
          redirect_to edit_user_setting_path(current_user.user_setting)
#          redirect_to @contract
        }
        format.json { render :show, status: :created, location: @contract }
      else
        format.html { render :new }
        format.json { render json: @contract.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT v2/contracts/1
  # PATCH/PUT v2/contracts/1.json
  def update
    @contract = Contract.update(current_user.token, current_yard_id, contract_params)
    respond_to do |format|
      format.html {
        if @contract == 'true'
          flash[:success] = 'Contract List was successfully updated.'
        else
          flash[:danger] = 'Error updating Contract List.'
        end
        redirect_to contracts_path
      }
    end
  end

  # DELETE v2/contracts/1
  # DELETE v2/contracts/1.json
  def destroy
    @contract.destroy
    respond_to do |format|
      format.html { redirect_to contracts_url, notice: 'Contract was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def search_by_tag_number
    authorize! :search_by_tag_number, :contracts
    respond_to do |format|
      format.json {
        search = Contract.search_by_tag(current_user.token, current_yard_id, params[:q])
        unless search.empty?
#          @contracts = search.collect{ |contract| {id: contract['Id'], text: "#{contract['PrintDescription']}"} }
            @contracts = search.collect{ |contract| {id: contract['TagNumber'], text: "#{contract['PrintDescription']}"} }
          Rails.logger.info "results: {#{@contracts}}"
        else
          @contracts = []
        end
        render json: {results: @contracts}, :status => :ok
      }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contract
      @contract = Contract.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contract_params
      params.require(:contract).permit(:id, :description, :quantity, :net)
    end
end
