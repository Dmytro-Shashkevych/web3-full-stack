// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

/**
 * @title a sample raffle contract
 * @author Dmytro Shashkevych
 * @notice Random Smart Contract Lottery
 * @dev Implements Chainling VRFv2
 */
contract Raffle {
    error Raffle__NotEnoughEntrenceFee();
    error Raffle__NotEnoughTimeToPickWinner();

    uint256 private immutable i_entranceFee;
    // @dev Duration of the lottery in seconds
    uint256 private immutable i_interval;
    address private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;

    address[] private s_players;
    uint256 private s_lastTimeStemp;

    event EnteredRaffle(address indexed player);

    constructor(uint256 entranceFee, uint256 interval, address vrfCoordinator, bytes32 gasLane) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        i_vrfCoordinator = vrfCoordinator;
        i_gasLane = gasLane;
        s_lastTimeStemp = block.timestamp;
    }

    function enterRaffle() external payable {
        if (msg.value < i_entranceFee) {
            revert Raffle__NotEnoughEntrenceFee();
        }
        s_players.push(payable(msg.sender));
        emit EnteredRaffle(msg.sender);
    }

    function pickWinner() external {
        // if (block.timestamp - s_lastTimeStemp < i_interval) {
        //     revert Raffle__NotEnoughTimeToPickWinner();
        // }
        //         unit256 requestId = i_vrfCoordinator.requestRandomWords(
        //     i_gasLane,
        //     uint64 subId,
        //     uint16 requestConfirmations,
        //     uint32 callbackGasLimit,
        //     uint32 numWords
        //   )
    }

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
