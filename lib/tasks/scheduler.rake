task create_groups: :environment do
  Rakes::RunsMatchmaking.new(stdout: $stdout, stderr: $stdout).call
end
