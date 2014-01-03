
module Beauvoir
  class Name
    include Beauvoir::Statistics
    attr_accessor :male_count, :female_count, :name

    def initialize(name, options={})
      # default_options = {
      #   :significance_level => 0.95,
      # }
      @options = options #default_options.merge(options)

      @male_count = 0
      @female_count = 0
      @name = name
      # @significance_level = @options[:significance_level]
    end

    def guess_gender(threshold=DEFAULT_PROPORTION_THRESHOLD, lower_confidence_bound=DEFAULT_LOWER_CONFIDENCE_BOUND)
      if sufficiently_confident(threshold, lower_confidence_bound)
        gender
      else
        :unknown
      end
    end

    def raw_female_proportion
      return 0 unless self.total > 0
      @female_count / self.total
    end

    def raw_male_proportion
      return 0 unless self.total > 0
      @male_count / self.total
    end

    def total
      (@male_count + @female_count).to_f
    end

    private
      # These methods are private for a reason.
      # You should use the guess_gender method instead.
      # (See README.md for more discussion.)
      def female?
        #pure proportions, so even the slightest greater proportion of one gender will affect this
        @female_count > @male_count
      end

      def male? 
        #pure proportions, so even the slightest greater proportion of one gender will affect this
        @male_count > @female_count
      end

      def gender
        if female?
          :female
        elsif male?
          :male
        else
          :unknown
        end
      end

      def sufficiently_confident(threshold=DEFAULT_PROPORTION_THRESHOLD, lower_confidence_bound=DEFAULT_LOWER_CONFIDENCE_BOUND)
        (raw_male_proportion > threshold || raw_female_proportion > threshold) &&
          lower > lower_confidence_bound
      end
  end
end