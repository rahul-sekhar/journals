shared_examples_for "a paginated page" do
  before do
    create_items(5)
    controller.stub(:per_page_default).and_return(3)
  end

  it "assigns ten elements for the first page" do
    make_request
    assigns(item_list_name).length.should == 3
  end

  it "assigns a total number of pages for the first page" do
    make_request
    assigns(:total_pages).should == 2
  end

  it "defaults to the first page if the page parameter is 0" do
    make_request(0)
    assigns(:page).should == 1
  end

  it "defaults to the first page if the page parameter is negative" do
    make_request(-1)
    assigns(:page).should == 1
  end      

  it "assigns five elements for the second page" do
    make_request(2)
    assigns(item_list_name).length.should == 2
  end

  it "assigns a total number of pages for the second page" do
    make_request(2)
    assigns(:total_pages).should == 2
  end

  it "assigns the page number for the second page" do
    make_request(2)
    assigns(:page).should == 2
  end

  it "assigns the correct total number of pages for an exact match" do
    create_items(1)
    make_request(2)
    assigns(:total_pages).should == 2
    assigns(item_list_name).length.should == 3
  end

  it "assigns an empty collection for a page that is too high" do
    make_request(3)
    assigns(item_list_name).should be_empty
    assigns(:total_pages).should == 2
  end
end