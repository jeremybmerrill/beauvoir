Beauvoir
========

Guess a person's gender by their first name. Caveats apply.

Beauvoir uses more precise data sourced from [Open Gender Tracker](http://opengendertracking.org/)'s [Global Name Data](https://github.com/OpenGenderTracking/globalnamedata). Beauvoir lets you set avg and lower bounds and choose countries from which to draw data (so far US, UK only, more to come soon).

Caveats
-------

It's important to note that many people identify as neither a men nor a women. It's important, too, to note that many people who do identify as male or female have names that are held by far more people who identify as another gender. All of these people deserve not to be misgendered.

Nevertheless, automatically classifying people by apparent gender can be a very useful tool to perform censuses of communities or publications to detect and quantify perhaps-invisible bias. VIDA is a pioneer in this field, but their \"Count\" is limited by a manual methodology that depends hundreds of person-hours of labor. There is a place for more automated counts and Beauvoir can help, but if you plan to publish a count like this, you should be careful. You should probably set very high confidence thresholds to make sure you're very unlikely to misgender someone; you should also be prepared to be responsive and respectful if you do. You should include your methodology, prominently. You might consider emphasizing aggregate numbers over your mapping of individual people's names to genders.

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

b.femaleness_ratio("Sam")
=> 0.0103360994972961
b.maleness_ratio("Sam")
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
b.femaleness_ratio("Sam")
=> 0.010336099497296115
b.maleness_ratio("Sam")
=> 0.9896639005027039
````

Methodology
-----------
to come soon. email me if you need it asap.

Name
----
Beauvoir is named after [Simone de Beauvoir](http://en.wikipedia.org/wiki/Simone_de_Beauvoir), a feminist author best known for _The Second Sex), which Wikipeida describes as "a detailed analysis of women's oppression and a foundational tract of contemporary feminism."
