// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

/**
 * @title a sample raffle contract
 * @author Dmytro Shashkevych
 * @notice Random Smart Contract Lottery
 * @dev Implements Chainling VRFv2
 */
contract Raffle {
    uint256 private immutable i_entranceFee;

    constructor(uint256 entranceFee) {
        i_entranceFee = entranceFee;
    }

    function enterRaffle() public payable {}

    function pickWinner() public {}

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
