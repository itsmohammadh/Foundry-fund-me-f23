// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundme;
    uint256 constant SEND_VALUE = 0.1 ether;
    address USER = makeAddr("user");
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        //fundme = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployfundme = new DeployFundMe();
        fundme = deployfundme.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testtMinimomDollarIsFive() public {
        assertEq(fundme.MINIMUM_USD(), 5e18);
    }

    function testOwner() public {
        assertEq(fundme.getOwner(), msg.sender);
    }

    function testPriceFeedVersionisAcurrate() public {
        console.log("Hello world!");
        uint256 version = fundme.getVersion();
        assertEq(version, 4);
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER);
        fundme.fund{value: SEND_VALUE}();

        uint256 amountFunded = fundme.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddFounderToArrayFounders() public {
        vm.prank(USER);
        fundme.fund{value: SEND_VALUE}();

        address funder = fundme.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundme.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundme.withdraw();
    }

    function testWithdrawWithSingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundMeBalance = address(fundme).balance;

        // Act
        vm.prank(fundme.getOwner());
        fundme.withdraw();

        // Assert
        uint256 stopOwnerBalance = fundme.getOwner().balance;
        uint256 stopFundMeBalance = address(fundme).balance;

        assertEq(stopFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            stopOwnerBalance
        );
    }

    function testWithdrawFromMultipleFunders() public funded {
        // Arrange
        uint160 numberOfFunder = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i > numberOfFunder; i++) {
            hoax(address(i), SEND_VALUE); //hoax is a foundry cheatcode for create and give them value ^_^
            fundme.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundMeBalance = address(fundme).balance;

        // Act
        vm.startPrank(fundme.getOwner());
        fundme.withdraw(); // Call mikone function ro guys
        vm.stopPrank();

        // Assert
        assert(address(fundme).balance == 0);
        assert(
            startingOwnerBalance + startingFundMeBalance ==
                fundme.getOwner().balance
        );

        /* assertEq(address(fundme).balance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            fundme.getOwner().balance
        );
        */
    }
}
