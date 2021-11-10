const Reward = artifacts.require("Reward");
const Staking = artifacts.require("Staking");

contract("Staking...", async (accounts) => {
    let [alice] = accounts;
    let contractInstance;
    let reward;
    before(async () => {
        reward = await Reward.deployed();
        console.log("Reward " + reward.address)
        contractInstance = await Staking.deployed(reward.address);
        console.log("ContractInstance " + contractInstance.address)
    });
    it("gives the owner of token 1M tokens", async () => {
        let balance = await reward.balanceOf(accounts[0])
        balance = web3.utils.fromWei(balance, 'ether')
        assert.equal(balance, '10000000', "Balance should be 1M tokens for contract creator")
    })

    it("can transfer tokens between accounts", async () => {
        let amount = web3.utils.toWei('1000', 'ether')
        await reward.transfer(contractInstance.address, amount, {from : accounts[0]})
        let balance = await reward.balanceOf(contractInstance.address)
        balance = web3.utils.fromWei(balance, 'ether')
        assert.equal(balance, '1000', 'Balance should be 1000')
    })

    it("should be able to change rewardRate", async () => {
        const result = await contractInstance.setRewardRate(50, {from: alice});
        //TODO: replace with expect
        assert.equal(result.receipt.status, true);
        assert.equal((await contractInstance.getRewardRate()).toString(), '50');
    });

    it("should be able to change withdrawFee", async () => {
        const result = await contractInstance.setWithdrawFee(5, {from: alice});
        //TODO: replace with expect
        assert.equal(result.receipt.status, true);
        assert.equal((await contractInstance.getWithdrawFee()).toString(), '5');
    });

    it("should be able to change withdrawFeeStatus", async () => {
        const result = await contractInstance.setWithdrawFeeStatus(false, {from: alice});
        //TODO: replace with expect
        assert.equal(result.receipt.status, true);
        assert.equal((await contractInstance.getWithdrawFeeStatus()), false);
    });

    it("should be able to stake", async () => {
        const before = await contractInstance.getBalanceOf({from: alice});
        const result = await contractInstance.stake(3,{from: alice, gas:3000000, value: 1000000});
        const after = await contractInstance.getBalanceOf({from: alice});
        //TODO: replace with expect
        assert.equal(result.receipt.status, true);
        assert.equal(after - before, 1000000);
    });

    it("should be able to withdraw", async () => {
        const result = await contractInstance.stake(0, {from: alice, gas:3000000, value: 1000000});
        assert.equal(result.receipt.status, true);
        const before = await contractInstance.getBalanceOf({from: alice});
        const result1 = await contractInstance.withdraw(1000000, {from: alice, gas:3000000});
        const after = await contractInstance.getBalanceOf({from: alice});
        //TODO: replace with expect
        assert.equal(result1.receipt.status, true);
        assert.equal(before - after, 1000000);
    });
    // it("should be able to claimReward", async () => {
    //     const result = await contractInstance.claimReward({from: alice, gas:3000000});
    //     const rewards = await contractInstance.getBalanceOf({from: alice});
    //     //TODO: replace with expect
    //     assert.equal(result.receipt.status, true);
    //     assert.equal(rewards, 0);
    // });
})
