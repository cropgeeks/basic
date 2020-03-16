import web3 from '../util/getWeb3'
import Supply from '../../build/contracts/Supply.json'
import TruffleContract from 'truffle-contract'

export default {
  data: function() {
    return {
      w3: web3,
      defaultAccount: null,
      supplyContract: null,
      isAdmin: false
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
    }
  }
}