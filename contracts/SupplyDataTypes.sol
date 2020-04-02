pragma solidity  > 0.5.0;

library SupplyDataTypes {
  enum State { Propogated, Purchased, Shipped, Stored, Planted, Harvested, Packed }
  enum OrderState { Placed, Dispatched, Received }
  enum Role { Nursery, Farmer, Packhouse }

  struct Nursery {
    uint id;
    string name;
    int lat;
    int long;
    string description;
    address ownerAddress;
  }

  struct Owner {
    string name;
    address ownerAddress;
  }

  struct Plant {
    uint id; // id of the plant
    State state; // the state of the plant in the supply chain
    uint plantedDate; // date the plant was planeted
    int lat; // Latitute of plant location
    int long; // Longitude of plant location
    string sourceNursery; // Nursery plant was grown at
    string variety;
    address ownerAddress;
  }

  struct Farm {
    uint id;
    string name;
    int lat;
    int long;
    string description;
    address ownerAddress;
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
}