// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

    /**
        According to the given block time = 6s, 
        there would be 14400 blocks mined each day.
        Given the reward rate of 0.001 DEFI PER 1 DEFI for a day.
        The reward per block for 1 DEFI is, 0.001 / 14400
        Which would give 69444444444 wei per block.
     */

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Staking {

    using SafeERC20 for IERC20;

    struct Stake {
        uint256 amount;
        uint256 accumulatedReward;
        uint256 lastStakedBlock;
    }

    uint256 constant REWARD_PER_BLOCK = 69444444444;
    IERC20 private _token; 
    mapping(address => Stake) private _stakes;

    constructor(
        IERC20 token_
    ) {
        _token = token_;
    }

    function token() external view returns(IERC20) {
        return _token;
    }

    function getStake(address user) external view returns(Stake memory) {
        return _stakes[user];
    }

    function rewards(address user) public view returns(uint256, uint256) {
        Stake memory stake = _stakes[user];
        uint256 reward = (block.number - stake.lastStakedBlock) * REWARD_PER_BLOCK;
        return (stake.amount, stake.accumulatedReward + reward);
    }

    function deposit(uint256 amount) external {
        _token.safeTransferFrom(msg.sender, address(this), amount);
        _stake(amount);
    }

    function withdraw() external {
        (uint256 stake, uint256 rewardToSend) = rewards(msg.sender);
        _withdraw();
        _token.safeTransfer(msg.sender, stake + rewardToSend);
    }

    function _stake(uint256 amount) private {
        Stake storage stake = _stakes[msg.sender];
        if(stake.amount != 0) {
            stake.accumulatedReward += (block.number - stake.lastStakedBlock) * REWARD_PER_BLOCK;
        }
        stake.amount += amount;
        stake.lastStakedBlock = block.number;
    }

    function _withdraw() private {
        delete _stakes[msg.sender];
    }
}