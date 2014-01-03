require './lib/beauvoir'

describe Beauvoir do
  it "should be initializable" do
    Beauvoir::Categorizer.new(:country => :us)
  end


  context "once initialized" do
    before :all do
      @simone_low_threshold = Beauvoir::Categorizer.new(:country => :us, :threshold => 0.75, :lower_confidence_bound => 0.6)
      @simone = Beauvoir::Categorizer.new(:country => :us, :threshold => 0.99)
    end

    it "should accept a quote-unquote simple threshold" do
      @simone.threshold.should eql 0.99
      @simone.lower_confidence_bound.should eql 0.75
    end

    it "should accept a more complex lower threshold (i.e. lower confidence bound)" do
      @simone_low_threshold.threshold.should eql 0.75
      @simone_low_threshold.lower_confidence_bound.should eql 0.6
    end

    it "should normalize input strings to first names" do
      Beauvoir::Categorizer.normalize("Jer\nEmY k78321kj c[9 821 vc98  v\t\t\nasfasdf").should eql "Jeremy"
    end

    it "should return either :male or :female if confidence is within confidence thresholds" do
      @simone.guess("John").should eql :male
      @simone.guess("Mary").should eql :female
    end

    it "should return the single-value gender proportion" do
      @simone.male_proportion("John").class.should eql Float
      @simone.female_proportion("Mary").class.should eql Float
    end

    it "should return the single-value gender estimated values" do
      @simone.estimated_male_value("John").class.should eql Float
      @simone.estimated_female_value("Mary").class.should eql Float
    end

    it "should return :unknown if confidence is not within confidence thresholds" do
      @simone.guess("Pat").should eql :unknown
    end

    it "should use the complex thresholds to determine unknowns too" do
      @simone.guess("Dakota").should eql :unknown
      @simone_low_threshold.guess("Dakota").should eql :male
    end
  end
end