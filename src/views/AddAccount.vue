<template>
  <b-container class="container-top">
    <h1>Add Account</h1>
    <div class="row" v-if="isAdmin">
      <div class="col">
        <div class="row mt-3">
          <b-table striped hover small bordered caption-top caption="Nursery Owners" :items="nurseryOwners"></b-table>
          <p v-if="nurseryOwners.length === 0">No nursery owners found</p>
        </div>
        <div class="row mt-3">
          <b-table striped hover small bordered caption-top caption="Farm Owners" :items="farmOwners"></b-table>
          <p v-if="farmOwners.length === 0">No farm owners found</p>
        </div>

        <b-button v-b-modal.addModal class="float-left" variant="primary">Add account</b-button>
        <b-modal id="addModal" title="Add account" @ok="addAccount">
          <b-form class="mt-3">
            <b-form-group label="Role" label-for="role" label-align="left">
              <b-form-select id="role" size="sm" :options="roles" v-model="selectedRole"></b-form-select>
            </b-form-group>
            <b-form-group label="Name" label-for="name" label-align="left">
              <b-input id="name" type="text" size="sm" v-model="name"/>
            </b-form-group>
            <b-form-group label="Account" label-for="account" label-align="left">
              <b-input id="account" type="text" size="sm" placeholder="0x000..." v-model="account"/>
            </b-form-group>
          </b-form>
        </b-modal>
      </div>
    </div>
  </b-container>

</template>

<script>
import web3 from '../util/getWeb3'
import Supply from '../../build/contracts/Supply.json'
import TruffleContract from 'truffle-contract'

export default {
  name: 'home',
  data() {
    return {
      w3: web3,
      defaultAccount: null,
      supplyContract: null,
      isAdmin: false,
      account: null,
      selectedRole: null,
      name: null,
      roles: ["Nursery", "Farmer"],
      nurseryOwners: [],
      farmOwners: []
    }
  },
  mounted() {
    web3.eth.getAccounts().then((acc) => {
      // Standard in page setup of web3 and contract variables
      this.defaultAccount = acc[0]
      web3.eth.defaultAccount = acc[0]
      this.supplyContract = TruffleContract(Supply)
      this.supplyContract.setProvider(this.w3.currentProvider)
      this.supplyContract.defaults({from: this.w3.eth.defaultAccount})

      // Specific setup of elements for this page
      this.supplyContract.deployed().then((contract) => {
        this.adminCheck(contract);
        this.initNurseryOwners(contract);
        this.setupNurseryOwnerEvent(contract);
        this.initFarmOwners(contract);
        this.setupFarmOwnerEvent(contract);
      })
    })
  },
  methods: {
    // Called from the modal launched via the add account button
    addAccount() {
      this.supplyContract.deployed().then((contract) => {
        // Try to add an account of the selected type
        if (this.selectedRole === "Nursery") {
          contract.addNurseryOwner(this.name, this.account);
        } else if (this.selectedRole === "Farmer") {
          contract.addFarmOwner(this.name, this.account);
        }
      }).catch(error => {
        // TODO: Flag to the user in some useful way
        console.log(error);
      }).then(() => {
        // We want to blank out our form fields whether we succeeded or failed
        // hence the placement in a then after the catch
        this.account = null;
        this.selectedRole = null;
        this.name = null;
      })
    },
    adminCheck: function(contract) {
      contract.isOwner().then((isOwner) => {
        this.isAdmin = isOwner;
      })
    },
     // Load any existing nursery owners into an array with backs a table
    initNurseryOwners: function(contract) {
      contract.getNurseryOwnerCount().then((count) => {
        for (var i =0; i < count; i++) {
          contract.getNurseryOwner(i).then((nurseryOwner) => {
            let n = {
              name: nurseryOwner[0].toString(),
              address: nurseryOwner[1].toString()
            }

            this.nurseryOwners.push(n);
          })
        }
      })
    },
    // Setup the event listener which checks for the addition of new nursery owners
    setupNurseryOwnerEvent: function(contract) {
      contract.AddedNurseryOwner().on('data', event => {
        let n = {
          name: event.returnValues.name,
          address: event.returnValues.nurseryOwner
        }

        this.nurseryOwners.push(n);
      });
    },
    // Load any existing farm owners into an array with backs a table
    initFarmOwners: function(contract) {
      contract.getFarmOwnerCount().then((count) => {
        for (var i =0; i < count; i++) {
          contract.getFarmOwner(i).then((farmOwner) => {
            let n = {
              name: farmOwner[0].toString(),
              address: farmOwner[1].toString()
            }

            this.farmOwners.push(n);
          })
        }
      })
    },
    // Setup the event listener which checks for the addition of new farm owners
    setupFarmOwnerEvent: function(contract) {
      contract.AddedFarmOwner().on('data', event => {
        let f = {
          name: event.returnValues.name,
          address: event.returnValues.farmOwner
        }

        this.farmOwners.push(f);
      })
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
.container-top{
  margin-top: 2%;
}
</style>
