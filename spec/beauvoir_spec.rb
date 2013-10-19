require './lib/beauvoir'

describe Beauvoir do
  it "should be initializable" do
    Beauvoir.new(:countries => :us)
  end


  context "once initialized" do
    before :all do
      @simone_no_low_threshold = Beauvoir.new(:countries => :us, :threshold => 0.99)
      @simone = Beauvoir.new(:countries => :us, :threshold => 0.99, :lower_threshold => 0.95)
    end

    it "should accept a quote-unquote simple confidence threshold" do
      @simone_no_low_threshold.threshold.should eql 0.99
      @simone_no_low_threshold.lower_threshold.should eql 0.5
    end


    it "should accept a more complex confidence threshold" do
      @simone.threshold.should eql 0.99
      @simone.lower_threshold.should eql 0.95
    end

    it "should normalize input strings to first names" do
      @simone.normalize("JerEmY k78321kj c[9 821 vc98  v\t\t\nasfasdf").should eql "Jeremy"
    end

    it "should return either :male or :female if confidence is within confidence thresholds" do
      @simone.guess("John").should eql :male
      @simone.guess("Mary").should eql :female
    end

    it "should return :unknown if confidence is not within confidence thresholds" do
      @simone.guess("Pat").should eql :unknown
    end

    it "should return the single-value gender ratio" do
      @simone.maleness_ratio("John").class.should eql Float
      @simone.femaleness_ratio("Mary").class.should eql Float
    end

    it "should use the complex confidence thresholds if both types are set" do
      @simone.guess("Aadison").should eql :unknown
    end

    it "should use only the estimated average if lower_threshold is unset" do

    end
  end
end