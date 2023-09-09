// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundme} from "../../script/interaction.s.sol";

contract Interactiontest is Test {
    FundMe fundme;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 GAS_PRICE = 1;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        DeployFundMe deployfundme = new DeployFundMe();
        fundme = deployfundme.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteraction() public {
        FundFundMe fundfundme = new FundFundMe();
        fundfundme.fundFundMe(address(fundme));

        WithdrawFundme withdrawfundme = new WithdrawFundme();
        withdrawfundme.withdrawFundMe(address(fundme));

        assert(address(fundme).balance == 0);
    }
}
