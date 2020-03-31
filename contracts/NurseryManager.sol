pragma solidity  > 0.5.0;

import "../node_modules/openzeppelin-solidity/contracts/access/Roles.sol";
import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./SupplyDataTypes.sol";

contract NurseryManager is Ownable {
  using Roles for Roles.Role;

  Roles.Role private nurseryOwners;

  SupplyDataTypes.Nursery[] public nurseries;
  SupplyDataTypes.Owner[] public nurseryOwnerList;
  mapping(address => SupplyDataTypes.Owner) public ownersByAddress;

  event AddedNurseryOwner(string name, address nurseryOwner);
  event AddedNursery(uint nurseryId, string nurseryName, int lat, int long, string description, string ownerName, address ownerAddress);

  constructor() public {
  }

  function addNurseryOwner(string memory name, address nurseryOwner) public onlyOwner {
    nurseryOwners.add(nurseryOwner);
    SupplyDataTypes.Owner memory owner = SupplyDataTypes.Owner(name, nurseryOwner);
    nurseryOwnerList.push(owner);
    ownersByAddress[nurseryOwner] = owner;
    emit AddedNurseryOwner(owner.name, owner.ownerAddress);
  }

  function isNurseryOwner(uint index) public view returns(bool) {
    return nurseries[index].ownerAddress == msg.sender;
  }

  function getNurseryOwnerCount() public view returns(uint) {
    return nurseryOwnerList.length;
  }

  function getNurseryOwner(uint index) public view returns(string memory, address) {
    SupplyDataTypes.Owner memory owner = nurseryOwnerList[index];
    return (owner.name, owner.ownerAddress);
  }

  function addNursery(string memory name, int lat, int long, string memory nurseryDescription, address ownerAddress) public onlyOwner {
    SupplyDataTypes.Nursery memory nursery = SupplyDataTypes.Nursery(nurseries.length, name, lat, long, nurseryDescription, ownerAddress);
    nurseries.push(nursery);
    SupplyDataTypes.Owner memory owner = ownersByAddress[ownerAddress];
    emit AddedNursery(nursery.id, name, lat, long, nurseryDescription, owner.name, ownerAddress);
  }

  function getNurseryCount() public view returns(uint) {
    return nurseries.length;
  }

  function getNursery(uint index) public view returns(uint, string memory, int, int, string memory, string memory, address) {
    SupplyDataTypes.Nursery memory nursery = nurseries[index];
    SupplyDataTypes.Owner memory owner = ownersByAddress[nursery.ownerAddress];
    return (nursery.id, nursery.name, nursery.lat, nursery.long, nursery.description, owner.name, nursery.ownerAddress);
  }

  function getNurseryLat(uint index) public view returns(int) {
    SupplyDataTypes.Nursery memory nursery = nurseries[index];
    return (nursery.lat);
  }

  function getNurseryLong(uint index) public view returns(int) {
    SupplyDataTypes.Nursery memory nursery = nurseries[index];
    return (nursery.long);
  }

  function getNurseryName(uint index) external view returns(string memory) {
    SupplyDataTypes.Nursery memory nursery = nurseries[index];
    return (nursery.name);
  }

  function getNurseryOwnerAddress(uint index) public view returns(address) {
    SupplyDataTypes.Nursery memory nursery = nurseries[index];
    return (nursery.ownerAddress);
  }
}