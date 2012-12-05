require 'spec_helper'

describe "sessions/new.html.haml" do
  before do
    assign(:user, mock_model(User).as_new_record)
    render
  end

  it "has a title of 'Log in'" do
    view.content_for(:title).should match('Log in')
  end

  describe "the login form" do
    let(:form){ rendered.find 'form' }

    it "has a POST method" do
      form['method'].should == 'post'
    end

    it "does not have a method attribute" do
      form.should have_no_selector "input[name='_method']"
    end

    it "has the login url" do
      form['action'].should == login_path
    end

    it "has a submit button" do
      form.should have_selector "input[type='submit']"
    end

    it "has a username field" do
      form.should have_field 'user[username]', type: 'text'
    end

    it "has a password field" do
      form.should have_field 'user[password]', type: 'password'
    end
  end
end