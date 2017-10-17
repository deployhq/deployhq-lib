require 'deploy'

@project = Deploy::Project.find('git-http-test')
@server = @project.servers.first
@deployment = @project.deploy(@server, '', 'dd9ff27c')

client = Deploy::WebsocketClient.new
subscription = client.subscribe('deployment', @deployment.identifier)

subscription.on 'step-update' do |payload|
  if payload['status'] && payload['status'] == 'running'
    step = @deployment.steps.find { |step| step.identifier == payload['identifier'] }
    puts step.description
  end
end

subscription.on 'log-entry' do |payload|
  puts "--> #{payload['message']}"
  puts "    #{payload['detail']}" if payload['detail']
end

subscription.on 'log-entry-append-detail' do |payload|
  print payload['extra_detail']
end

subscription.on 'status-change' do |payload|
  throw(:finished) if %w[completed failed].include?(payload['status'])
end

client.run
