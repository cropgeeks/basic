import web3 from '../util/getWeb3'
import Supply from '../../build/contracts/Supply.json'
import NurseryManager from '../../build/contracts/NurseryManager.json'
import FarmManager from '../../build/contracts/FarmManager.json'
import OrderManager from '../../build/contracts/OrderManager.json'
import TruffleContract from 'truffle-contract'

export default {
  data: function() {
    return {
      w3: web3,
      defaultAccount: null,
      supplyContract: null,
      nurseryManager: null,
      orderManager: null,
      isAdmin: false,
      roles: [ 'Nursery', 'Farmer' ]
    }
  },
  mounted: function() {
    web3.eth.getAccounts().then((acc) => {
      // Standard in page setup of web3 and contract variables
      this.defaultAccount = acc[0]
      web3.eth.defaultAccount = acc[0]
      this.supplyContract = TruffleContract(Supply)
      this.supplyContract.setProvider(this.w3.currentProvider)
      this.supplyContract.defaults({from: this.w3.eth.defaultAccount})

      this.nurseryManager = TruffleContract(NurseryManager);
      this.nurseryManager.setProvider(this.w3.currentProvider)
      this.nurseryManager.defaults({from: this.w3.eth.defaultAccount})

      this.farmManager = TruffleContract(FarmManager);
      this.farmManager.setProvider(this.w3.currentProvider)
      this.farmManager.defaults({from: this.w3.eth.defaultAccount})

      this.orderManager = TruffleContract(OrderManager);
      this.orderManager.setProvider(this.w3.currentProvider)
      this.orderManager.defaults({from: this.w3.eth.defaultAccount})

      // We want the admin check to occur on every page load
      this.supplyContract.deployed().then((contract) => {
        this.adminCheck(contract);
      })
    })
  },
  methods: {
    adminCheck: function(contract) {
      contract.isOwner().then((isOwner) => {
        this.isAdmin = isOwner;
      })
    },
    getNurseries: function(contract) {
      const nurseries = [];
      contract.getNurseryCount().then((count) => {
        for (var i = 0; i < count; i++) {
          contract.getNursery(i).then((nursery) => {
            let n = {
              id: nursery[0].toNumber(),
              name: nursery[1].toString(),
              lat: nursery[2].toNumber(),
              long: nursery[3].toNumber(),
              description: nursery[4].toString(),
              owner: nursery[5].toString()
            }
            nurseries.push(n);
          })
        }
      })
      return nurseries;
    },
    getNurseryOwners: function(contract) {
      const owners = [];
      contract.getNurseryOwnerCount().then((count) => {
        for (var i = 0; i < count; i++) {
          contract.getNurseryOwner(i).then((owner) => {
            let n = {
              name: owner[0].toString(),
              address: owner[1]
            }
            owners.push(n);
          })
        }
      })
      return owners;
    },
    getFarms: function(contract) {
      const farms = [];
      contract.getFarmCount().then((count) => {
        for (var i = 0; i < count; i++) {
          contract.getFarm(i).then((farm) => {
            let n = {
              id: farm[0].toNumber(),
              name: farm[1].toString(),
              lat: farm[2].toNumber(),
              long: farm[3].toNumber(),
              description: farm[4].toString(),
              owner: farm[5].toString()
            }
            farms.push(n);
          })
        }
      })
      return farms;
    },
    getFarmOwners: function(contract) {
      const owners = [];
      contract.getFarmOwnerCount().then((count) => {
        for (var i = 0; i < count; i++) {
          contract.getFarmOwner(i).then((owner) => {
            let n = {
              name: owner[0].toString(),
              address: owner[1].toString()
            }
            owners.push(n);
          })
        }
      })
      return owners;
    },
    getOrders: function(contract) {
      const orders = [];
      contract.getOrderCount().then((count) => {
        for (var i = 0; i < count; i++) {
          contract.getOrder(i).then((order) => {
            let o = {
              id: order[0].toNumber(),
              nurseryName: order[1].toString(),
              farmName: order[2].toString(),
              quantity: order[3].toNumber(),
              state: order[4].toNumber(),
              lastUpdated: new Date(order[5].toNumber() * 1000)
            }
            orders.push(o);
          })
        }
      })
      return orders;
    }
  }
}