task create_groups: :environment do
  [
    Rakes::RunMatchmaking.new(stdout: $stdout, stderr: $stdout),
    Rakes::SendPendingNotifications.new(stdout: $stdout, stderr: $stdout),
    Rakes::RemovesOldMatches.new
  ].each(&:call)
end
