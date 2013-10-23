

class Name
  attr_accessor :male_count, :female_count, :name

  def initialize(name, options={})
    default_options = {
      :significance_level => 0.95,
    }
    @options = default_options.merge(options)

    @male_count = 0
    @female_count = 0
    @name = name
    @significance_level = @options[:significance_level]
  end

  def male?
    @male_count > @female_count
  end

  def female?
    @female_count > @male_count
  end

  def gender
    female? ? :female : male? ? :male : :unknown #oh god this is unreadable
  end

  def female_proportion
    return 0 unless self.total > 0
    @female_count / self.total
  end

  def male_proportion
    return 0 unless self.total > 0
    @male_count / self.total
  end

  def total
    (@male_count + @female_count).to_f
  end

  # fancy statistics!
  #------------------
  # implements Agresti-Coull estimated value and binomial confidence interval
  # via:
  # - http://codesequoia.wordpress.com/2010/12/06/unit-test-and-statistics/
  # - http://stackoverflow.com/questions/3749125/how-should-i-order-these-helpful-scores/3752941#3752941
  # -

  #this is apparently related to alpha and related to the level of statistical significance we care about.
  # 1.96 pertains to a 0.90 significance level?
  #
  AGRESTI_COULL_MAGIC_NUMBER = 1.96

  def z
    # TODO: https://github.com/clbustos/statsample/blob/1168d58b14a5095af0a639b4843b31433d40f105/lib/statsample/srs.rb
    @significance_level #do stuff with this.
    AGRESTI_COULL_MAGIC_NUMBER
  end

  def estimated_value
    observed = [@male_count, @female_count].max
    nt = total + @z ** 2
    (observed + ((@z ** 2) / 2)) / nt
  end

  #  returns lower bound of higher of male/female
  def lower
    interval = @z * Math.sqrt(estimated_value * (1 - estimated_value) / nt)
    [female_proportion, male_proportion].max - interval
  end
end