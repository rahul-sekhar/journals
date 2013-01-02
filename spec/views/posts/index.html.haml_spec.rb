require 'spec_helper'

describe "posts/index.html.haml" do
  before do
    @profile = double(TeacherProfile).as_null_object
    @user = double(User)
    @user.stub(:profile).and_return(@profile)
    controller.stub(:current_user).and_return(@user)
    render
  end

  it "has a title of 'Viewing posts'" do
    view.content_for(:title).should match('Viewing posts')
  end
end