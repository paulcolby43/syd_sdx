class CustomersController < ApplicationController
  before_filter :login_required
#  before_action :set_customer, only: [:show, :edit, :update, :destroy]

  # GET /customers
  # GET /customers.json
  def index
    unless params[:q].blank?
      results = Customer.search(current_token, current_yard_id, params[:q])
    else
      results = Customer.all(current_token, current_yard_id)
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
    @customer = Customer.find_by_id(current_token, params[:yard_id], params[:id])
    @cust_pics = CustPic.where(cust_nbr: @customer['Id'], yardid: current_yard_id)
#    @cust_pics = CustPic.where(cust_nbr: @customer['Id'], location: current_yard_id)
  end

  # GET /customers/new
  def new
    @customer = Customer.new
  end

  # GET /customers/1/edit
  def edit
  end

  # POST /customers
  # POST /customers.json
  def create
    @customer = Customer.new(customer_params)

    respond_to do |format|
      if @customer.save
        format.html { redirect_to @customer, notice: 'Customer was successfully created.' }
        format.json { render :show, status: :created, location: @customer }
      else
        format.html { render :new }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /customers/1
  # PATCH/PUT /customers/1.json
  def update
    respond_to do |format|
      if @customer.update(customer_params)
        format.html { redirect_to @customer, notice: 'Customer was successfully updated.' }
        format.json { render :show, status: :ok, location: @customer }
      else
        format.html { render :edit }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
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
    @customer = Customer.find_by_id(current_token, current_yard_id, params[:id])
#    @ticket_number = Ticket.next_available_number(current_token, current_yard_id)
    @guid = SecureRandom.uuid
    @ticket = Ticket.create(current_token, current_yard_id, @customer['Id'], @guid)
    respond_to do |format|
      format.html { 
        flash[:success] = 'Ticket was successfully created.'
        redirect_to edit_ticket_path(@guid, status: 'held') 
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
      params.require(:customer).permit(:customername, :password)
    end
end
