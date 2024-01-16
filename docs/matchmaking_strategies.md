# Matchmaking Strategies

Regardless of the strategy, there are some conditions that we must satisfy for the matchmaking to be considered adequate.

1. Participation is opt-in
2. Consecutive matches between individual participants should be rare

There is another tangentially related requirement, but its status as a requirement is fluid.

3. All encounters across groups contribute to the determination logic when matchmaking.

It's a little confusing at this point, so we'll come back to it.

Every matchmaking strategy receives a hash argument where each participant is a key and their respective value is a hash of all other participants with a score.

```ruby
{
    "Frodo" => {"Sam" => 3, "Merry" => 2, "Pippin" => 1},
    "Sam" => {"Frodo" => 3, "Merry" => 1, "Pippin" => 0},
    "Merry" => {"Frodo" => 2, "Sam" => 1, "Pippin" => 3},
    "Pippin" => {"Frodo" => 1, "Sam" => 0, "Merry" => 3}
}
```

Each score represents the number of times those participants were matched up. So, in the above example, Frodo met with Merry twice. When we get to determining the best match, to satisfy the second requirement above, we consider the available participants closest to 0. If we were to do it manually, we'd end up with either

- Frodo & Pippin, Sam & Merry
- Sam & Pippin, Frodo & Merry

Which groups are detemined depends on the strategy and, due to the stochastic nature of the algorithms, which participant is selected for a match first.

Once the participants have been matched, a `HistoricalMatch` record is created and on the next run, all the relevant `HistoricalMatch` records are taken into account to determine the new scores based on how many times a participant has been matched with every other participant.

## Pair by Fewest Encounters

This particular strategy has gone through a couple revisions. It was inspired by the [Stable Marriage Problem](https://en.wikipedia.org/wiki/Stable_marriage_problem) and the [Stable Roommates Problem](https://en.wikipedia.org/wiki/Stable_roommates_problem). It used to be the sole strategy, but it wasn't ideal for groups with more than 2 participants.

All this strategy does is select a random participant in the hash and then randomly select one of the participants with the lowest score. That is repeated until everyone has been matched. If the number of participants is odd, they final person is placed in the group that has the lowest sum between the already matched individuals.

## Arrange Groups Genetically

This strategy is for any group size and leverages a conceptual algorithm known as a ["genetic algorithm"](https://en.wikipedia.org/wiki/Genetic_algorithm). It implements a form of natural selection from evolutionary biology, and as the algorithm runs, it ideally converges to _an_ optimal solution. Due to it's stochastic nature, it cannot guarantee a global optimum with regards to solutions, but for our purposes it's good enough.

**Why though?**

Thanks for asking. Originally, we didn't use a genetic algorithm (GA) and simply adapted the Stable Marriage and Stable Roommates problem to accommodate groups of 3 or more. The adaptation was okay, but came with some drawbacks. One of those drawbacks was a violation of requirement 2 above because eventually, the final participants to be placed in a group were not always ideal since they could only choose the best that is available.

It became clear over time as people were matched consecutively that we needed something different for larger groups.

## Other strategies

The matchmaking was refactored into this strategy pattern primarily to support the two separate matchmaking approaches, but also to provide a way to experiment with other matchmaking methods in the future.
