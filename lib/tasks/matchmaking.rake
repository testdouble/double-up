namespace :matchmaking do
  desc "Run matchmaking tasks"
  task run: :environment do
    [
      Rakes::RunMatchmaking.new(stdout: $stdout, stderr: $stdout),
      Rakes::SendPendingNotifications.new(stdout: $stdout, stderr: $stdout),
      Rakes::RemovesOldMatches.new
    ].each(&:call)
  end

  desc "Run single matchmaking task"
  task :run_single, [:group_name] => :environment do |_task, args|
    [
      Rakes::RunMatchmaking.new(stdout: $stdout, stderr: $stdout, only: [args[:group_name]]),
      Rakes::SendPendingNotifications.new(stdout: $stdout, stderr: $stdout),
      Rakes::RemovesOldMatches.new
    ].each(&:call)
  end
end
