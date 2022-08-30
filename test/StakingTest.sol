// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "forge-std/Test.sol";
import "../src/Staking.sol";
import "./Mocks/TestToken.sol";

contract ContractTest is Test {

    Staking public staking;
    TestToken public testToken;
    function setUp() public {
        staking =  new Staking(testToken,testToken);
        testToken = new TestToken();
    }
    //Test for 0 inputs
    function testNonZero() public {
        vm.expectRevert(abi.encodeWithSignature("Staking_NonZero()"));
        uint amount = 0;
        staking.stake(amount);

    }
   //Test for 0 inputs
    function testNonZero_() public {
        vm.expectRevert(abi.encodeWithSignature("Staking_NonZero()"));
        uint amount = 0;
        staking.withdrawStake(amount);
    }

    }
