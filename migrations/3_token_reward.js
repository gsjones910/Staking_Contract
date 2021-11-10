const Reward = artifacts.require("Reward");

module.exports = function (deployer) {
  deployer.deploy(Reward, 10000000);
};
