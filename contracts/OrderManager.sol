pragma solidity  > 0.5.0;

import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./SupplyDataTypes.sol";
import "./FarmManager.sol";
import "./NurseryManager.sol";
import "./Supply.sol";

contract OrderManager is Ownable {
  NurseryManager nurseryManager;
  FarmManager farmManager;
  Supply supply;

  SupplyDataTypes.Order[] public orders;

  event OrderPlaced(uint orderId, string nurseryName, string farmName, uint quantity, SupplyDataTypes.OrderState state, uint placedDate);
  event OrderDispatched(uint orderId, string nurseryName, string farmName, uint quantity, SupplyDataTypes.OrderState state, uint dispatchedDate);
  event OrderReceived(uint orderId, string nurseryName, string farmName, uint quantity, SupplyDataTypes.OrderState state, uint receivedDate);

  constructor(address nurseryManagerAddress, address farmManagerAddress, address supplyAddress) public {
    nurseryManager = NurseryManager(nurseryManagerAddress);
    farmManager = FarmManager(farmManagerAddress);
    supply = Supply(supplyAddress);
  }

  function getOrderCount() public view returns(uint) {
    return orders.length;
  }

  function getOrder(uint index) public view returns(uint, string memory, string memory, uint, SupplyDataTypes.OrderState, uint) {
    SupplyDataTypes.Order memory order = orders[index];
    string memory nurseryName = nurseryManager.getNurseryName(order.nurseryId);
    string memory farmName = farmManager.getFarmName(order.farmId);
    return (order.orderId, nurseryName, farmName, order.quantity, order.state, order.updated);
  }

  function orderPlants(uint quantity, uint nurseryId, uint farmId, uint purchaseDate) public {
    uint orderId = orders.length;
    uint[] memory plantIds = new uint[](quantity);
    SupplyDataTypes.Order memory order = SupplyDataTypes.Order(orderId, nurseryId, farmId, quantity, plantIds, SupplyDataTypes.OrderState.Placed, purchaseDate);

    string memory farmName = farmManager.getFarmName(farmId);
    string memory nurseryName = nurseryManager.getNurseryName(order.nurseryId);

    emit OrderPlaced(orderId, nurseryName, farmName, quantity, SupplyDataTypes.OrderState.Placed, purchaseDate);

    orders.push(order);
  }

  function dispatchOrder(uint orderId, uint[] memory plantIds, uint dispatchedDate, string memory farmName, string memory nurseryName, int lat, int long) public {
    SupplyDataTypes.Order storage order = orders[orderId];
    order.state = SupplyDataTypes.OrderState.Dispatched;
    order.updated = dispatchedDate;
    order.plantIds = plantIds;

    emit OrderDispatched(order.orderId, nurseryName, farmName, order.quantity, order.state, order.updated);

    for (uint i = 0; i < plantIds.length; i++) {
      supply.dispatchedByNursery(plantIds[i], order.orderId, order.nurseryId, nurseryName, order.farmId, farmName, dispatchedDate, lat, long);
    }
  }

  function receiveOrder(uint orderId, uint receivedDate, string memory storeName, int storeTemp) public {
    SupplyDataTypes.Order storage order = orders[orderId];
    order.state = SupplyDataTypes.OrderState.Received;
    order.updated = receivedDate;

    string memory farmName = farmManager.getFarmName(order.farmId);
    string memory nurseryName = nurseryManager.getNurseryName(order.nurseryId);
    address farmAddress = farmManager.getFarmAddress(order.farmId);

    emit OrderReceived(order.orderId, nurseryName, farmName, order.quantity, order.state, order.updated);

    for (uint i = 0; i < order.plantIds.length; i++) {
      supply.receivePlant(order.plantIds[i], farmAddress, order.updated, storeName, storeTemp);
    }
  }
}