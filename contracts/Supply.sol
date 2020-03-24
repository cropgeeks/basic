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

  enum OrderState { Placed, Dispatched, Recevied }

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
    uint ownerId;
  }

  struct Farm {
    uint id;
    string name;
    int lat;
    int long;
    string description;
    uint ownerId;
  }

  struct Order {
    uint orderId;
    uint nurseryId;
    uint farmId;
    uint quantity;
    uint[] plantIds;
    OrderState state;
    uint updated;
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
  event AddedFarm(uint farmId, string farmName, int lat, int long, string description, uint ownerId, string ownerName);
  event PropogatedByNursery(uint indexed plantId, Supply.State state, uint date, int lat, int long, string name, string variety, uint indexed ownerId);
  event OrderPlaced(uint orderId, string nurseryName, string farmName, uint plantIds, OrderState state, uint placedDate);
  event PurchasedByFarmer(uint indexed plantId, string nurseryName, string farmName, uint date, int lat, int long);
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

  function getNursery(uint index) public view returns(uint, string memory, int, int, string memory, string memory, uint) {
    Nursery memory nursery = nurseries[index];
    Owner memory owner = ownerList[nursery.ownerId];
    return (nursery.id, nursery.name, nursery.lat, nursery.long, nursery.description, owner.name, nursery.ownerId);
  }

  function propogatePlants(uint date, string memory variety, int quantity) public {
    require(nurseryOwners.has(msg.sender), "only nursery owner can propogate plants");
    Nursery memory nursery = nurseriesByOwners[msg.sender];
    uint plantId = plants.length;
    for (int i = 0; i < quantity; i++) {
      addPlant(plantId, State.Propogated, date, nursery.lat, nursery.long, nursery.name, variety, nursery.ownerId);
      emit PropogatedByNursery(plantId, State.Propogated, date, nursery.lat, nursery.long, nursery.name, variety, nursery.ownerId);
      plantId++;
    }
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

  function getFarmOwner(uint index) public view returns(uint, string memory, address) {
    Owner memory farmOwner = farmOwnerList[index];
    return (farmOwner.id, farmOwner.name, farmOwner.ownerAddress);
  }

  function addFarm(string memory name, int lat, int long, string memory description, uint ownerId) public onlyOwner {
    Owner memory owner = ownerList[ownerId];
    require(farmers.has(owner.ownerAddress), "address is not a farmer");
    Farm memory farm = Farm(farms.length, name, lat, long, description, ownerId);
    farms.push(farm);
    farmsByOwners[owner.ownerAddress] = farm;
    emit AddedFarm(farm.id, name, lat, long, description, ownerId, owner.name);
  }

  function getFarmCount() public view returns(uint) {
    return farms.length;
  }

  function getFarm(uint index) public view returns(uint, string memory, int, int, string memory, string memory, uint) {
    Farm memory farm = farms[index];
    Owner memory owner = ownerList[farm.ownerId];
    return (farm.id, farm.name, farm.lat, farm.long, farm.description, owner.name, farm.ownerId);
  }

  function addPlant(uint id, State _state, uint _date, int _lat, int _long, string memory _nursery, string memory variety, uint ownerId) public {
    Plant memory plant = Plant(id, _state, _date, _lat, _long, _nursery, variety, ownerId);
    plants.push(plant);
  }

  function getPlantCount() public view returns(uint) {
    return plants.length;
  }

  function getPlant(uint index) public view returns(uint, State, uint, int, int, string memory, string memory, uint ownerId) {
    Plant memory plant = plants[index];
    return (plant.id, plant.state, plant.plantedDate, plant.lat, plant.long, plant.sourceNursery, plant.variety, plant.ownerId);
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

  function getOrder(uint index) public view returns(uint, string memory, string memory, uint, OrderState, uint) {
    Order memory order = orders[index];
    Nursery memory nursery = nurseries[order.nurseryId];
    Farm memory farm = farms[order.farmId];
    return (order.orderId, nursery.name, farm.name, order.quantity, order.state, order.updated);
  }

  function orderPlants(uint quantity, uint nurseryId, uint farmId, uint purchaseDate) public {
    require(farmers.has(msg.sender), "address is not a farmer");
    uint orderId = orders.length;
    uint[] memory plantIds = new uint[](quantity);
    Order memory order = Order(orderId, nurseryId, farmId, quantity, plantIds, OrderState.Placed, purchaseDate);

    Farm memory farm = farms[farmId];
    Nursery memory nursery = nurseries[nurseryId];

    emit OrderPlaced(orderId, nursery.name, farm.name, quantity, OrderState.Placed, purchaseDate);

    // for (uint i = plantIds[0]; i < plantIds[0] + plantIds.length; i++) {
    //   plants[i].state = State.Purchased;
    //   emit PurchasedByFarmer(i, nursery.name, farm.name, purchaseDate, nursery.lat, nursery.long);
    // }

    orders.push(order);
  }
}