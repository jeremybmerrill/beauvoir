Beauvoir
========

Beauvoir is a gem for guessing a person's gender by their first name. Caveats apply (see below)

Beauvoir uses more precise data sourced from [Open Gender Tracker](http://opengendertracking.org/)'s [Global Name Data](https://github.com/OpenGenderTracking/globalnamedata). Beauvoir lets you set avg and lower bounds and choose countries from which to draw data (so far US, UK only, maybe more to come later). Beauvoir is opinionated software designed to keep you from making common mistakes.

Caution
-------
This is pre-alpha software. The API will change, I guarantee it.

Usage and Caveats
-------

Beauvoir is *opinionated software*; unlike, say, Ruby on Rails, Beauvoir's "opinions" aren't about how to write software, but instead about how to conscientiously use the power of software to affect the analog world. 

It's important to note that [many people identify as neither a man nor a woman](https://www.genderspectrum.org/understanding-gender). It's important, too, to note that many people who do identify as male or female have names for which most other people with that name identify as a different gender. All of these people deserve not to be misgendered -- that is, publicly identified as a gender other than their own.

Nevertheless, performing censuses of communities or publications to detect and quantify perhaps-invisible bias can be a useful tool. [VIDA](link tk) is a pioneer in performing these censuses, but their "Count" is limited by a manual methodology that depends hundreds of person-hours of labor. There is a place for more automated counts and Beauvoir can help, but if you plan to publish a count like this, you should be careful. Common mistakes can include

  1. failing to account for a difference in names that overwhelmingly denote people of one gender ("John" or "Mary") from those that have only a slight tendency to denote people of one gender over another ("Pat", "Kendall"). If you have three people named Kendall in a data set, (absent any other information) it's more likely that one is a man and two are women; if you treated "Kendall" as a "female" name because a person named Kendall is more likely to identify as a woman than as a man, you might make the (incorrect) assumption that the three Kendalls are mostly likely three women.
  1. representing probabilities that a certain first name denotes a person of a certain gender with the "probable" gender of a single named individual. This is just a logic error -- and one that would likely misgender someone. Probabilities are properties of the population, e.g. all people in the United States, not of individuals. Suppose a person named Kendall wrote an article at a publication for which you were doing a census: it's not true that they have a 60% chance of being female -- this Kendall identifies as some gender with 100% probability.
  1. linking a estimated gender with a named individual publicly. This too could misgender someone, and more dangerously because of the power of search to publicly link them to a possibly-incorrect gender. Reducing statistical tendencies about a large group of people named "Kendall" to a conclusion about this specific person named Kendall is an error.

Beauvoir is designed to help you avoid these mistakes. The main tactic by which Beauvoir does this is by treating probabilities as a property of a group of names, not individual names. Beauvoir's primary methods take a list of at least three names and return ratios or counts of the likely gender makeup of the group of people denoted by those names.

````
require 'beauvoir'
b = Beauvoir::Categorizer.new
b.estimated_gender_ratio("Kendall", "Mary", "John")
=> {:male=>0.4674791746470981, :female=>0.5325208253529019}
````

In calculating counts -- that is, translating a name like "Mary" to a likely gender, "female" -- Beauvoir uses a high confidence threshold of 0.95. Beauvoir's confidence thresholds are set very high by default on purpose so that if you tried to translate "Kendall" to a likely gender, Beauvoir would return "unknown", not "female", because concluding that any given Kendall is a woman would likely be incorrect for about two out of every five people named "Kendall".

````
 b.ratio_of_guessed_genders("Kendall", "Mary", "John")
=> {:unknown=>0.33333333333, :female=>0.333333333333, :male=>0.333333333333}
````

Methodology
-----------
Beauvoir uses data from the [OpenGenderTracking project](https://github.com/opengendertracking/)'s [global name data](https://github.com/OpenGenderTracking/globalnamedata) set, which collects U.S. and U.K. name data from governmental sources. Beauvoir minimally reprocesses this data.

**A minimum estimated value**: a best guess of the ratio of genders of people with a given name; calculated using the [Agresti-Coull Binomial Confidence Interval](http://en.wikipedia.org/wiki/Binomial_proportion_confidence_interval#Agresti-Coull_Interval)
**A minimum lower confidence bound**: only 2.5 times out of a hundred (by default) with the _actual_ proportion of genders of people with this name fall below this bound. (It will be above outside the confidence interval 5% of the time, half of which is above and half of which is below. Ninety-five percent of the time, it will fall within the confidence interval. )
**Set a level of statistical significance** -- by default 0.95. The lower this level, the more likely the "true" parameter will fall outside the interval.

In the methods that classify a name as likely "male" or "female", an assumption I've made, but haven't tested yet, is that unclassifiable names will be evenly distributed between men and women (or, more precisely, would match the distribution of men and women in the data set). You could conclude from this, if it's true, that the actual gender ratio of the names Beauvoir couldn't classify will approximate the ratio of names Beauvoir could classify. The underlying assumption seems intuitively plausible, but might not be true; it's also eminently testable.

Name
----
Beauvoir is named after [Simone de Beauvoir](http://en.wikipedia.org/wiki/Simone_de_Beauvoir), a feminist author best known for _The Second Sex), which Wikipedia describes as "a detailed analysis of women's oppression and a foundational tract of contemporary feminism." Hopefully Beauvoir (the Gem) will have some effect by assisting computational efforts to shed light on gender bias and discrimination.

TODO
----
- Test A.C. Confidence Interval, Expected Value results against the ones in the source data. (The R is abstruse like a goose, so I'm not sure it's implemented right.)
- Can I come up with a way to add up the probabilities to get something better out of the unknowns? (i.e. if we're doing this over groups, not individual names, and we have three names that have a 66% chance of corresponding to women, can we say there's likely to be 2 women and 1 man?)
- reword the two arrays-only methods to use the words "continuous" and "discrete"

- similar: http://www.eigenfactor.org/gender/