require 'csv'
require 'set'
require_relative './beauvoir/statistics'
require_relative './beauvoir/name'

module Beauvoir
  class Beauvoir
    DEFAULT_PROPORTION_THRESHOLD = 0.95
    DEFAULT_LOWER_CONFIDENCE_BOUND = 0.75
    MINIMUM_CODING_GROUP_SIZE = 3

    # these aren't writable because once a Beauvoir is initialized, since their
    # value is baked into Beauvoir's internal judgments of gender.
    attr_reader :threshold, :lower_confidence_bound, :names_by_names, :names_genders

    def initialize(options={})
      countries = Set.new([:us, :uk])

      @threshold = options[:threshold] || DEFAULT_PROPORTION_THRESHOLD

      # TODO: what should this be in the default case? (0, i.e. ignore the lower bound?, some sensical value to
      # exclude a naive user from getting back nonsense? the bare minimum value for a loose significance level?)
      @lower_confidence_bound = options[:lower_confidence_bound] || DEFAULT_LOWER_CONFIDENCE_BOUND

      @names_by_names = {}
      # @country_totals = {}
      @names_genders = {}

      if options[:country] && !options[:countries]
        countries &= Set.new([options[:country].to_sym])
      elsif options[:countries] && !options[:country]
        countries &= Set.new(options[:countries].map(&:to_sym))
      elsif options[:countries] && options[:country]
        raise ArgumentError, "Specify either :country or :countries, not both."
      end

      #TODO: consider "piecewise" loading with stashing of already-loaded names
      # to avoid ~10sec delay when loading into memory
      #(e.g. seeking around the file?)
      countries.each do |country|

        CSV.open(File.join(File.dirname(File.expand_path(__FILE__)), "data/#{country}processed.csv"), :headers => true).each do |row|
          name_str = self.class.normalize(row["Name"])
          name = @names_by_names.fetch(name_str, Name.new(name_str))
          name.male_count += row["count.male"].to_i
          name.female_count += row["count.female"].to_i
          @names_by_names[name_str] = name
        end
      end

      @names_by_names.values.each do |name|
        @names_genders[name.name] = name.guess_gender(@threshold, @lower_confidence_bound)
      end
      self
    end

    # def sufficiently_confident(name)
    #   (name.male_proportion > @threshold || name.female_proportion > @threshold) &&
    #     name.lower > @lower_confidence_bound
    # end

    #
    # Transform any name-like string into an unpadded, initial-cased first name.
    # Should be a surjection, mapping many possible inputs (e.g. "Jeremy", "Jeremy.", "JEREMY", "Jeremy B. Merrill")
    # onto one single name.
    # This is used for two things:
    # 1. Accepting differently-formatted/tokenized names from the user.
    # 2. Dealing with differently-formatted names from the source agencies (e.g. "Mckinley" v. "McKinley", "Obrien", vs. "O'brien")
    #
    def self.normalize(name)
      name.tr!("^A-Za-z' \-", '')
      name.strip!
      # name.gsub!(/[^A-Za-z \-\']+/, '') #this I suspect is done more efficiently with String#tr
      if name.include?(" ")
        name = name[0...name.index(" ")]
      end
      name[0].to_s.upcase + name[1..-1].to_s.downcase
    end

    # beauvoir_instance.guess_gender(["Jeremy", "Nathan", "Adam"])
    # => {:male=>0.9960086726125402, :female=>0.004007321921194168}
    # this method returns the sum of estimated proportions.
    def estimated_continuous_gender_ratio(*names)
      return {:unknown => names.size, :error => "Too few names as argument for estimated_continuous_gender_ratio" } if names.size < MINIMUM_CODING_GROUP_SIZE
      estimated_male_total = names.inject(0.0){|memo, name| memo + ((prop = estimated_male_proportion(name)).nil? ? 0.5 : prop) }
      {:male => estimated_male_total / names.size, :female => ((names.size - estimated_male_total) / names.size)}
    end

    # beauvoir_instance.guess_gender(["Jeremy", "Nathan", "Adam"])
    # => {:male => 3, :female => 0, :unknown => 0}
    def estimated_discrete_gender_counts(*names)
      # raise ArgumentError, "estimated_discrete_gender_counts needs at least two names as arguments" if names.size < MINIMUM_CODING_GROUP_SIZE
      return {:unknown => names.size } if names.size < MINIMUM_CODING_GROUP_SIZE
      result =names.each.with_object(Hash.new(0)){|e, h| h[guess_gender(e)] += 1}
      {:male => 0, :female => 0}.merge(result) #ensure :male and :female keys are both in the result
    end

    #convenience method, returns lots of stuff in one hash
    def gender_info(*names)
      counts = estimated_discrete_gender_counts(*names)
      ratios = estimated_continuous_gender_ratio(*names)
      info = {}
      ratios.keys.each do |gender|
        info[gender] = {:ratio => ratios[gender], :count => counts[gender]}
      end
      info[:total] = {:count => counts.values.inject(:+) }
      info
    end

    # convenience methods

    def estimated_continuous_gender_ratio_with_count(*names)
      ratios = estimated_continuous_gender_ratio(*names)
      ratios[:total] = names.size
      ratios
    end


    # beauvoir_instance.guess_gender(["Jeremy", "Kim", "Sam", "Mary])
    # => {:male => 0.25, :female => 0.25, :unknown => 0.5, :total => 4}
    def estimated_discrete_gender_ratio(*names)
      # raise ArgumentError, "ratio_of_guessed_genders needs at least two names as arguments" if names.size < MINIMUM_CODING_GROUP_SIZE
      return {:unknown => names.size } if names.size < MINIMUM_CODING_GROUP_SIZE
      estimated_discrete_gender_counts(*names).each_with_object({}){|(gender, count), memo| memo[gender] = count.to_f / names.size }
    end

    def ratio_of_guessed_genders_with_count(*names)
      ratios = ratio_of_guessed_genders(*names)
      ratios[:total] = names.size
      ratios
    end


    def inspect
      inspect_string = "#<#{self.class.name}:0x#{(self.object_id*2).to_s(16)} "
      exclude = [:@names_by_names, :@names_genders]
      fields = self.instance_variables - exclude
      inspect_string << fields.map{|field| "#{field}=#{instance_variable_get(field)}"}.join(", ") << ">"
      inspect_string
    end

    private
      def guess_gender(name)
        @names_genders.fetch(self.class.normalize(name), :unknown)
      end

      def estimated_male_proportion(name)
        if name_obj = @names_by_names[self.class.normalize(name)]
          name_obj.estimated_male_proportion
        else
          nil
        end
      end

      def estimated_female_proportion(name)
        if name_obj = @names_by_names[self.class.normalize(name)]
          name_obj.estimated_female_proportion
        else
          nil
        end
      end

      def raw_male_proportion(name)
        if name_obj = @names_by_names[self.class.normalize(name)]
          name_obj.raw_male_proportion
        else
          nil
        end
      end
      def raw_female_proportion(name)
        if name_obj = @names_by_names[self.class.normalize(name)]
          name_obj.raw_female_proportion
        else
          nil
        end
      end
  end
end
