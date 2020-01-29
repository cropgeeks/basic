const Supply = artifacts.require("./Supply.sol");

contract('Supply', function(accounts) {
  contract('Supply.Constructor', function(accounts) {
    it("Contract owner is sender", function() {
      return Supply.deployed().then(function(instance) {
        return instance.owner();
      })
      .then(function(contractOwner) {
        assert.equal(contractOwner.valueOf(), accounts[0], "accounts[0] wasn't the contract owner");
      });
    });
  });
});