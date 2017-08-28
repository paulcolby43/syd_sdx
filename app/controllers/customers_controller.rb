class CustomersController < ApplicationController
  before_filter :login_required
#  before_action :set_customer, only: [:show, :edit, :update, :destroy]

  # GET /customers
  # GET /customers.json
  def index
    authorize! :index, :customers
    unless params[:q].blank?
      search = Customer.search(current_user.token, current_yard_id, params[:q])
    else
      search = Customer.all(current_user.token, current_yard_id)
    end
    respond_to do |format|
      format.html {
        unless search.blank?
          @customers = Kaminari.paginate_array(search).page(params[:page]).per(10)
        else
          redirect_to new_customer_path(first_name: params[:first_name], last_name: params[:last_name], license_number: params[:license_number], dob: params[:dob],
            sex: params[:sex], issue_date: params[:issue_date], expiration_date: params[:expiration_date], streetaddress: params[:streetaddress], city: params[:city], state: params[:state], zip: params[:zip])
          @customers = []
        end
      }
      format.json {
#        @customers = Kaminari.paginate_array(results).page(params[:page]).per(10)
#        render json: @customers.map{|c| c['Id']}
#        @customers = results.map {|customer| ["#{customer['FirstName']} #{customer['LastName']}", customer['Id']]}
        unless search.blank?
          @customers = search.collect{ |customer| {id: customer['Id'], text: "#{customer['FirstName']} #{customer['LastName']} #{customer['Company']}"} }
        else
          @customers = nil
        end
        Rails.logger.info "results: {#{@customers}}"
        render json: {results: @customers}
      }
      format.js {
        unless search.blank?
          @customers = Kaminari.paginate_array(search).page(params[:page]).per(10)
        else
          redirect_to new_customer_path(first_name: params[:first_name], last_name: params[:last_name], license_number: params[:license_number], dob: params[:dob],
            sex: params[:sex], issue_date: params[:issue_date], expiration_date: params[:expiration_date], streetaddress: params[:streetaddress], city: params[:city], state: params[:state], zip: params[:zip])
          @customers = []
        end
      }
    end
  end

  # GET /customers/1
  # GET /customers/1.json
  def show
    authorize! :show, :customers
    
    @customer = Customer.find_by_id(current_user.token, current_yard_id, params[:id])
#    @cust_pics = CustPic.where(cust_nbr: @customer['Id'], yardid: current_yard_id) if CustPic.table_exists?
    @cust_pics_array = CustPic.api_find_all_by_customer_number(params[:id]) # Customer images
    @customer_user = User.where(customer_guid: @customer['Id'], yard_id: current_yard_id).last
#    @paid_tickets = Ticket.search(3, current_user.token, current_yard_id, "#{@customer['Company']}")
    @paid_tickets = Customer.paid_tickets(current_user.token, current_yard_id, params[:id])
#    if @customer_user.blank?
#      @new_user = User.new
#    end
#    @cust_pics = CustPic.where(cust_nbr: @customer['Id'], location: current_yard_id)
  end

  # GET /customers/new
  def new
    authorize! :create, :customers
    @customer = Customer.new
  end

  # GET /customers/1/edit
  def edit
    authorize! :edit, :customers
    @customer = Customer.find_by_id(current_user.token, current_yard_id, params[:id])
    @customer_user = User.where(customer_guid: @customer['Id'], yard_id: current_yard_id).last
    if @customer_user.blank?
      @new_user = User.new
    end
  end

  # POST /customers
  # POST /customers.json
  def create
#    @customer = Customer.new(customer_params)
    create_customer_response = Customer.create(current_user.token, current_yard_id, customer_params)
    respond_to do |format|
      format.html {
        if create_customer_response["Success"] == 'true'
          flash[:success] = 'Customer was successfully created.'
          redirect_to customer_path(create_customer_response['Item']['Id'])
#          redirect_to customers_path
        else
          flash[:danger] = 'Error creating customer.'
          redirect_to customers_path
        end
      }
    end
  end

  # PATCH/PUT /customers/1
  # PATCH/PUT /customers/1.json
  def update
    create_customer_response = Customer.update(current_user.token, current_yard_id, customer_params)
    respond_to do |format|
      format.html {
        if create_customer_response["Success"] == 'true'
          flash[:success] = 'Customer was successfully updated.'
        else
          flash[:danger] = 'Error updating customer.'
        end
        redirect_to customer_path(customer_params[:id])
      }
    end
  end

  # DELETE /customers/1
  # DELETE /customers/1.json
  def destroy
    @customer.destroy
    respond_to do |format|
      format.html { redirect_to customers_url, notice: 'Customer was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def create_ticket
    @customer = Customer.find_by_id(current_user.token, current_yard_id, params[:id])
#    @ticket_number = Ticket.next_available_number(current_user.token, current_yard_id)
    @guid = SecureRandom.uuid
    @ticket = Ticket.create(current_user.token, current_yard_id, @customer['Id'], @guid)
    respond_to do |format|
      format.html { 
        flash[:success] = 'Ticket was successfully created.'
        redirect_to edit_ticket_path(@guid, status: 2, commodity_id: params[:commodity_id]) 
        }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = Customer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def customer_params
      params.require(:customer).permit(:id, :first_name, :last_name, :company, :phone, :email, :address_1, :address_2, :city, :state, :zip, :tax_collection, 
        :id_number, :id_expiration, :id_state)
    end
end
