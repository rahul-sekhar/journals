require 'spec_helper'

describe "pages/home.html.haml" do
  before do
    @profile = double(TeacherProfile).as_null_object
    @user = double(User)
    @user.stub(:profile).and_return(@profile)
    controller.stub(:current_user).and_return(@user)
  end

  
end