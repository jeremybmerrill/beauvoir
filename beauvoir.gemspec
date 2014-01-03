Gem::Specification.new do |s|
  s.name        = 'beauvoir'
  s.version     = '0.0.3'
  s.date        = '2014-01-02'
  s.summary     = "Guess a person's gender by their first name"
  s.description = "Guess gender by a first name using more detailed, better
                    sourced data from Open Gender Tracker's Global Name Data.<br />
                    Beauvoir lets you set avg and lower bounds and choose
                    countries from which to draw data. \n

                    It's important to note that many people identify as neither
                    a men nor a women. It's important, too, to note that many
                    people who do identify as male or female have names that<br />
                    are held by far more people who identify as another gender.
                    All of these people deserve not to be misgendered in public
                    (or in private).

                    Nevertheless, automatically classifying people by apparent
                    gender can be a very useful tool to perform censuses of
                    communities or publications to detect and quantify
                    perhaps-invisible bias. VIDA is a pioneer in this field,
                    but their \"Count\" is limited by a manual methodology that
                    depends hundreds of person-hours of labor. There is a place
                    for more automated counts and Beauvoir can help, but if you
                    do a count like this, you should be careful in how you word
                    your findings not to misgender anyone in particular and be
                    responsive to the possibility of errors."
  s.authors     = ["Jeremy B. Merrill"]
  s.email       = 'jeremybmerrill@jeremybmerrill.com'
  s.files       = ["lib/beauvoir.rb", "lib/beauvoir/name.rb", "lib/beauvoir/statistics.rb", "LICENSE", "README.md"] + Dir["lib/data/*.csv"] #todo: add data files
  s.homepage    =
    'http://rubygems.org/gems/beauvoir'
  s.license       = 'MIT'
end
