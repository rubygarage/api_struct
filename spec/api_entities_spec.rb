RSpec.describe ApiStruct do
  it "has a version number" do
    expect(ApiStruct::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
