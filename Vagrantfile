Vagrant.configure("2") do |config|
  config.vm.box = "xenial64"
  config.disksize.size = '50GB'

  config.vm.provider "virtualbox" do |vb|
    vb.memory = (1024*8).to_s
  end
end

