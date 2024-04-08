// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    uint256 number = 1;
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 SEND_VALUE = 0.1 ether;
    uint256 STARTING_BALANCE = 10 ether;

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
        // giving user a starting balance to interact with the contract
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinDollarIsFive() public view {
        uint256 minUsd = fundMe.MINIMUM_USD();
        assertEq(minUsd, 5e18);
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testIsOwnerInitialisedCorrectly() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public funded {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(SEND_VALUE, amountFunded);
    }

    function testAddsFunderToArrayOfFunders() public funded {
        assertEq(fundMe.getFunder(0), USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testOwnerCanWithdrawWithSingleUserFunding() public funded {
        // Arrange
        address owner = fundMe.getOwner();
        uint256 ownerStartingBalance = owner.balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.prank(owner);
        fundMe.withdraw();

        // Assert
        uint256 ownerEndingBalance = owner.balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(ownerEndingBalance, startingFundMeBalance + ownerStartingBalance);
        assertEq(endingFundMeBalance, 0);
    }

    function testOwnerCanWithdrawWithMultipleUsersFunding() public funded {
        // Simulating multiple users funding the contract
        uint160 numberOfFunders = 10;
        uint160 startingIndex = 1;

        for (uint160 i = startingIndex; i < numberOfFunders; i++) {
            hoax(address(i), STARTING_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }

        // Arrange
        address owner = fundMe.getOwner();
        uint256 ownerStartingBalance = owner.balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.prank(owner);
        fundMe.withdraw();

        // Assert
        uint256 ownerEndingBalance = owner.balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(ownerEndingBalance, startingFundMeBalance + ownerStartingBalance);
        assertEq(endingFundMeBalance, 0);
    }
}
