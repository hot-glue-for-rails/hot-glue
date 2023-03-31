require "spec_helper.rb"


describe HotGlue::Version do
  before(:each) do
    @version = HotGlue::Version::CURRENT
  end

  it "should be a major- syntax" do
    @version = HotGlue::Version::CURRENT
    split  = @version.split(".").collect(&:to_i)
    expect(split[0]).to be_kind_of(Numeric)
  end
  it "should be a point- syntax" do
    split  = @version.split(".").collect(&:to_i)
    expect(split[1]).to be_kind_of(Numeric)
  end

  it "should be a minor- syntax" do
    split  = @version.split(".").collect(&:to_i)
    expect(split[2]).to be_kind_of(Numeric)
  end

  it "should be before version 1 " do
    split  = @version.split(".").collect(&:to_i)
    expect(split[0]).to be(0)
  end
end
