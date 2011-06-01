class Admin::CategoriesController < Admin::IndexController
  def index
    @categories = Category.ordered
  end
  
  def new
  end
  
  def create
  end
  
  def edit
  end
  
  def update
  end
  
  def destroy
  end
end
