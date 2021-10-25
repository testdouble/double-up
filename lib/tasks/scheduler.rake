task create_groups: :environment do
  Rakes::RunsMatchmaking.new($stdout, $stdout).call
  CreateGroupsJob.perform
end
