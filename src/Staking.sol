// SPDX-License-Identifier: MIT
 // Inspired by https://solidity-by-example.org/defi/staking-rewards/

pragma solidity ^0.8.6;

error Staking_NonZero();
error Staking_TransferFailed();

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Staking {
    IERC20 public immutable stakeToken;
    IERC20 public immutable rewardToken;

    //This is the reward rate per second
    // To be multiplied by the tokens staked divided by the total supply
    uint256 private constant REWARD_RATE_PER_SECOND = 100;
    //reward per token staked
    uint256 private rewardPerStakedToken;
    //total supply of staketokens
    uint256 public totalSupply;
    //the time of the previous snapshot
    uint256 private lastUpdatedTime;
    //The amount of tokens staked by the user
    mapping(address => uint256) amountOfTokensStaked;
    mapping(address => uint256) userRewardPerTokensStaked;
    // A mapping of the rewards earned by the user to the address
    mapping(address => uint256) rewards;


    modifier updateReward(address _user) {
      rewardPerStakedToken  = rewardPerToken();
      lastUpdatedTime = block.timestamp;
      if(_user != address(0)) {
      userRewardPerTokensStaked[msg.sender] = rewardPerStakedToken;
      rewards[_user] = rewardsEarned(_user);
      }
      _;

    }

    event UserStaked (address indexed user, uint256 indexed amount);
    event StakeWithdrawn(address indexed user,uint256 indexed amount);
    event UserRewarded (address indexed user, uint256 indexed amount);

    constructor(IERC20 _stakeToken, IERC20 _rewardToken) {
       stakeToken = _stakeToken;
       rewardToken  = _rewardToken;
    }

    /**
     * @notice User Deposits their tokens
     * @param amount| How much to stake
     */
    function stake(uint256 amount)
       external
       updateReward
       (msg.sender)
    {
      if(amount == 0 ) {
        revert Staking_NonZero();
      }
       
        (bool success ) = stakeToken.transferFrom(msg.sender,address(this),amount);
        if (! success) {
          revert Staking_TransferFailed();
        }
        emit UserStaked(msg.sender, amount);

        amountOfTokensStaked[msg.sender] += amount;
        totalSupply +=amount;
    }

    /**
     * @notice User Withdraws their tokens
     * @param amount| How much to withdraw
     */
    function withdrawStake(uint256 amount)
      external
      updateReward
      (msg.sender)
   {
     if(amount == 0 ) {
        revert Staking_NonZero();
      }

       amountOfTokensStaked[msg.sender] -= amount;
        totalSupply -= amount;
       
         bool success = stakeToken.transfer(msg.sender,amount);
        if (! success) {
          revert Staking_TransferFailed();
        }
        emit StakeWithdrawn(msg.sender, amount);
    }

    /**
     * @notice User claims their reward
     */
    function claimReward() external {
      uint reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
         bool success = rewardToken.transfer(msg.sender, reward);
          if (! success) {
          revert Staking_TransferFailed();
        }
        }
        emit UserRewarded(msg.sender, reward);
    }
 
    /**
     * @notice The amount of reward a user as earned
     */
    function rewardsEarned(address user)
      public
      view 
      returns
      (uint256)
   {
      return 
     ((amountOfTokensStaked[user] * (rewardPerToken() - userRewardPerTokensStaked[user])) / 1e18) +
      rewards[user] ;
   }

    /**
     * @notice The amount of reward a token gets based on how long it has been in based on when the snapshot was taken
     */
    function rewardPerToken() 
      public
      view
      returns 
     (uint256) 
    {
      if(totalSupply == 0) {
        return rewardPerStakedToken;
      }
       return 
         rewardPerStakedToken + ((block.timestamp - lastUpdatedTime) * REWARD_RATE_PER_SECOND * 1e18) / totalSupply;
    }
}