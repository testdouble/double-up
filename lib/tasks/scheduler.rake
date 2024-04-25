task create_groups: :environment do
  Rake::Task["matchmaking:run"].invoke
end
