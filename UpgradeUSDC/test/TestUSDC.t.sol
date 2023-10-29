// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Test, console2} from "forge-std/Test.sol";
import {USDC_V2} from "../src/USDC_V2.sol";
interface IFiatTokenProxy {
  event AdminChanged(address previousAdmin, address newAdmin);

  function admin() external view returns (address);
  function implementation() external view returns (address);
  function changeAdmin(address) external;
  function upgradeTo(address newImplementation) external;
  function upgradeToAndCall(address newImplementation, bytes memory data) payable external;
}

contract TestUSDC is Test {

  address USDC_TOKEN_ADDR = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
  address USDC_ADMIN = 0x807a96288A1A408dBC13DE2b1d087d10356395d2;
  address USDC_OWNER = 0xFcb19e6a322b27c06842A71e8c725399f049AE3a;

  IFiatTokenProxy usdc_proxy;

  address user1 = makeAddr("user1");
  address user2 = makeAddr("user2");
  

  function setUp () public {
    vm.createSelectFork("https://eth-mainnet.g.alchemy.com/v2/5uLAUMBNqkgQrMLPdxBeNLqYkSncr1DQ");

    usdc_proxy = IFiatTokenProxy(USDC_TOKEN_ADDR);

    deal(address(usdc_proxy), user1, 10 ether);
  }

  function testUpgrade() public {
    USDC_V2 new_implement = new USDC_V2();
    vm.startPrank(USDC_ADMIN);
    usdc_proxy.upgradeTo(address(new_implement));
    USDC_V2 usdc_v2 = USDC_V2(address(usdc_proxy));
    vm.stopPrank();
    vm.startPrank(user1);
    
    assertEq(usdc_v2.VERSION(), "V2");
    vm.stopPrank();
  }

  function testTransferOnlyWhitelist() public {
    USDC_V2 new_implement = new USDC_V2();
    vm.startPrank(USDC_ADMIN);
    usdc_proxy.upgradeTo(address(new_implement));
    USDC_V2 usdc_v2 = USDC_V2(address(usdc_proxy));
    vm.stopPrank();

    // set user1 in whitelist
    vm.prank(USDC_OWNER);
    usdc_v2.updateWhitelist(user1);
    
    // before transfer user1 has 10 ether
    assertEq(usdc_v2.balances(user1), 10 ether);
    assertEq(usdc_v2.balances(user2), 0 ether);

    vm.prank(user1);
    usdc_v2.transfer(user2, 4 ether);

    assertEq(usdc_v2.balances(user1), 6 ether);
    assertEq(usdc_v2.balances(user2), 4 ether);
    
    // test user2 is not in whitelist and user2 can not transfer
    vm.startPrank(user2);
    vm.expectRevert("need to be in whitelist");
    usdc_v2.transfer(user1, 1 ether);
    vm.stopPrank();

  }

  function testMint() public {
    USDC_V2 new_implement = new USDC_V2();
    vm.startPrank(USDC_ADMIN);
    usdc_proxy.upgradeTo(address(new_implement));
    USDC_V2 usdc_v2 = USDC_V2(address(usdc_proxy));
    vm.stopPrank();

    // in white list, user can mint no limit times

    // set user1 in whitelist
    vm.prank(USDC_OWNER);
    usdc_v2.updateWhitelist(user1);

    // let user1 mint 5 times
    // and user1 can mint to user2 
    vm.startPrank(user1);
    for (uint256 index = 0; index < 5; index++) {
      if(index < 3) {
        usdc_v2.mint(user1, 1 ether);
      }else{
        usdc_v2.mint(user2, 1 ether);
      }
    }
    vm.stopPrank();
    assertEq(usdc_v2.balances(user1), 13 ether);
    assertEq(usdc_v2.balances(user2), 2 ether);

    // test for user2 can only mint once because user2 is not in whitelist
    vm.startPrank(user2);
    usdc_v2.mint(user2, 3 ether);

    vm.expectRevert("this address can only mint once.");
    usdc_v2.mint(user2, 3 ether);

    assertEq(usdc_v2.balances(user2), 5 ether);
  }
}

