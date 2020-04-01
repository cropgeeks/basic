var SupplyDataTypes = artifacts.require("./SupplyDataTypes.sol");
var NurseryManager = artifacts.require("./NurseryManager.sol");
var FarmManager = artifacts.require("./FarmManager.sol");
var OrderManager = artifacts.require("./OrderManager.sol");
var Supply = artifacts.require("./Supply.sol");

module.exports = function(deployer) {
  deployer.deploy(SupplyDataTypes);
  deployer.deploy(Supply).then(() => Supply.deployed())
    .then(() => deployer.deploy(NurseryManager))
    .then(() => NurseryManager.deployed())
    .then(() => deployer.deploy(FarmManager))
    .then(() => FarmManager.deployed())
    .then(() => deployer.deploy(OrderManager, NurseryManager.address, FarmManager.address, Supply.address));
};