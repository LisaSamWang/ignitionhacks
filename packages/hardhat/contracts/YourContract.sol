pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol"; 
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract YourContract is Ownable{
  // maps the provider wallet addresses to their names or license numbers, something identifiable
  mapping(address => string) public providers;

  event AddProvider(address prov, string provid);
  function addProvider(address prov, string memory str) public {
    providers[prov] = str;
    emit AddProvider(prov, str);
  }

  // maps the bill ID to the value of the bill
  mapping(string => uint) public bills;

  // maps bills ID to the providers who billed them
  mapping(string => address) public billers;

  // stores if bill ID was paid or not. A bill with any amount unpaid is not paid
  mapping(string => bool) public paid;

  // stores the amount of money providers were paid so far through the service
  mapping(address => uint) public payme;

  event AddBill(string id, uint value, address billedby);

  function addBill(string memory billid, uint money, address billedby) public {
    bytes memory checkempty = bytes(providers[billedby]);
    require(checkempty.length != 0, "Not a registered provider!");
    bills[billid] = money;
    billers[billid] = billedby;
    emit AddBill(billid, money, billedby);
  }

  // event SearchBill(string mybill);
  // function searchBill(string memory mybill_id) public returns(uint) {
  //   return bills[mybill_id];
  // }

  event SetPurpose(address sender, string purpose, string bill_id);
  uint256 public price = 0.01 ether;

  string public purpose = "Paying bills flexibly!";

  constructor() payable {
    // what should we do on deploy?
  }

  function setPurpose(string memory newPurpose, string memory bill_id_pay) public payable {
      price = bills[bill_id_pay];
      require(msg.value == price, "You are not paying the correct amount, check price above!");
      address prov = billers[bill_id_pay];
      bytes memory checkempty = bytes(providers[prov]);
      require(checkempty.length != 0, "Not a registered provider!");
      purpose = newPurpose;
      console.log(msg.sender,"set purpose to",purpose);
      emit SetPurpose(msg.sender, purpose, bill_id_pay);
      paid[bill_id_pay] = true;
      payme[prov] = payme[prov] + price;
  }

  function withdraw() public onlyOwner {
    require(address(this).balance >= 1, "Not enough money here sorry!");
    (bool success, ) = msg.sender.call{value: address(this).balance}("");
    require(success, "Unsuccessful withdrawal!");
  }

  function renounceOwnership() public override {
    revert("disabled");
  }

  // to support receiving ETH by default
  receive() external payable {}
  fallback() external payable {}
}
