class HardJob
  include Sidekiq::Job

  def perform(name, age)
    puts "Processing job for #{name} with value #{age}"
  end
end
