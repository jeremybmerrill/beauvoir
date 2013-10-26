require 'csv'
require 'set'
require_relative './name'

class Beauvoir
  DEFAULT_PROPORTION_THRESHOLD = 0.99
  DEFAULT_LOWER_CONFIDENCE_BOUND = 0.75


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
        name_str = Beauvoir.normalize(row["Name"])
        name = @names_by_names.fetch(name_str, Name.new(name_str))
        name.male_count += row["count.male"].to_i
        name.female_count += row["count.female"].to_i
        @names_by_names[name_str] = name
      end
    end

    @names_by_names.values.each do |name|
      @names_genders[name.name] = if sufficiently_confident(name)
                                    name.gender
                                  else
                                    :unknown
                                  end
    end
    self
  end

  def sufficiently_confident(name)
    (name.male_proportion > @threshold || name.female_proportion > @threshold) &&
      name.lower > @lower_confidence_bound
  end

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
    # name.gsub!(/[^A-Za-z \-\']+/, '') #this I suspect is done more efficiently with String#tr
    if name.include?(" ")
      name = name[0...name.index(" ")]
    end
    name[0].upcase + name[1..-1].downcase
  end

  def guess(name)
    @names_genders.fetch(Beauvoir.normalize(name), :unknown)
  end

  def estimated_male_value(name)
    if name_obj = @names_by_names[Beauvoir.normalize(name)]
      name_obj.estimated_male_value
    else
      nil
    end
  end

  def estimated_female_value(name)
    if name_obj = @names_by_names[Beauvoir.normalize(name)]
      name_obj.estimated_female_value
    else
      nil
    end
  end

  def male_proportion(name)
    if name_obj = @names_by_names[Beauvoir.normalize(name)]
      name_obj.male_proportion
    else
      nil
    end
  end
  def female_proportion(name)
    if name_obj = @names_by_names[Beauvoir.normalize(name)]
      name_obj.female_proportion
    else
      nil
    end
  end
end