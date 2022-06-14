task create_groups: :environment do
  [
    Rakes::RunsMatchmaking.new(stdout: $stdout, stderr: $stdout),
    Rakes::SendsPendingNotifications.new(stdout: $stdout, stderr: $stdout)
  ].each(&:call)
end
