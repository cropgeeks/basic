pragma solidity >=0.4.22 <0.7.0;

contract Supply {
  enum State { Planted, Harvested, Weighted }

  struct Plant {
    uint id; // id of the plant
    State state; // the state of the plant in the supply chain
    uint plantedDate; // date the plant was planeted
    int lat; // Latitute of plant location
    int long; // Longitude of plant location
    string sourceNursery; // Nursery plant was grown at
  }

  // Dynamically sized plant array
  Plant[] public plants;

  constructor() public {
    addPlant(0, State.Planted, 1566383873, 56, 3, "Invergowrie");
  }

  function addPlant(uint id, State _state, uint _date, int _lat, int _long, string memory _nursery) public {
    Plant memory plant = Plant(id, _state, _date, _lat, _long, _nursery);
    plants.push(plant);
  }

  function firstPlantedDate() public view returns (uint date_)
  {
    date_ = plants[0].plantedDate;
  }

  function getPlantCount() public view returns(uint) {
    return plants.length;
  }

  function getPlant(uint index) public view returns(uint, State, uint, int, int, string memory) {
    Plant memory plant = plants[index];
    return (plant.id, plant.state, plant.plantedDate, plant.lat, plant.long, plant.sourceNursery);
  }
}