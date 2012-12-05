module RSpec::CapybaraExtensions
  def rendered
    Capybara.string(@rendered)
  end
end