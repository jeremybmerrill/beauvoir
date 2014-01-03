Beauvoir
========

Beauvoir is a gem for guessing a person's gender by their first name. Caveats apply (see below)

Beauvoir uses more precise data sourced from [Open Gender Tracker](http://opengendertracking.org/)'s [Global Name Data](https://github.com/OpenGenderTracking/globalnamedata). Beauvoir lets you set avg and lower bounds and choose countries from which to draw data (so far US, UK only, more to come soon).

Caution
-------
This is pre-alpha software. The API will change, I guarantee it.

Caveats
-------

It's important to note that many people identify as neither a man nor a woman. It's important, too, to note that many people who do identify as male or female have names for which most other people with that name identify as a different gender. All of these people deserve not to be misgendered.

Nevertheless, automatically classifying people by apparent gender can be a very useful tool to perform censuses of communities or publications to detect and quantify perhaps-invisible bias. VIDA is a pioneer in performing theses censuses, but their \"Count\" is limited by a manual methodology that depends hundreds of person-hours of labor. There is a place for more automated counts and Beauvoir can help, but if you plan to publish a count like this, you should be careful. Beauvoir's confidence thresholds are set very high by default on purpose, you shouldn't lower them unless you take other steps to make sure that you're very unlikely to misgender someone; you should also be prepared to be responsive and respectful if you do. You should include your methodology, prominently. You might consider emphasizing aggregate numbers over your mapping of individual people's names to genders.

Usage
-----

Basic case:
````
require 'beauvoir'
b = Beauvoir.new

b.guess("John")
=> :male
b.guess("Mary")
=> :female
b.guess("Sam")
=> :unknown

b.estimated_female_value("Sam")
=> 0.0103360994972961
b.estimated_male_value("Sam")
=> 0.9896639005027039
````

Set other options.
````
require 'beauvoir'
b = Beauvoir.new(:country => :uk, :threshold => 0.95, :lower_threshold => 0.66)

b.guess("John")
=> :male
b.guess("Mary")
=> :female
b.guess("Sam")
=> :male

#the same as above
b.estimated_female_value("Sam")
=> 0.01034936186847522
b.estimated_male_value("Sam")
=> 0.9896506381315247
````

Methodology
-----------
to come soon. email me if you need it asap.

A minimum estimated value: a best guess of the ratio of genders of people with a given name.
A minimum lower confidence bound: only 2.5 times out of a hundred (by default) with the _actual_ proportion of genders of people with this name fall below this bound. (It will be above outside the confidence interval 5% of the time, half of which is above and half of which is below. Ninety-five percent of the time, it will fall within the confidence interval. )
Set a level of statistical significance -- by default 0.95. The lower this level, the more likely the "true" parameter will fall outside the interval.

Name
----
Beauvoir is named after [Simone de Beauvoir](http://en.wikipedia.org/wiki/Simone_de_Beauvoir), a feminist author best known for _The Second Sex), which Wikipedia describes as "a detailed analysis of women's oppression and a foundational tract of contemporary feminism." Hopefully Beauvoir (the Gem) will have some effect by assisting computational efforts to shed light on gender bias and discrimination.

TODO
----
- Test A.C. Confidence Interval, Expected Value results against the ones in the source data. (The R is abstruse like a goose, so I'm not sure it's implemented right.)