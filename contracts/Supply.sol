pragma solidity  > 0.5.0;

import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./NurseryManager.sol";
import "./FarmManager.sol";
import "./OrderManager.sol";
import "./SupplyDataTypes.sol";

contract Supply is Ownable {
  // Dynamically sized plant array
  SupplyDataTypes.Plant[] public plants;

  event PropogatedByNursery(uint indexed plantId, SupplyDataTypes.State state, uint date, int lat, int long, string name, string variety, address indexed ownerAddress);
  event PurchasedByFarmer(uint indexed plantId, uint orderId, uint nurseryId, string nurseryName, uint farmId, string farmName, uint date, int lat, int long);
  event DispatchedByNursery(uint indexed plantId, uint orderId, uint nurseryId, string nurseryName, uint farmId, string farmName, uint date, int lat, int long);
  event StoredByFarmer(uint indexed plantId, address plantOwner, uint date, string storeName, int storeTemp);
  event PlantedByFarmer(uint indexed plantId, address plantOwner, uint date);

  constructor() public {
    // addNurseryOwner(0x21111104e6933e6fb2bB4dc99AB5B65439226043);
    // addNursery(0, "Raspberry Nursery", 56, 3, "Small nursery for raspberries", 0x21111104e6933e6fb2bB4dc99AB5B65439226043);
    // addFarmer(0xdacF2A85BEbdD88e49DF032A61b5d7679eafb25E);
    // addFarm(0, "Invergowrie", 56, 3, 0xdacF2A85BEbdD88e49DF032A61b5d7679eafb25E);
  }

  // function getOwnerCount() public view returns(uint) {
  //   return ownerList.length;
  // }

  // function getOwner(uint index) public view returns(uint, string memory, address, SupplyDataTypes.Role) {
  //   SupplyDataTypes.Owner memory owner = ownerList[index];
  //   return (owner.id, owner.name, owner.ownerAddress, owner.role);
  // }

  // function addFarmOwner(string memory name, address farmOwner) public onlyOwner {
  //   farmers.add(farmOwner);
  //   SupplyDataTypes.Owner memory owner = SupplyDataTypes.Owner(ownerList.length, name, farmOwner);
  //   ownerList.push(owner);
  //   farmManager.addFarmOwner(owner);
  // }

  function propogatePlants(uint date, string memory variety, int quantity, string memory nurseryName, int lat, int long, address ownerAddress) public {
    uint plantId = plants.length;
    for (int i = 0; i < quantity; i++){
      addPlant(plantId, SupplyDataTypes.State.Propogated, date, lat, long, nurseryName, variety, ownerAddress);
      plantId++;
    }
  }

  function dispatchedByNursery(uint plantId, uint orderId, uint nurseryId, string memory nurseryName, uint farmId, string memory farmName, uint dispatchedDate, int lat, int long) public {
    SupplyDataTypes.Plant storage plant = plants[plantId];
    plant.state = SupplyDataTypes.State.Shipped;

    emit PurchasedByFarmer(plantId, orderId, nurseryId, nurseryName, farmId, farmName, dispatchedDate, lat, long);
    emit DispatchedByNursery(plantId, orderId, nurseryId, nurseryName, farmId, farmName, dispatchedDate, lat, long);
  }

  function addPlant(uint id, SupplyDataTypes.State state, uint date, int lat, int long, string memory nursery, string memory variety, address ownerAddress) public {
    SupplyDataTypes.Plant memory plant = SupplyDataTypes.Plant(id, state, date, lat, long, nursery, variety, ownerAddress);
    plants.push(plant);
    emit PropogatedByNursery(id, state, date, lat, long, nursery, variety, ownerAddress);
  }

  function getPlantCount() public view returns(uint) {
    return plants.length;
  }

  function getPlant(uint index) public view returns(uint, SupplyDataTypes.State, uint, int, int, string memory, string memory, address ownerAddress) {
    SupplyDataTypes.Plant memory plant = plants[index];
    return (plant.id, plant.state, plant.plantedDate, plant.lat, plant.long, plant.sourceNursery, plant.variety, plant.ownerAddress);
  }

  function receivePlant(uint index, address ownerAddress, uint date, string memory storeName, int storeTemp) public {
    SupplyDataTypes.Plant storage plant = plants[index];
    plant.state = SupplyDataTypes.State.Stored;
    plant.ownerAddress = ownerAddress;

    emit StoredByFarmer(index, ownerAddress, date, storeName, storeTemp);
  }

  // modifier purchasedByFarmer(uint id) {
  //   require(plants[id].state == SupplyDataTypes.State.Purchased, "the state of the plant in this function must be Purchased");
  //   _;
  // }
}