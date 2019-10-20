namespace :desktop do
  desc "-- [options] Desktop Clean-up Project"
  task :clean_up_project => :environment do |t|
    MrCore::Desktop::CleanUpProject.new(self, t).run
  end

  desc "-- [options] Desktop Update Application"
  task :update_application => :environment do |t|
    MrCore::Desktop::UpdateApplication.new(self, t).run
  end
end
