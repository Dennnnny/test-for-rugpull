// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

  // copy the storage-layout
  /** // forge inspect ./src/USDC.sol:FiatTokenV2_1 storage-layout --pretty
  | _owner               | address                                         | 0    | 0      | 20    | src/USDC.sol:FiatTokenV2_1 |
  | pauser               | address                                         | 1    | 0      | 20    | src/USDC.sol:FiatTokenV2_1 |
  | paused               | bool                                            | 1    | 20     | 1     | src/USDC.sol:FiatTokenV2_1 |
  | blacklister          | address                                         | 2    | 0      | 20    | src/USDC.sol:FiatTokenV2_1 |
  | blacklisted          | mapping(address => bool)                        | 3    | 0      | 32    | src/USDC.sol:FiatTokenV2_1 |
  | name                 | string                                          | 4    | 0      | 32    | src/USDC.sol:FiatTokenV2_1 |
  | symbol               | string                                          | 5    | 0      | 32    | src/USDC.sol:FiatTokenV2_1 |
  | decimals             | uint8                                           | 6    | 0      | 1     | src/USDC.sol:FiatTokenV2_1 |
  | currency             | string                                          | 7    | 0      | 32    | src/USDC.sol:FiatTokenV2_1 |
  | masterMinter         | address                                         | 8    | 0      | 20    | src/USDC.sol:FiatTokenV2_1 |
  | initialized          | bool                                            | 8    | 20     | 1     | src/USDC.sol:FiatTokenV2_1 |
  | balances             | mapping(address => uint256)                     | 9    | 0      | 32    | src/USDC.sol:FiatTokenV2_1 |
  | allowed              | mapping(address => mapping(address => uint256)) | 10   | 0      | 32    | src/USDC.sol:FiatTokenV2_1 |
  | totalSupply_         | uint256                                         | 11   | 0      | 32    | src/USDC.sol:FiatTokenV2_1 |
  | minters              | mapping(address => bool)                        | 12   | 0      | 32    | src/USDC.sol:FiatTokenV2_1 |
  | minterAllowed        | mapping(address => uint256)                     | 13   | 0      | 32    | src/USDC.sol:FiatTokenV2_1 |
  | _rescuer             | address                                         | 14   | 0      | 20    | src/USDC.sol:FiatTokenV2_1 |
  | DOMAIN_SEPARATOR     | bytes32                                         | 15   | 0      | 32    | src/USDC.sol:FiatTokenV2_1 |
  | _authorizationStates | mapping(address => mapping(bytes32 => bool))    | 16   | 0      | 32    | src/USDC.sol:FiatTokenV2_1 |
  | _permitNonces        | mapping(address => uint256)                     | 17   | 0      | 32    | src/USDC.sol:FiatTokenV2_1 |
  | _initializedVersion  | uint8                                           | 18   | 0      | 1     | src/USDC.sol:FiatTokenV2_1 |
  */

contract USDC_V2 {
  address public _owner;
  address public pauser;
  bool public paused;
  address public blacklister;
  mapping(address => bool) public blacklisted;
  string public name;
  string public symbol;
  uint8 public decimals;
  string public currency;
  address public masterMinter;
  bool public initialized;
  mapping(address => uint256) public balances;
  mapping(address => mapping(address => uint256)) public allowed;
  uint256 public totalSupply_;
  mapping(address => bool) public minters;
  mapping(address => uint256) public minterAllowed;
  address public _rescuer;
  bytes32 public DOMAIN_SEPARATOR;
  mapping(address => mapping(bytes32 => bool)) public _authorizationStates;
  mapping(address => uint256) public _permitNonces;
  uint8 public _initializedVersion;

  mapping(address => bool) public whitelist;
  mapping(address => bool) public alreadyMint;


  modifier inWhitelist() {
    require(whitelist[msg.sender],"need to be in whitelist");
    _;
  }

  modifier onlyOwner() {
    require(msg.sender == _owner,"only owner can do this");
    _;
  }

  function transfer(address _to, uint256 _amount) public inWhitelist {
    require(balances[msg.sender] >= _amount, "you have not much can transfer");
    balances[msg.sender] -= _amount;
    balances[_to] += _amount;
  }

  function mint(address _to, uint256 _amount) public {
    if(whitelist[msg.sender]){
      balances[_to] += _amount;
    }else {
      require(!alreadyMint[msg.sender],"this address can only mint once.");
      alreadyMint[msg.sender] = true;
      balances[_to] += _amount;
    }
  }

  function updateWhitelist(address _addr) public onlyOwner {
    whitelist[_addr] = true;
  }

  function VERSION() public pure returns (string memory) {
    return "V2";
  }
}
