require './lib/beauvoir'

describe Beauvoir do
  it "should be initializable" do
    Beauvoir::Beauvoir.new(:country => :us)
  end


  context "once initialized" do
    before :all do
      @simone_low_threshold = Beauvoir::Beauvoir.new(:country => :us, :threshold => 0.75, :lower_confidence_bound => 0.6)
      @simone = Beauvoir::Beauvoir.new(:country => :us, :threshold => 0.99)
    end

    it "should return unknown with < MINIMUM_CODING_GROUP_SIZE argument for estimated_discrete_gender_counts" do
      @result = @simone.estimated_discrete_gender_counts("Jeremy", "Megan")
      @result.should_not have_key(:male)
      @result.should_not have_key(:female)
    end

    it "should return unknown with < MINIMUM_CODING_GROUP_SIZE argument for estimated_continuous_gender_ratio" do
      @result = @simone.estimated_discrete_gender_counts("Jeremy", "Megan")
      @result.should_not have_key(:male)
      @result.should_not have_key(:female)
    end

    it "should return integers as values for estimated_discrete_gender_counts" do
      @simone.estimated_discrete_gender_counts("Jeremy", "Megan", "Adam", "Nathan").values.each do |v|
        v.class == Integer
      end
    end

    it "should return floats as values for estimated_continuous_gender_ratio" do
      @simone.estimated_continuous_gender_ratio("Jeremy", "Megan", "Adam", "Nathan").values.each do |v|
        v.class == Float
      end
    end

    it "should return both male and female as keys for estimated_discrete_gender_counts" do
      @result = @simone.estimated_discrete_gender_counts("Jeremy", "Adam", "Nathan")
      @result.should have_key(:male)
      @result.should have_key(:female)
    end

    it "should return both male and female as keys for estimated_continuous_gender_ratio" do
      @result = @simone.estimated_continuous_gender_ratio("Jeremy", "Adam", "Nathan")
      @result.should have_key(:male)
      @result.should have_key(:female)
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
      Beauvoir::Beauvoir.normalize("Jer\nEmY k78321kj c[9 821 vc98  v\t\t\nasfasdf").should eql "Jeremy"
    end

    it "should return either :male or :female if confidence is within confidence thresholds" do
      @simone.send(:guess_gender, "John").should eql :male
      @simone.send(:guess_gender, "Mary").should eql :female
    end

    it "should return the single-value gender proportion" do
      @simone.send(:raw_male_proportion, "John").class.should eql Float
      @simone.send(:raw_female_proportion, "Mary").class.should eql Float
    end

    it "should return the single-value gender estimated values" do
      @simone.send(:estimated_male_value, "John").class.should eql Float
      @simone.send(:estimated_female_value, "Mary").class.should eql Float
    end

    it "should return :unknown if confidence is not within confidence thresholds" do
      @simone.send(:guess_gender, "Pat").should eql :unknown
    end

    it "should use the complex thresholds to determine unknowns too" do
      @simone.send(:guess_gender, "Dakota").should eql :unknown
      @simone_low_threshold.send(:guess_gender, "Dakota").should eql :male
    end
  end
end