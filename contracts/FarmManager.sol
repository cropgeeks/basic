pragma solidity  > 0.5.0;

import "../node_modules/openzeppelin-solidity/contracts/access/Roles.sol";
import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./SupplyDataTypes.sol";

contract FarmManager is Ownable {
  using Roles for Roles.Role;

  Roles.Role private farmOwners;

  struct FarmStorage {
    uint id;
    uint farmId;
    string name;
    int temperature;
  }

  SupplyDataTypes.Farm[] public farms;
  SupplyDataTypes.Owner[] public farmOwnerList;
  FarmStorage[] public stores;
  mapping(address => SupplyDataTypes.Owner) public ownersByAddress;

  event AddedFarm(uint farmId, string name, int lat, int long, string description, string ownerName, address ownerAddress);
  event AddedFarmOwner(string name, address farmOwner);
  event AddedStore(uint storeId, uint farmId, string name, int temperature);

  constructor() public {
  }

  function addFarmOwner(string memory name, address farmOwner) public onlyOwner {
    farmOwners.add(farmOwner);
    SupplyDataTypes.Owner memory owner = SupplyDataTypes.Owner(name, farmOwner);
    farmOwnerList.push(owner);
    ownersByAddress[farmOwner] = owner;
    emit AddedFarmOwner(owner.name, owner.ownerAddress);
  }

  function isFarmOwner(uint index) public view returns(bool) {
    return farms[index].ownerAddress == msg.sender;
  }

  function getFarmOwnerCount() public view returns(uint) {
    return farmOwnerList.length;
  }

  function getFarmOwner(uint index) public view returns(string memory, address) {
    SupplyDataTypes.Owner memory owner = farmOwnerList[index];
    return (owner.name, owner.ownerAddress);
  }

  function addFarm(string memory name, int lat, int long, string memory description, address ownerAddress) public onlyOwner {
    SupplyDataTypes.Farm memory farm = SupplyDataTypes.Farm(farms.length, name, lat, long, description, ownerAddress);
    farms.push(farm);
    SupplyDataTypes.Owner memory owner = ownersByAddress[ownerAddress];
    emit AddedFarm(farm.id, name, lat, long, description, owner.name, ownerAddress);
  }

  function getFarmCount() public view returns(uint) {
    return farms.length;
  }

  function getFarm(uint index) public view returns(uint, string memory, int, int, string memory, string memory, address) {
    SupplyDataTypes.Farm memory farm = farms[index];
    SupplyDataTypes.Owner memory owner = ownersByAddress[farm.ownerAddress];
    return (farm.id, farm.name, farm.lat, farm.long, farm.description, owner.name, farm.ownerAddress);
  }

  function getFarmName(uint index) public view returns(string memory) {
    SupplyDataTypes.Farm memory farm = farms[index];
    return (farm.name);
  }

  function getFarmAddress(uint index) public view returns(address) {
    SupplyDataTypes.Farm memory farm = farms[index];
    return (farm.ownerAddress);
  }

  function addFarmStorage(uint farmId, string memory name, int temperature) public {
    FarmStorage memory store = FarmStorage(stores.length, farmId, name, temperature);
    stores.push(store);
    emit AddedStore(store.id, store.farmId, name, store.temperature);
  }

  function getFarmStorageCount() public view returns(uint) {
    return stores.length;
  }

  function getFarmStorage(uint index) public view returns(uint, uint, string memory, int) {
    FarmStorage memory store = stores[index];
    return (store.id, store.farmId, store.name, store.temperature);
  }
}