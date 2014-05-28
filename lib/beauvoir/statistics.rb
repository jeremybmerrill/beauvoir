require_relative './statistics'

module Beauvoir
  module Statistics
      # fancy statistics!

    #------------------
    # implements Agresti-Coull estimated proportion and binomial confidence interval
    # via:
    # - http://codesequoia.wordpress.com/2010/12/06/unit-test-and-statistics/
    # - http://stackoverflow.com/questions/3749125/how-should-i-order-these-helpful-scores/3752941#3752941
    # - http://www.stata.com/manuals13/rci.pdf, p. 10
    # the MAGIC_STATISTICS_NUMBER is apparently related to alpha and related to  
    # the level of statistical significance we care about.
    # 1.96 pertains to a 0.95 significance level.
    #
    MAGIC_STATISTICS_NUMBER = 1.96

    def self.z
      # TODO: https://github.com/clbustos/statsample/blob/1168d58b14a5095af0a639b4843b31433d40f105/lib/statsample/srs.rb
      MAGIC_STATISTICS_NUMBER
    end

    def estimated_female_proportion
      estimated_proportion(@female_count)
    end

    def estimated_male_proportion
      estimated_proportion(@male_count)
    end

    def max_estimated_proportion
      estimated_proportion([@male_count, @female_count].max)
    end

    #  returns lower bound of higher of male/female
    def lower
      nt = total + Statistics.z ** 2
      interval = Statistics.z * Math.sqrt(max_estimated_proportion * (1 - max_estimated_proportion) / nt)
      [raw_female_proportion, raw_male_proportion].max - interval
    end

    def estimated_proportion(observed)
      Statistics.estimated_proportion_formula(observed, total)
    end

    def self.estimated_proportion_formula(observed, total_count)
      #mimicing R, which appears to treat as a special case when x == 0 or x == n
      return 1 if observed == total_count 
      return 0 if observed == 0

      nt = total_count + (self.z ** 2)
      (observed + ((self.z ** 2) / 2)) / nt
    end
  end
end

  # p <- x/n
  # alpha <- 1 - conf.level
  # alpha <- rep(alpha, length = length(p))
  # alpha2 <- 0.5 * alpha
  # z <- qnorm(1 - alpha2)
  # z2 <- z * z

  # .x <- x + 0.5 * z2
  # .n <- n + z2
  # .p <- .x/.n
  # lcl <- .p - z * sqrt(.p * (1 - .p)/.n)
  # ucl <- .p + z * sqrt(.p * (1 - .p)/.n)
  # res.ac <- data.frame(method = rep("agresti-coull", NROW(x)),
  #                      xn, mean = p, lower = lcl, upper = ucl)
  # res <- res.ac