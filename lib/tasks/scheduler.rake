task create_groups: :environment do
  [
    Rakes::RunsMatchmaking.new(stdout: $stdout, stderr: $stdout),
    Rakes::SendsPendingNotifications.new(stdout: $stdout, stderr: $stdout),
    Rakes::RemovesOldMatches.new
  ].each(&:call)
end
