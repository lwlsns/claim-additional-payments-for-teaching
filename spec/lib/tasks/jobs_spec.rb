require "rails_helper"
require "rake"

RSpec.describe "rake db:schedule_jobs" do
  def queue_adapter_for_test
    DelayedJobTestAdapter.new
  end

  before do
    Rake::Task.define_task(:environment)
    Rake::Task.define_task(:"db:migrate")
    Rake::Task.define_task(:"db:schema:load")
    Rake.application.rake_require "tasks/jobs"
  end

  it "schedules and enqueues SchoolDataImporterJob" do
    Rake::Task["db:schedule_jobs"].invoke

    jobs = SchoolDataImporterJob.send(:jobs)

    expect(jobs.where(cron: nil).count).to eq(1)
    expect(jobs.where.not(cron: nil).count).to eq(1)
  end

  it "runs automatically after db:migrate" do
    expect(Rake::Task["db:schedule_jobs"]).to receive(:invoke)

    Rake::Task["db:migrate"].invoke
  end

  it "runs automatically after db:schema:load" do
    expect(Rake::Task["db:schedule_jobs"]).to receive(:invoke)

    Rake::Task["db:schema:load"].invoke
  end
end
