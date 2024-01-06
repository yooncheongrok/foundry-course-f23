//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "../../lib/forge-std/src/Test.sol";
import {FundMe} from "../../src/FundMe.sol" ;
import {DeployFundMe} from "../../script/DeployFundMe.s.sol" ;


contract FundMeTest is Test{
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);

    }

    function testMinimumDollaIsFive() public {
        console.log("testMinimumDollaIsFive");
        assertEq(fundMe.MINIMUM_USD(), 5e18);
        
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        
        uint256 version = fundMe.getVersion();
        console.log(version);
        assertEq(version, 4);
    }

    function testFundFailWithoutEnoughEth() public {
        vm.expectRevert();
        // s_priceFeed is not defined in this test. So s_priceFeed is 0 and fund() will fail. 
        fundMe.fund();
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testFundUpdatesFundedDataStructure() public funded {

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public funded {

        address funder = fundMe.getFunder(0);
        assertEq(USER, funder);
    }

    function testOnlyOwnerCanWithdraw() public funded {

        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();

    }

    function testWithDrawWithASingleFunder() public funded {
    
    //arange
    uint256 startingOwnerBalance = fundMe.getOwner().balance;
    uint256 startingFunderBalance = address(fundMe).balance;


    //Act
    vm.prank(fundMe.getOwner());
    fundMe.withdraw();

    // assert
    uint256 edingOwnerBalance = fundMe.getOwner().balance;
    uint256 edingFunderBalance = address(fundMe).balance;
    assertEq(startingOwnerBalance + startingFunderBalance, edingOwnerBalance);
    assertEq(edingFunderBalance,0);

    }

    function testWithrawWithMultipleFunders() public funded {
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for(uint160 i = startingFunderIndex; i<numberOfFunders; i++){
            //vm.prank new address
            //vm.deal new address
            //address()
            //above sentences can be into one sentence => hoax
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMebalance = address(fundMe).balance;

        //Act

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();


        //Assert

        assertEq(startingOwnerBalance + startingFundMebalance, fundMe.getOwner().balance);
        assertEq(address(fundMe).balance, 0);
    }

        function testWithrawWithMultipleFundersCheaper() public funded {
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for(uint160 i = startingFunderIndex; i<numberOfFunders; i++){
            //vm.prank new address
            //vm.deal new address
            //address()
            //above sentences can be into one sentence => hoax
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMebalance = address(fundMe).balance;

        //Act

        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();


        //Assert

        assertEq(startingOwnerBalance + startingFundMebalance, fundMe.getOwner().balance);
        assertEq(address(fundMe).balance, 0);
    }



}
