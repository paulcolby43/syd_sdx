class CustomersController < ApplicationController
  before_filter :login_required
#  before_action :set_customer, only: [:show, :edit, :update, :destroy]

  # GET /customers
  # GET /customers.json
  def index
    authorize! :index, :customers
    unless params[:q].blank?
      results = Customer.search(current_user.token, current_yard_id, params[:q])
    else
      results = Customer.all(current_user.token, current_yard_id)
    end
    unless results.blank?
      @customers = Kaminari.paginate_array(results).page(params[:page]).per(10)
    else
      @customers = []
    end
  end

  # GET /customers/1
  # GET /customers/1.json
  def show
    authorize! :show, :customers
    
    @customer = Customer.find_by_id(current_user.token, current_yard_id, params[:id])
    @cust_pics = CustPic.where(cust_nbr: @customer['Id'], yardid: current_yard_id)
    @customer_user = User.where(customer_guid: @customer['Id'], yard_id: current_yard_id).last
#    @paid_tickets = Ticket.search(3, current_user.token, current_yard_id, "#{@customer['Company']}")
    @paid_tickets = Customer.paid_tickets(current_user.token, current_yard_id, params[:id])
    if @customer_user.blank?
      @new_user = User.new
    end
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
  end

  # POST /customers
  # POST /customers.json
  def create
#    @customer = Customer.new(customer_params)
    @customer = Customer.create(current_user.token, current_yard_id, customer_params)
    respond_to do |format|
      format.html {
        if @customer == 'true'
          flash[:success] = 'Customer was successfully created.'
        else
          flash[:danger] = 'Error creating customer.'
        end
        redirect_to customers_path
      }
    end
  end

  # PATCH/PUT /customers/1
  # PATCH/PUT /customers/1.json
  def update
    @customer = Customer.update(current_user.token, current_yard_id, customer_params)
    respond_to do |format|
      format.html {
        if @customer == 'true'
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
        redirect_to edit_ticket_path(@guid, status: 2) 
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
