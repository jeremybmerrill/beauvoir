require_relative './statistics'

module Beauvoir
  module Statistics
      # fancy statistics!
    #------------------
    # implements Agresti-Coull estimated value and binomial confidence interval
    # via:
    # - http://codesequoia.wordpress.com/2010/12/06/unit-test-and-statistics/
    # - http://stackoverflow.com/questions/3749125/how-should-i-order-these-helpful-scores/3752941#3752941
    # -
    # the MAGIC_STATISTICS_NUMBER is apparently related to alpha and related to  
    # the level of statistical significance we care about.
    # 1.96 pertains to a 0.95 significance level.
    #
    MAGIC_STATISTICS_NUMBER = 1.96

    def z
      # TODO: https://github.com/clbustos/statsample/blob/1168d58b14a5095af0a639b4843b31433d40f105/lib/statsample/srs.rb
      #@significance_level #do stuff with this.
      MAGIC_STATISTICS_NUMBER
    end

    def estimated_female_value
      estimated_value_formula(@female_count)
    end

    def estimated_male_value
      estimated_value_formula(@male_count)
    end

    def estimated_value
      estimated_value_formula([@male_count, @female_count].max)
    end

    #  returns lower bound of higher of male/female
    def lower
      nt = total + z ** 2
      interval = z * Math.sqrt(estimated_value * (1 - estimated_value) / nt)
      [female_proportion, male_proportion].max - interval
    end

    def estimated_value_formula(observed)
      nt = total + z ** 2
      (observed + ((z ** 2) / 2)) / nt
    end
  end
end