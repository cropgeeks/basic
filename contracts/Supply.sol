pragma solidity  > 0.5.0;

import "../node_modules/openzeppelin-solidity/contracts/access/Roles.sol";
import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract Supply is Ownable {
  using Roles for Roles.Role;

  Roles.Role private nurseryOwners;
  Roles.Role private farmers;

  Owner[] public nurseryOwnerList;
  Owner[] public farmOwnerList;
  Owner[] public ownerList;

  enum State { Propogated, Purchased, Shipped, Received, Planted, Harvested, Packed, Weighed, Stored, AtDistribution, Distributed, Sold }

  enum OrderState { Ordered, Dispatched, Recevied }

  struct Owner {
    uint id;
    string name;
    address ownerAddress;
  }

  struct Nursery {
    uint id;
    string name;
    int lat;
    int long;
    string description;
    uint ownerId;
  }

  struct Plant {
    uint id; // id of the plant
    State state; // the state of the plant in the supply chain
    uint plantedDate; // date the plant was planeted
    int lat; // Latitute of plant location
    int long; // Longitude of plant location
    string sourceNursery; // Nursery plant was grown at
    string variety;
    address plantOwner;
  }

  struct Farm {
    uint id;
    string name;
    int lat;
    int long;
    address farmer;
  }

  struct Order {
    uint orderId;
    address nursery;
    address farmer;
    uint[] plantIds;
    OrderState state;
  }

  Nursery[] public nurseries;
  mapping(address => Nursery) public nurseriesByOwners;

  // Dynamically sized plant array
  Plant[] public plants;

  Order[] public orders;

  Farm[] public farms;
  mapping(address => Farm) public farmsByOwners;

  event AddedNurseryOwner(string name, address nurseryOwner);
  event AddedFarmOwner(string name, address farmOwner);
  event AddedNursery(uint nurseryId, string nurseryName, int lat, int long, string description, uint ownerId, string ownerName);
  event PropogatedByNursery(uint indexed plantId, address plantOwner, string nurseryName, uint date, int lat, int long);
  event PurchasedByFarmer(uint indexed plantId, address plantOwner, string nurseryName, string farmName, uint date, int lat, int long);
  event ShippedByNursery(uint indexed plantId, address plantOwner, uint date);
  event ReceivedByFarmer(uint indexed plantId, address plantOwner, uint date);
  event PlantedByFarmer(uint indexed plantId, address plantOwner, uint date);

  constructor() public {
    // addNurseryOwner(0x21111104e6933e6fb2bB4dc99AB5B65439226043);
    // addNursery(0, "Raspberry Nursery", 56, 3, "Small nursery for raspberries", 0x21111104e6933e6fb2bB4dc99AB5B65439226043);
    // addFarmer(0xdacF2A85BEbdD88e49DF032A61b5d7679eafb25E);
    // addFarm(0, "Invergowrie", 56, 3, 0xdacF2A85BEbdD88e49DF032A61b5d7679eafb25E);
  }

  function getOwnerCount() public view returns(uint) {
    return ownerList.length;
  }

  function addNurseryOwner(string memory name, address nurseryOwner) public onlyOwner {
    nurseryOwners.add(nurseryOwner);
    Owner memory owner = Owner(ownerList.length, name, nurseryOwner);
    ownerList.push(owner);
    nurseryOwnerList.push(owner);
    emit AddedNurseryOwner(name, nurseryOwner);
  }

  function getNurseryOwnerCount() public view returns(uint) {
    return nurseryOwnerList.length;
  }

  function getNurseryOwner(uint index) public view returns(uint, string memory, address) {
    Owner memory nurseryOwner = nurseryOwnerList[index];
    return (nurseryOwner.id, nurseryOwner.name, nurseryOwner.ownerAddress);
  }

  function addNursery(string memory name, int lat, int long, string memory nurseryDescription, uint ownerId) public onlyOwner {
    Owner memory owner = ownerList[ownerId];
    require(nurseryOwners.has(owner.ownerAddress), "address is not a nursery owner");
    Nursery memory nursery = Nursery(nurseries.length, name, lat, long, nurseryDescription, ownerId);
    nurseries.push(nursery);
    nurseriesByOwners[owner.ownerAddress] = nursery;
    emit AddedNursery(nursery.id, name, lat, long, nurseryDescription, ownerId, owner.name);
  }

  function getNurseryCount() public view returns(uint) {
    return nurseries.length;
  }

  function getNursery(uint index) public view returns(uint, string memory, int, int, string memory, string memory) {
    Nursery memory nursery = nurseries[index];
    Owner memory owner = ownerList[nursery.ownerId];
    return (nursery.id, nursery.name, nursery.lat, nursery.long, nursery.description, owner.name);
  }

  function propogatePlant(uint date) public {
    require(nurseryOwners.has(msg.sender), "only nursery owner can propogate plants");
    Nursery memory nursery = nurseriesByOwners[msg.sender];
    uint plantId = plants.length;
    addPlant(plantId, State.Propogated, date, nursery.lat, nursery.long, nursery.name, "Glen Moy", msg.sender);
    emit PropogatedByNursery(plantId, msg.sender, nursery.name, date, nursery.lat, nursery.long);
  }

   function addFarmOwner(string memory name, address farmOwner) public onlyOwner {
    farmers.add(farmOwner);
    Owner memory owner = Owner(ownerList.length, name, farmOwner);
    ownerList.push(owner);
    farmOwnerList.push(owner);
    emit AddedFarmOwner(name, farmOwner);
  }

  function getFarmOwnerCount() public view returns(uint) {
    return farmOwnerList.length;
  }

  function getFarmOwner(uint index) public view returns(string memory, address) {
    Owner memory farmOwner = farmOwnerList[index];
    return (farmOwner.name, farmOwner.ownerAddress);
  }

  function addFarm(uint id, string memory name, int lat, int long, address farmer) public onlyOwner {
    require(farmers.has(farmer), "address is not a farmer");
    Farm memory farm = Farm(id, name, lat, long, farmer);
    farms.push(farm);
    farmsByOwners[farmer] = farm;
  }

  function addPlant(uint id, State _state, uint _date, int _lat, int _long, string memory _nursery, string memory variety, address plantOwner) public {
    Plant memory plant = Plant(id, _state, _date, _lat, _long, _nursery, variety, plantOwner);
    plants.push(plant);
  }

  function getPlantCount() public view returns(uint) {
    return plants.length;
  }

  function getPlant(uint index) public view returns(uint, State, uint, int, int, string memory, string memory, address plantOwner) {
    Plant memory plant = plants[index];
    return (plant.id, plant.state, plant.plantedDate, plant.lat, plant.long, plant.sourceNursery, plant.variety, plant.plantOwner);
  }

  modifier purchasedByFarmer(uint id) {
    require(plants[id].state == State.Purchased, "the state of the plant in this function must be Purchased");
    _;
  }

  function isNurseryOwner() public view returns(bool) {
    return nurseryOwners.has(msg.sender);
  }

  function isFarmer() public view returns(bool) {
    return farmers.has(msg.sender);
  }

  function getOrderCount() public view returns(uint) {
    return orders.length;
  }

  function orderPlants(uint[] memory plantIds, address nurseryOwner, uint purchaseDate) public {
    require(farmers.has(msg.sender), "address is not a farmer");
    uint orderId = orders.length;
    Order memory order = Order(orderId, nurseryOwner, msg.sender, plantIds, OrderState.Ordered);

    Farm memory farm = farmsByOwners[msg.sender];
    Nursery memory nursery = nurseriesByOwners[nurseryOwner];

    for (uint i = plantIds[0]; i < plantIds[0] + plantIds.length; i++) {
      plants[i].state = State.Purchased;
      emit PurchasedByFarmer(i, nurseryOwner, nursery.name, farm.name, purchaseDate, nursery.lat, nursery.long);
    }

    orders.push(order);
  }
}