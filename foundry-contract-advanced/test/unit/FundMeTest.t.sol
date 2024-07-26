// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address ALICE = makeAddr("alice");
    address BOB = makeAddr("bob");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant INITIAL_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

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

    function testWithdrawWithASignleFunder() public funded {
        // arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeContractBalance = address(fundMe).balance;

        // act

        /**
         * getting debuged actual amount of gas spent within this transaction
         */
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 gasEnd = gasleft();
        uint256 gasUsed = gasStart - gasEnd * tx.gasprice;

        console.log(gasUsed);

        // assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeContractBalance = address(fundMe).balance;

        assertEq(endingOwnerBalance, startingOwnerBalance + SEND_VALUE);
        assertEq(
            endingFundMeContractBalance,
            startingFundMeContractBalance - SEND_VALUE
        );
    }

    function testWithdrawFromMultipleFunders() public funded {
        // arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i <= numberOfFunders; i++) {
            // prank - create new address and sets a next call to him
            // deal - fund with some Ether
            // hoax = prank + deal - creates account that has some Ether

            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeContractBalance = address(fundMe).balance;

        // act
        vm.startPrank(fundMe.getOwner());
        /*
        everything in between will be send by address we set in startPrank
         */
        fundMe.withdraw();
        vm.stopPrank();

        // assert
        assert(
            startingFundMeContractBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }

    function testWithdrawFromMultipleFundersCheaper() public funded {
        // arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i <= numberOfFunders; i++) {
            // prank - create new address and sets a next call to him
            // deal - fund with some Ether
            // hoax = prank + deal - creates account that has some Ether

            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeContractBalance = address(fundMe).balance;

        // act
        vm.startPrank(fundMe.getOwner());
        /*
        everything in between will be send by address we set in startPrank
         */
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // assert
        assert(
            startingFundMeContractBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }
}
