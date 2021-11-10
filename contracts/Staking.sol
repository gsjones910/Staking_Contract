// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

contract Staking is Ownable {
    using SafeMath for uint256;

    IERC20 public rewardsToken;


    uint private rewardRate = 100; // reward rates

    uint private withdrawFee = 10; // withdraw fees
    bool private withdrawFeeStatus = true; // enable/disable withdraw fees

    uint public lastUpdateTime;
    uint public rewardPerTokenStored;

    mapping(address => uint) public userRewardPerTokenPaid;
    mapping(address => uint) private rewards;

    uint private _totalSupply;
    mapping(address => uint) private _balances;
    mapping(address => uint) private _endBlock;

    event RewardUpdated(address account, uint rewards, uint rewardPerTokenStored, uint lastUpdateTime);
    event Stake(address account, uint amount, uint amountSoFar);
    event Withdraw(address account, uint amount, uint amountRemaining);
    event ClaimReward(address account, uint amount);


    constructor(address _rewardsToken) {
        rewardsToken = IERC20(_rewardsToken);
    }

    function setRewardRate(uint _rewardRate) external onlyOwner {
        rewardRate = _rewardRate;
    }

    function getRewardRate() public view returns (uint _rewardRate) {
        return rewardRate;
    }

    function setWithdrawFee(uint _withdrawFee) external onlyOwner {
        withdrawFee = _withdrawFee;
    }

    function getWithdrawFee() public view returns (uint _withdrawFee) {
        return withdrawFee;
    }

    function setWithdrawFeeStatus(bool _withdrawFeeStatus) external onlyOwner {
        withdrawFeeStatus = _withdrawFeeStatus;
    }

    function getWithdrawFeeStatus() public view returns (bool _withdrawFeeStatus) {
        return withdrawFeeStatus;
    }

    function getBalanceOf(address account) public view returns (uint256 _balance) {
        return _balances[account];
    }

    function getRewardsOf(address account) public view returns (uint256 _balance) {
        return rewards[account];
    }

    function getRewardToken() public view returns (address _address) {
        return address(rewardsToken);
    }

    function rewardPerToken() public view returns (uint) {
        if (_totalSupply == 0) {
            return 0;
        }

        uint256 reward_value = 0;
        reward_value = rewardPerTokenStored.add((((block.timestamp.sub(lastUpdateTime)).mul(rewardRate).mul(1e18)).div(_totalSupply)));

        return reward_value;
    }

    function earned(address account) public view returns (uint) {
        return ((_balances[account].mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))).div(1e18)).add(rewards[account]);
    }

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;

        rewards[account] = earned(account);
        userRewardPerTokenPaid[account] = rewardPerTokenStored;

        emit RewardUpdated(account, rewards[account], rewardPerTokenStored, lastUpdateTime);
        _;
    }

    function stake(uint blocks) external payable updateReward(msg.sender) {
        require( msg.sender.balance >= msg.value + 23000, "Insufficient amount");
        require( block.number >= _endBlock[msg.sender], "Too Early");

        _totalSupply = _totalSupply.add(msg.value);
        _balances[msg.sender] = _balances[msg.sender].add(msg.value);
        _endBlock[msg.sender] = block.number.add(blocks);
        
        // stakingToken.transferFrom(msg.sender, address(this), msg.value);
        emit Stake(msg.sender, msg.value, _balances[msg.sender]);
    }

    function withdraw(uint _amount) external updateReward(msg.sender) {
        require( block.number >= _endBlock[msg.sender], "Too Early");
        require(_balances[msg.sender] >= _amount, "Over the limit");
        require(address(this).balance >= _amount, "Insufficient amount");
        uint realAmount = _amount;
        // if (withdrawFeeStatus) {
        //     realAmount = _amount.mul(100 - withdrawFee).div(100);
        // }

        payable(msg.sender).transfer(realAmount);

        _totalSupply = _totalSupply.sub(realAmount);
        _balances[msg.sender] = _balances[msg.sender].sub(_amount);
        emit Withdraw(msg.sender, _amount, _balances[msg.sender]);
    }

    function claimReward() external updateReward(msg.sender) {
        require( block.number >= _endBlock[msg.sender], "Too Early");
        require(rewards[msg.sender] > 0, "No Rewards");

        uint reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        rewardsToken.transfer(msg.sender, 5);
        emit ClaimReward(msg.sender, reward);
    }
}
