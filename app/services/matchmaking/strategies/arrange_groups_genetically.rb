module Matchmaking
  module Strategies
    # This strategy uses a genetic algorithm to arrange participants into groups of a target size. It expects a hash of
    # participants and their scores for each other participant. The scores are used to determine the fitness of a given
    # solution.
    #
    # The algorithm works by creating a population of random solutions and then selecting the best solutions to create
    # offspring. The offspring are then mutated and added to the population. This process is repeated for a number of
    # generations. The best solution is then returned.
    #
    # The fitness of a solution is determined by the total score of each pairing of participants in the solution. The
    # total score is negated to ensure that the best solution has the highest fitness.
    #
    # A tournament selection process is used to select the parents for the next generation. The tournament size is set
    # to 5% of the population size. This means that 5% of the population is randomly selected and the best solution is
    # chosen as a parent. This process is repeated to select the second parent.
    #
    # The population_size and generations parameters can be used to tune the algorithm. The population_size determines
    # the number of solutions that are created for each generation. The generations parameter determines the number of
    # times the algorithm will create offspring and mutate the population.
    #
    # A target_group_size parameter is always required. This parameter determines the size of the groups that the
    # participants will be arranged into.
    #
    # Input example:
    #   {
    #    "Alice" => {"Bob" => 1, "Charlie" => 0, "Dave" => 2, "Eve" => 1},
    #    "Bob" => {"Alice" => 1, "Charlie" => 3, "Dave" => 1, "Eve" => 2},
    #    "Charlie" => {"Alice" => 0, "Bob" => 3, "Dave" => 2, "Eve" => 3},
    #    "Dave" => {"Alice" => 2, "Bob" => 1, "Charlie" => 2, "Eve" => 1},
    #    "Eve" => {"Alice" => 1, "Bob" => 2, "Charlie" => 3, "Dave" => 1}
    #   }
    #
    # Output example:
    #   [["Dave", "Bob", "Eve"], ["Alice", "Charlie"]]
    class ArrangeGroupsGenetically
      def initialize(target_group_size:, population_size: 100, generations: 100)
        @target_group_size = target_group_size
        @population_size = population_size
        @generations = generations

        @balance_groups = BalanceGroups.new
      end

      def call(scored_participants)
        return [] if scored_participants.size < 2

        @participants = scored_participants.keys
        @scored_participants = scored_participants

        population = Array.new(@population_size) { random_solution }

        @generations.times do
          p1, p2 = select_parents(population)

          offspring = crossover(p1, p2)
          mutated_offspring = offspring.map { |child| mutate(child) }

          population = select_next_generation(population, mutated_offspring)
        end

        best_solution(population)
      end

      private

      def best_solution(population)
        population.max_by { |individual| fitness(individual) }
      end

      def mutate(solution)
        return solution if solution.empty?

        # Randomly select two groups to mutate
        group_indices = (0...solution.size).to_a.sample(2)
        group1_idx, group2_idx = group_indices

        # Randomly select one participant from each group
        participant1_idx = rand(solution[group1_idx].size)
        participant2_idx = rand(solution[group2_idx].size)

        solution.map.with_index do |group, idx|
          case idx
          when group1_idx
            # Swap participant with one from group2
            group.dup.tap { |g| g[participant1_idx] = solution[group2_idx][participant2_idx] }
          when group2_idx
            # Swap participant with one from group1
            group.dup.tap { |g| g[participant2_idx] = solution[group1_idx][participant1_idx] }
          else
            group.dup
          end
        end
      end

      def crossover(parent1, parent2)
        return [parent1.dup, parent2.dup] if parent1.empty? || parent2.empty? || parent1.size != parent2.size

        crossover_point = rand([parent1.size, parent2.size].min)

        new_parent1 = parent1.dup
        new_parent2 = parent2.dup
        # Swap the whole group. This will likely violate the determinants of matchmaking, namely that each
        # participant exist in exactly one group. The rest of the method will fix this.
        new_parent1[crossover_point], new_parent2[crossover_point] = new_parent2[crossover_point], new_parent1[crossover_point]

        # The fix here is to identify any participants that are duplicated and replace them with participants that are
        # missing from groups. This ensures that each participant exists in exactly one group. The only group that remains
        # unchanged is the one that was swapped. By leaving that group unchanged, the crossover point is maintained so
        # the offspring has something from each parent.
        offspring1 = fix_duplicates(new_parent1, crossover_point, parent1 + parent2)
        offspring2 = fix_duplicates(new_parent2, crossover_point, parent1 + parent2)

        [offspring1, offspring2]
      end

      def fix_duplicates(offspring, crossover_point, all_groups)
        all_participants = all_groups.flatten.uniq
        existing_participants = offspring.flatten

        missing = all_participants - existing_participants
        duplicated = existing_participants.tally.select { |p, c| c > 1 }.keys

        offspring.map.with_index do |group, idx|
          next group if idx == crossover_point

          group.map do |participant|
            if duplicated.include?(participant)
              duplicated.delete(participant)
              missing.shift
            else
              participant
            end
          end
        end
      end

      def fitness(solution)
        total_score = 0

        # Total the scores for each pairing of participants in the solution
        solution.each do |group|
          group.combination(2).each do |pair|
            total_score += @scored_participants[pair.first][pair.last]
          end
        end

        # The total is being negated to ensure that the best solution has the highest fitness
        -total_score
      end

      def select_next_generation(current_population, offspring)
        # Ensure population size is maintained by selecting the participants with the highest fitness
        combined_population = current_population + offspring
        sorted_by_fitness = combined_population.sort_by { |individual| fitness(individual) }
        sorted_by_fitness.last(@population_size)
      end

      def random_solution
        # The participants are shuffled to ensure that the first group is not always the same
        shuffled_participants = @participants.shuffle
        @balance_groups.call(shuffled_participants, @target_group_size)
      end

      def select_parents(population)
        parents = []

        2.times do
          tournament = population.sample(tournament_size)
          best = tournament.max_by { |solution| fitness(solution) }
          parents << best
        end

        parents
      end

      def tournament_size
        # The tournament size is set to 5% of the population size
        @tournament_size ||= (@population_size * 0.05).ceil
      end
    end
  end
end
