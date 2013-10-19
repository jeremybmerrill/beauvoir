

class Name
  attr_accessor :male_count, :female_count, :name

  def initialize(name)
    @male_count = 0
    @female_count = 0
    @name = name
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

  #implements Agresti-Coull binomial confidence interval, returns lower bound of higher of male/female
  # cf. http://codesequoia.wordpress.com/2010/12/06/unit-test-and-statistics/
  def lower
    nt = total + 1.96 ** 2
    pt = ([@male_count, @female_count].max + (1.96 ** 2) / 2) / nt
    e = 1.96 * Math.sqrt(pt * (1 - pt) / nt)
    [female_proportion, male_proportion].max - e
  end
end