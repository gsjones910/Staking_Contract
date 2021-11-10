const Staking = artifacts.require("Staking");

module.exports = function (deployer) {
  // deployer.deploy(Reward, 10000000);
  deployer.deploy(Staking, "0xfe68140e569f8b8f2e28d92125b75e7f81789cc6");
};
