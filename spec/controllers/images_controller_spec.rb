require 'spec_helper'

describe ImagesController, :focus do
  let(:user){ create(:teacher_with_user).user }
  let(:ability) do
    ability = Object.new
    ability.extend(CanCan::Ability)
  end
  before do
    controller.stub(:current_user).and_return(user)
    controller.stub(:current_ability).and_return(ability)
    ability.can :manage, Image
  end

  describe "POST create" do
    before do
      @image = mock_model(Image).as_null_object
      Image.stub(:new).and_return(@image)
    end
    let(:make_request){ post :create, files: ["some image"], format: :json }

    context "with valid data" do
      it "raises an exception if the user cannot create an image" do
        ability.cannot :create, Image
        expect{ make_request }.to raise_exception(CanCan::AccessDenied)
      end

      it "sets the file_name" do
        @image.should_receive(:file_name=)
        make_request
      end

      it "creates an image with the data passed" do
        @image.should_receive(:save)
        make_request
      end

      it "has a status of 200" do
        make_request
        response.status.should eq(200)
      end
    end

    context "with invalid data" do
      before do
        @image.stub(:save).and_return(false)
      end

      it "has a status of 422" do
        make_request
        response.status.should eq(422)
      end
    end
  end
end