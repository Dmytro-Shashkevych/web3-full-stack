// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address ALICE = makeAddr("alice");
    address BOB = makeAddr("bob");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant INITIAL_BALANCE = 10 ether;

    function setUp() external {
        // US ---> FundMeTest ---> FundMe
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(ALICE, INITIAL_BALANCE);
        vm.deal(BOB, INITIAL_BALANCE);
    }

    modifier funded() {
        vm.prank(ALICE);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        console.log(version);
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); // the next line should revert!
        fundMe.fund();
    }

    function testFundUpdatesFundedData() public funded {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(ALICE);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public funded {
        address funderAlice = fundMe.getFunder(0);
        assertEq(funderAlice, ALICE);

        vm.prank(BOB);
        fundMe.fund{value: SEND_VALUE}();

        address funderBob = fundMe.getFunder(1);
        assertEq(funderBob, BOB);
    }

    function testFundMultipleTimes() public funded {
        address funderAlice = fundMe.getFunder(0);
        assertEq(funderAlice, ALICE);
        uint256 amountFunded = fundMe.getAddressToAmountFunded(ALICE);
        assertEq(amountFunded, SEND_VALUE);

        vm.prank(ALICE);

        fundMe.fund{value: SEND_VALUE}();

        uint256 amountFundedAfterSecondFund = fundMe.getAddressToAmountFunded(
            ALICE
        );
        assertEq(amountFundedAfterSecondFund, 2 * SEND_VALUE);
    }

    function testWithdrawFailNotAnOwner() public funded {
        vm.expectRevert();
        vm.prank(ALICE);
        fundMe.withdraw();
    }

    function testWithdrawSuccessMadeByOwner() public funded {
        vm.expectRevert();
        vm.prank(ALICE);
        fundMe.withdraw();
    }
}
