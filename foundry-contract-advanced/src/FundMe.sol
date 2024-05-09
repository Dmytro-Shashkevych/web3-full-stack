// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5 * 1e18;
    uint256 public constant VERSION = 5;

    mapping(address => uint256) public addressToAmountFunded;
    address public immutable i_owner;

    // immediately called whenever you deploy a function
    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {
        require(
            msg.value.getConversionRate() >= MINIMUM_USD,
            "Didn't send enough ETH  "
        );
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        // for(starting index; ending index; step amount)
        // for (
        //     uint256 funderIndex = 0;
        //     funderIndex < funders.length;
        //     funderIndex++
        // ) {
        //     address funders =  funders[funderIndex];
        //     addressToAmountFunded[funder] = 0;
        // }

        // 3 ways to send ether

        // transfer (2300 gas, if more gas is used -> throws error)
        // reverts automatically
        // payable(msg.sender).transfer(address(this).balance);

        // send (2300 gas, returns bool whether or not it was successfully)
        // reverts by adding require check for the isSendSuccess step
        // bool isSendSuccess = payable(msg.sender).send(address(this).balance);

        // require(isSendSuccess, "Send wasn't successfully");

        // call - lower level - without ABI
        // most preferred way to send ETH or native currency !!!

        (bool isCallSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");

        require(isCallSuccess, "Call lower level wasn't successfully");
    }

    modifier onlyOwner() {
        // (msg.sender == i_owner, "Only allowed to be called by owner");

        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }

        // Underscore is a special character only used inside
        // a function modifier and it tells Solidity to
        // execute the rest of the code.
        _;
    }

    // constant - do not take storage spot & easier to read --> cheaper to read from, immutable

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
